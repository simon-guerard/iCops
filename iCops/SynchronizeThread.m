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
#import "NetworkHelper.h"

@interface SynchronizeThread ()

@property NSOperationQueue * aQueue;

@property NSMutableArray * sections;
@property Article * currentArticle;
@property NSString * currentPropName;
@property NSMutableString * currentStringValue;
@property BOOL downloadLink;
@property BOOL currentCover;
@property BOOL bookDetail;

-(void) synchData;

@end

@implementation SynchronizeThread

static SynchronizeThread * sharedInstance;

@synthesize managedObjectContext=_managedObjectContext,aQueue=_aQueue,initData=_initData;
@synthesize currentPropName,currentStringValue,sections,currentArticle,downloadLink,bookDetail,currentCover;

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
        _initData=false;
        
        // init a timer to run synchronization thread method all 15 seconds.
        NSTimer * timer = [NSTimer timerWithTimeInterval:1500 target:self selector:@selector(runSynchOperation) userInfo:nil repeats:YES];
        
        // attach the timer to the currentRunLoop
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        
        [self runSynchOperation];
    }
    return self;
}

-(Boolean) isInitData {
    return _initData;
}

#pragma mark - Synchronization operation

-(void) runSynchOperation {
    // create an operation to synchronize data
    NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchData) object:nil];
    
    // put the operation in the queue
    [_aQueue addOperation:operation];
}

-(void) synchData {
    NSLog(@"Synchronization of data");
    
    // get the default url of cops application
    NSString * urlText = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_cops_preference"];
    
    // concatenate the default url and the books page to obtain the real url
    NSString * urlBase = [urlText stringByAppendingString:@"/cops/index.php?page=4"];
    
    // for test
    //urlBase = @"http://localhost/~simonguerard/page4.xhtml";
    
    NSLog(@"urlBase: %@", urlBase);
    NSURL * url = [NetworkHelper smartURLForString:urlBase];
    
    // init the xml parser with the cops books' page url
    NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    
    // perform parsing
    if ([parser parse]) {
        // YEAAAAAAH
        
        // clone the sections array to loop into
        NSArray * cloneSections = [NSArray arrayWithArray:sections];
        for (Article * art in cloneSections) {
            
            if ([art.type isEqualToString:@"frontpage"]) {
                NSLog(@"objects: %@", art.name);
                
                // for each article, get the cops books page (list of books for the first given letter)
                urlBase = [urlText stringByAppendingString:art.link];
                
                // for test
                //urlBase = @"http://localhost/~simonguerard/page5-0.xhtml";
                
                NSLog(@"urlBase: %@", urlBase);
                url = [NetworkHelper smartURLForString:urlBase];
                
                // parse the cops books page to get books detail
                NSXMLParser * subParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
                if(subParser) {
                    [subParser setDelegate:self];
                    [subParser setShouldResolveExternalEntities:YES];
                    if([subParser parse])
                        NSLog(@"subParser OK");
                } else {
                    NSLog(@"No parsing.");
                }
                
                // for test
                //break;
            }
        }
    }
    
    // loop over all the sections to insert book into managedObjectContext
    for (Article * art in sections) {
        if ([art.type isEqualToString:@"books"]) {

            // Create the fetch request for the entity.
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            // Edit the entity name as appropriate.
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_managedObjectContext];
            [fetchRequest setEntity:entity];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            NSNumber * idBook = [numberFormatter numberFromString:art.idArticle];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"(idBook = %@)", idBook];
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
                [newBook setImage:art.image];
                [newBook setDownloadUrl:art.downloadUrl];
                [newBook setFormat:art.format];
                
                Author * author = [self getAuthor:art.author];
                [newBook setAuthor:author];

                NSManagedObjectContext * moc = [self managedObjectContext];
                [moc insertObject:newBook];

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
                    modified=true;
                }
                if (![oldBook.image isEqualToString:art.image]) {
                    oldBook.image = art.image;
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
        }
    }
    
    // data has been initialize more than one time
    _initData=true;
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

