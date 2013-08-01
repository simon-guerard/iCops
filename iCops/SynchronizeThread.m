//
//  SynchronizeThread.m
//  iCops
//
//  Created by Simon Guérard on 19/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import "SynchronizeThread.h"
#import "Article.h"
#import "Book.h"
#import "Author.h"
#import "Library.h"
#import "NetworkHelper.h"
#import "LibraryParserDelegate.h"
#import "BookParserDelegate.h"

@interface SynchronizeThread ()

@property NSArray * libraries;
@property NSMutableArray * articlesList;

-(void) synchLibrary;
-(void) synchBooks;
-(void) synchBookDetail:(Article *)article;
-(void) synchDataWithStore:(NSArray *) lstArticles;

@end

@implementation SynchronizeThread

static SynchronizeThread * sharedInstance;

NSString *const LoadingBooksNotificationConstant = @"LoadingBooksNotification";

@synthesize managedObjectContext=_managedObjectContext,aQueue=_aQueue,initData=_initData,libraries=_libraries,articlesList=_articlesList;

+(SynchronizeThread *) sharedInstance:(NSManagedObjectContext *) managedContext {
    if (! sharedInstance) {
        sharedInstance=[[SynchronizeThread alloc] initWithManagedContext:managedContext];
    }
    return sharedInstance;
}

-(id) initWithManagedContext:(NSManagedObjectContext *) managedContext {
    _managedObjectContext = managedContext;
    
    self = [super init];
    if (self) {
        // Initialize self.
       _aQueue = [[NSOperationQueue alloc] init];
        [_aQueue setName:@"LoadingQueue"];
        _initData=true;
        
        /*
        // init a timer to run synchronization thread method all 15 seconds.
        NSTimer * timer = [NSTimer timerWithTimeInterval:1500 target:self selector:@selector(runSynchOperation) userInfo:nil repeats:YES];
        
        // attach the timer to the currentRunLoop
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        */
        [self synchLibrary];
    }
    return self;
}

-(Boolean) isInitData {
    return _initData;
}

#pragma mark - Synchronization operation

-(void) synchLibrary {
    NSLog(@"Synchronization of data");
    
    // get the default url of cops application
    NSString * urlText = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_cops_preference"];
    
    // concatenate the default url and the books page to obtain the real url
    NSString * urlBase = [urlText stringByAppendingString:@"/cops/index.php"];
    NSLog(@"urlBase: %@", urlBase);
    
    NSURL * url = [NetworkHelper smartURLForString:urlBase];
    
    // init the xml parser with the cops libraries' page url
    NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    LibraryParserDelegate * delegate = [[LibraryParserDelegate alloc] init];
    [parser setDelegate:delegate];
    [parser setShouldResolveExternalEntities:YES];
    
    // perform parsing
    if ([parser parse]) {
        NSLog(@"Loop over library list");
        for (Article * article in [delegate articlesList]) {
            NSLog(@"library list name %@", article.name);
            
            // Create the fetch request for the entity 'Library'.
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            // Edit the entity name as appropriate.
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:_managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@)", article.name];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *array = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (array == nil)
            {
                // Deal with error...
                NSLog(@"Error in executeFetchRequest(Library)");
            }
            
            if (array.count == 0) {
                // create the book
                NSLog(@"Creation of a new library.");
                
                Library *newLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:_managedObjectContext];
                [newLibrary setName:article.name];
                [newLibrary setSubname:article.subname];
                [newLibrary setLink:article.link];
                
                NSManagedObjectContext * moc = [self managedObjectContext];
                [moc insertObject:newLibrary];
                [moc processPendingChanges];
            } else {
                // modify the book
                Library * oldLibrary = array[0];
                BOOL modified = false;
                if (![oldLibrary.name isEqualToString:article.name]) {
                    oldLibrary.name = article.name;
                    modified=true;
                }
                if (![oldLibrary.subname isEqualToString:article.subname]) {
                    oldLibrary.subname = article.subname;
                    modified=true;
                }
                if (![oldLibrary.link isEqualToString:article.link]) {
                    oldLibrary.link = article.link;
                    modified=true;
                }
                if (modified) {
                    NSManagedObjectContext * moc = [self managedObjectContext];
                    [moc processPendingChanges];
                }
            }
            fetchRequest = nil;
            entity = nil;
        }
    }
    [self setLibraries:[[NSArray alloc] initWithArray:delegate.articlesList]];
    // end of update libraries list into store
    
    // create an operation to synchronize data
    NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchBooks) object:nil];
    
    // put the operation in the queue
    [_aQueue addOperation:operation];

}

