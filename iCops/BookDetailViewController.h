//
//  BookDetailViewController.h
//  iCops
//
//  Created by Simon Guérard on 07/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <ImageIO/ImageIO.h>
#import "ImageIOHelper.h"
#import "Book.h"
#import "Author.h"
//@class Book;

@interface BookDetailViewController : UITableViewController

@property (nonatomic, strong) Book *book;

@end
