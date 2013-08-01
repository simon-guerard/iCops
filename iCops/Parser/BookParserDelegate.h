//
//  BookParser.h
//  iCops
//
//  Created by Simon Guérard on 01/08/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"

@interface BookParserDelegate : NSObject<NSXMLParserDelegate>

@property NSMutableArray * articlesList;

@end