-(void) synchBooks {
    NSLog(@"Loop over library list to get books");
    for (Article * library in  _libraries) {
        // concatenate the default url and the books' list page to obtain the real url
        NSString * urlText = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_cops_preference"];
        NSString * urlBase = [urlText stringByAppendingString:[library.link stringByAppendingString:@"&page=4"]];
        
        NSLog(@"urlBase: %@", urlBase);
        NSURL * url = [NetworkHelper smartURLForString:urlBase];
        
        // init the xml parser with the cops books' page url
        NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        LibraryParserDelegate * subDelegate = [[LibraryParserDelegate alloc] init];
        [parser setDelegate:subDelegate];
        [parser setShouldResolveExternalEntities:YES];
        
        // perform parsing
        if ([parser parse]) {
            int nbSec = 0;
            for (Article * art in subDelegate.articlesList) {
                nbSec++;
                NSLog(@"idArticle: %@", art.idArticle);
                NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchBookDetail:) object:art.link];
                // put the operation in the queue
                [_aQueue addOperation:operation];
                if (nbSec > 10) {
                    break;
                }
            }
        }
    }
    
    // send notification to inform books are loaded
    [[NSNotificationCenter defaultCenter]postNotificationName:LoadingBooksNotificationConstant object:self];
}

-(void) synchBookDetail:(id) argument {
    NSLog(@"Synchronization of data");
    
    // get the default url of cops application
    NSString * urlText = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_cops_preference"];
    
    // for each article, get the cops books page (list of books for the first given letter)
    NSString * articleLink = argument;
    NSString * urlBase = [urlText stringByAppendingString:articleLink];
    
    NSLog(@"urlBase: %@", urlBase);
    NSURL * url = [NetworkHelper smartURLForString:urlBase];
    
    // parse the cops books page to get books detail
    NSXMLParser * subParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    if(subParser) {
        BookParserDelegate * delegate = [[BookParserDelegate alloc] init];
        [subParser setDelegate:delegate];
        [subParser setShouldResolveExternalEntities:YES];
        if([subParser parse]) {
            NSLog(@"subParser OK");
            [self synchDataWithStore:delegate.articlesList];
        }
    } else {
        NSLog(@"No parsing.");
    }
    
}

-(void) synchDataWithStore:(id) argument {
    int nb=0;
    NSArray * lstArticles = argument;
    // loop over all the sections to insert book into managedObjectContext
    for (Article * art in lstArticles) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        NSNumber * idBook = [numberFormatter numberFromString:art.idArticle];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(idBook = %@)", idBook];
        numberFormatter = nil;
        idBook = nil;
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (array == nil)
        {
            // Deal with error...
        }
        
        if (array.count == 0) {
            // create the book
            NSLog(@"Creation of a new book.");
            
            Book *newBook = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_managedObjectContext];
            [newBook setIdBook:idBook];
            [newBook setTitle:art.name];
            [newBook setFirstLetter:[[art.name substringToIndex:1] capitalizedString]];
            [newBook setImgLink:art.imgLink];
            [newBook setLink:art.link];
            // Get the URL for the pathname passed to the function.
            NSURL *url = [NSURL URLWithString:art.image];
            // Create an image source from the URL.
            CGDataProviderRef provider = CGDataProviderCreateWithURL ((__bridge CFURLRef)url);
            NSData * data = (__bridge NSData *)(CGDataProviderCopyData(provider));
            CGDataProviderRelease(provider);
            [newBook setImage:data];
            [newBook setDownloadUrl:art.downloadUrl];
            [newBook setFormat:art.format];
            
            Author * author = [self getAuthor:art.author];
            [newBook setAuthor:author];
            
            NSManagedObjectContext * moc = [self managedObjectContext];
            [moc insertObject:newBook];
            [moc processPendingChanges];
        } else {
            // modify the book
            Book * oldBook = array[0];
            BOOL modified = false;
            if (![oldBook.title isEqualToString:art.name]) {
                oldBook.title = art.name;
                [oldBook setFirstLetter:[[art.name substringToIndex:1] capitalizedString]];
                modified=true;
            }
            if (![oldBook.imgLink isEqualToString:art.imgLink]) {
                oldBook.imgLink = art.imgLink;
                // Get the URL for the pathname passed to the function.
                NSURL *url = [NSURL URLWithString:art.image];
                // Create an image source from the URL.
                CGDataProviderRef provider = CGDataProviderCreateWithURL ((__bridge CFURLRef)url);
                NSData * data = (__bridge NSData *)(CGDataProviderCopyData(provider));
                CGDataProviderRelease(provider);
                [oldBook setImage:data];
                modified=true;
            }
            if (![oldBook.downloadUrl isEqualToString:art.downloadUrl]) {
                oldBook.downloadUrl = art.downloadUrl;
                modified=true;
            }
            if (![oldBook.format isEqualToString:art.format]) {
                oldBook.format = art.format;
                modified=true;
            }
            if (![[oldBook.author name] isEqualToString:art.author]) {
                Author * author = [self getAuthor:art.author];
                [author setName:art.author];
                [oldBook setAuthor:author];
                modified=true;
            }
            
            if (modified) {
                NSManagedObjectContext * moc = [self managedObjectContext];
                [moc processPendingChanges];
            }
        }
        fetchRequest = nil;
        entity = nil;
        
        nb++;
        if (nb > 20) {
            break;
        }
    }
}

-(Author *) getAuthor:(NSString *)name {
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Author" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(name = %@)", name];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    
    NSManagedObjectContext * moc = [self managedObjectContext];
    if (array.count == 0) {
        Author *newAuthor = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:_managedObjectContext];
        [newAuthor setName:name];
        [moc insertObject:newAuthor];
        
        return newAuthor;
    }else{
        Author * oldAuthor = array[0];
        return oldAuthor;
    }
}

@end
