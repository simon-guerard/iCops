//
//  LibraryParser.m
//  iCops
//
//  Created by Simon Guérard on 01/08/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import "LibraryParserDelegate.h"

@interface LibraryParserDelegate ()

@property Article * currentArticle;
@property NSString * currentPropName;
@property NSMutableString * currentStringValue;

@end

@implementation LibraryParserDelegate

@synthesize currentPropName,currentStringValue,currentArticle,articlesList;

#pragma mark - XML parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    // create the current article and specify the type in case of 'books'
    if ( [elementName isEqualToString:@"article"] ) {
        if (!articlesList) {
            articlesList = [[NSMutableArray alloc] init];
        }
        currentArticle = [[Article alloc] init];
        return;
    }
    
    // get the link to books list
    if (currentArticle && [elementName isEqualToString:@"a"]) {
        NSString *thisLink = [attributeDict objectForKey:@"href"];
        if (thisLink)
            [currentArticle setLink:thisLink];
        return;
    }
    // get id to request book list
    if (currentArticle && [elementName isEqualToString:@"h2"] ) {
        currentPropName=@"name";
        currentStringValue = nil;
        return;
    }
    
    // specify if next link will be download link
    if (currentArticle && [elementName isEqualToString:@"h4"] ) {
        currentPropName=@"subname";
        currentStringValue = nil;
        return;
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
    if ( [elementName isEqualToString:@"article"] ) {
        // addresses and currentPerson are instance variables
        if(![self.articlesList containsObject:currentArticle]) {
            [self.articlesList addObject:currentArticle];
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
