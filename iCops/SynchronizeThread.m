//
//  SynchronizeThread.m
//  iCops
//
//  Created by Simon Guérard on 19/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import "SynchronizeThread.h"
#import "Article.h"
#import "NetworkHelper.h"

@interface SynchronizeThread ()

@property NSOperationQueue * aQueue;

@property NSMutableArray * sections;
@property Article * currentArticle;
@property NSString * currentPropName;
@property NSMutableString * currentStringValue;

@end

@implementation SynchronizeThread

static SynchronizeThread * sharedInstance;

@synthesize managedObjectContext=_managedObjectContext,aQueue=_aQueue,initData=_initData;
@synthesize currentPropName,currentStringValue,sections,currentArticle;

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
        NSTimer * timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(runSynchOperation) userInfo:nil repeats:YES];
        
        // attach the timer to the currentRunLoop
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
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
            NSLog(@"objects: %@", art.name);
            
            // for each article, get the cops books page (list of books for the first given letter)
            urlBase = [urlText stringByAppendingString:art.link];
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
        }
    }
    
    
    for (Article * art in sections) {
        if ([art.type isEqualToString:@"books"]) {
            
            NSEntityDescription * entityDesc = [[NSEntityDescription alloc] init];
            NSManagedObject * book = [[NSManagedObject alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:_managedObjectContext];
            [_managedObjectContext insertObject:book];
        }
    }
    
    // data has been initialize more than one time
    _initData=true;
}

#pragma mark - XML parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ( [elementName isEqualToString:@"section"]) {
        // sections is an NSMutableArray instance variable
        if (!sections)
            sections = [[NSMutableArray alloc] init];
        return;
    }
    
    if ( [elementName isEqualToString:@"article"] ) {
        // sections is an NSMutableArray instance variable
        currentArticle = [[Article alloc] init];
        NSString *typeArticle = [attributeDict objectForKey:@"class"];
        if (typeArticle)
            [currentArticle setType:typeArticle];
        return;
    }
    if ( [elementName isEqualToString:@"div"] ) {
        NSString *typeArticle = [attributeDict objectForKey:@"class"];
        if (typeArticle && ![currentArticle type])
            [currentArticle setType:typeArticle];
        return;
    }
    
    if ( [elementName isEqualToString:@"a"] ) {
        NSString *thisLink = [attributeDict objectForKey:@"href"];
        if (thisLink)
            [currentArticle setLink:thisLink];
        return;
    }
    if ( [elementName isEqualToString:@"h2"] ) {
        currentPropName=@"name";
        currentStringValue = nil;
        return;
    } else {
        currentPropName=@"";
    }
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
        [sections addObject:currentArticle];
        currentArticle = nil;
        return;
    }
    NSString *prop = [self currentPropName];
    
    // ... here ABMultiValue objects are dealt with ...
    
    if ( [prop isEqualToString:@"name"] ) {
        [currentArticle setName:currentStringValue];
    }
    currentStringValue = nil;
}


@end
