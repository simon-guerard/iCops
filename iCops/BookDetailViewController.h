//
//  BookDetailViewController.h
//  iCops
//
//  Created by Simon Guérard on 07/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book;

@interface BookDetailViewController : UITableViewController

@property (nonatomic, strong) Book *book;

@end
