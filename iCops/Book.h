//
//  Book.h
//  iCops
//
//  Created by Simon Guérard on 30/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * downloadUrl;
@property (nonatomic, retain) NSString * firstLetter;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSNumber * idBook;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imgLink;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Author *author;

@end
