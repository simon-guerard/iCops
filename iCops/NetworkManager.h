//
//  NetworkManager.h
//  iCops
//
//  Created by Simon Guérard on 15/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (NSURL *)smartURLForString:(NSString *)str;

@end