#pragma mark - XML parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ( [elementName isEqualToString:@"section"]) {
        // sections is an NSMutableArray instance variable
        if (!sections)
            sections = [[NSMutableArray alloc] init];
        return;
    }
    
    // create the current article and specify the type in case of 'books'
    if ( [elementName isEqualToString:@"article"] ) {
        currentArticle = [[Article alloc] init];
        NSString *typeArticle = [attributeDict objectForKey:@"class"];
        if (typeArticle)
            [currentArticle setType:typeArticle];
        return;
    }
    // get the article type in case of frontpage
    if (currentArticle &&  [elementName isEqualToString:@"div"] ) {
        NSString *typeArticle = [attributeDict objectForKey:@"class"];
        if (typeArticle && ![currentArticle type])
            [currentArticle setType:typeArticle];
        return;
    }
    
    // get the link to books list
    if (currentArticle && [elementName isEqualToString:@"a"] && [[currentArticle type] isEqualToString:@"frontpage"]) {
        NSString *thisLink = [attributeDict objectForKey:@"href"];
        if (thisLink)
            [currentArticle setLink:thisLink];
        return;
    }
    // get id to request book list
    if (currentArticle && [[currentArticle type] isEqualToString:@"frontpage"] && [elementName isEqualToString:@"h2"] ) {
        currentPropName=@"idArticle";
        currentStringValue = nil;
        return;
    }
    
    // specify if next link will be download link
    if (currentArticle && [[currentArticle type] isEqualToString:@"books"] && [elementName isEqualToString:@"h2"] ) {
        NSString *classLink = [attributeDict objectForKey:@"class"];
        if (classLink && [classLink isEqualToString:@"download"]) {
            downloadLink=true;
            return;
        }
    }

    // get the link to full image, to book detail or to download book
    if (currentArticle && [elementName isEqualToString:@"a"] && [[currentArticle type] isEqualToString:@"books"]) {
        NSString *classLink = [attributeDict objectForKey:@"class"];
        NSString *thisLink = [attributeDict objectForKey:@"href"];
        if (thisLink && classLink && [classLink isEqualToString:@"fancycover"]) {
            // full image link
            [currentArticle setImgLink:thisLink];
            currentCover=true;
            return;
        }
        if (thisLink && classLink && [classLink isEqualToString:@"fancydetail"]) {
            // link to book detail, specify that the future element give details of book.
            [currentArticle setLink:thisLink];
            bookDetail=true;
            return;
        }
        if(downloadLink) {
            // download url
            [currentArticle setDownloadUrl:thisLink];
            NSLog(@"download link : %@",thisLink);
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*download\\/([0-9]*)\\/.*" options:NSRegularExpressionCaseInsensitive error:&error];
            NSArray * result = [regex matchesInString:thisLink options:0 range:NSMakeRange(0, [thisLink length])];
            NSRange range = [result[0] rangeAtIndex:1];
            if (range.location != NSNotFound) {
                [currentArticle setIdArticle:[thisLink substringWithRange:range]];
            }
            downloadLink=false;
            return;
        }
    }
    
    // get book's cover
    if (currentArticle && currentCover && [elementName isEqualToString:@"img"]) {
        NSString *attrSrc = [attributeDict objectForKey:@"src"];
        if (attrSrc) {
            [currentArticle setImage:attrSrc];
            currentCover=false;
        }
        return;
    }
    
    // get book's title
    if (currentArticle && [[currentArticle type] isEqualToString:@"books"] && [elementName isEqualToString:@"span"] ) {
        NSString *classLink = [attributeDict objectForKey:@"class"];
        if (classLink && [classLink isEqualToString:@"st"]) {
            currentPropName=@"name";
            currentStringValue = nil;
            return;
        }
    }

    // get book's author
    if (currentArticle && [[currentArticle type] isEqualToString:@"books"] && [elementName isEqualToString:@"span"] ) {
        NSString *classLink = [attributeDict objectForKey:@"class"];
        if (classLink && [classLink isEqualToString:@"sa"]) {
            currentPropName=@"author";
            currentStringValue = nil;
            return;
        }
    }
    

    currentPropName=nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentStringValue) {
        // currentStringValue is an NSMutableString instance variable
        currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    [currentStringValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    // ignore root and empty elements
    if ( [elementName isEqualToString:@"section"])
        return;
    
    if ( [elementName isEqualToString:@"article"] ) {
        // addresses and currentPerson are instance variables
        if( ![sections containsObject:currentArticle]) {
            [sections addObject:currentArticle];
            currentArticle = nil;
            return;
        }
    }
    
    if (currentPropName && currentArticle) {
        [currentArticle setValue:currentStringValue forKey:[self currentPropName]];
        currentPropName=nil;
    }
    currentStringValue = nil;
}


@end