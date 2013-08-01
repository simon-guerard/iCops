//
//  Library.h
//  iCops
//
//  Created by Simon Guérard on 01/08/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Library : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * subname;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) Book *books;

@end
