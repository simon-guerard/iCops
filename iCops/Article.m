//
//  Article.m
//  iCops
//
//  Created by Simon Guérard on 18/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import "Article.h"

@implementation Article

@synthesize name,subname,link,type,idArticle,imgLink,image,downloadUrl,format,author;

- (BOOL)isEqual:(id)anObject {
    if (anObject == self) {
        return YES;
    } else if (!anObject || ![anObject isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToArticle:anObject];
}

- (BOOL)isEqualToArticle:(Article *)anArticle {
    if (self == anArticle)
        return YES;
    if (![(id)[self idArticle] isEqual:[anArticle idArticle]])
        return NO;
    if (![(id)[self name] isEqual:[anArticle name]])
        return NO;
    if (![(NSString *)[self type] isEqual:[anArticle type]])
        return NO;
    return YES;
}
@end
