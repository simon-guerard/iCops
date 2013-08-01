//
//  BookParser.m
//  iCops
//
//  Created by Simon Guérard on 01/08/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import "BookParserDelegate.h"

@interface BookParserDelegate()

@property Article * currentArticle;
@property NSString * currentPropName;
@property NSMutableString * currentStringValue;
@property BOOL downloadLink;
@property BOOL currentCover;
@property BOOL bookDetail;

@end

@implementation BookParserDelegate

@synthesize currentPropName,currentStringValue,currentArticle,downloadLink,bookDetail,currentCover,articlesList;

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
    
    // specify if next link will be download link
    if (currentArticle && [elementName isEqualToString:@"h2"] ) {
        NSString *classLink = [attributeDict objectForKey:@"class"];
        if (classLink && [classLink isEqualToString:@"download"]) {
            downloadLink=true;
            return;
        }
    }
    
    // get the link to full image, to book detail or to download book
    if (currentArticle && [elementName isEqualToString:@"a"] ) {
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
            // get the default url of cops application
            NSString * urlText = [[NSUserDefaults standardUserDefaults] stringForKey:@"url_cops_preference"];
            NSString * urlImage = [[urlText stringByAppendingString:@"/cops/"] stringByAppendingString:attrSrc];
            
            [currentArticle setImage:urlImage];
            currentCover=false;
        }
        return;
    }
    
    // get book's title
    if (currentArticle && [elementName isEqualToString:@"span"] ) {
        NSString *classLink = [attributeDict objectForKey:@"class"];
        if (classLink && [classLink isEqualToString:@"st"]) {
            currentPropName=@"name";
            currentStringValue = nil;
            return;
        }
    }
    
    // get book's author
    if (currentArticle && [elementName isEqualToString:@"span"] ) {
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
        if([[currentArticle type] isEqualToString:@"books"] && ![articlesList containsObject:currentArticle]) {
            [articlesList addObject:currentArticle];
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
