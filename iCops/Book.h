//
//  Book.h
//  iCops
//
//  Created by Simon Guérard on 10/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>
// #import <CoreData/CoreData.h>

@interface Book : NSObject //NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;

@end
