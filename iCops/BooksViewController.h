//
//  BooksViewController.h
//  iCops
//
//  Created by Simon Guérard on 07/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BooksViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
