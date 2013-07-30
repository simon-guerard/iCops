//
//  ImageIOHelper.h
//  iCops
//
//  Created by Simon Guérard on 31/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

@interface ImageIOHelper : NSObject

+(CGImageRef) MyCreateCGImageFromUrl:(NSString *)urlCover;
+(CGImageRef) MyCreateCGImageFromData:(NSData*)data;

@end
