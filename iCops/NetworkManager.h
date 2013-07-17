//
//  NetworkManager.h
//  iCops
//
//  Created by Simon Guérard on 15/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

@property (nonatomic, assign, readonly ) NSUInteger     networkOperationCount;  // observable

+ (NetworkManager *)sharedInstance;

- (NSURL *)smartURLForString:(NSString *)str;
- (NSString *)pathForTemporaryFile;
- (void)didStartNetworkOperation;
- (void)didStopNetworkOperation;
- (void)loadData:(NSString *) urlText;

@end
