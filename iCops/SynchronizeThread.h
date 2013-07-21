//
//  SynchronizeThread.h
//  iCops
//
//  Created by Simon Guérard on 19/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SynchronizeThread : NSObject<NSXMLParserDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property Boolean initData;

+(SynchronizeThread *) sharedInstance:NSManagedObjectContext;

-(Boolean)isInitData;
@end
