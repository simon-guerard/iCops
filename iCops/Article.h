//
//  Article.h
//  iCops
//
//  Created by Simon Guérard on 18/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * idArticle;
@property (nonatomic, retain) NSString * imgLink;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * downloadUrl;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * author;
@end
