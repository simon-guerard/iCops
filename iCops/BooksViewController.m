//
//  FirstViewController.m
//  iCops
//
//  Created by Simon Guérard on 07/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import "BooksViewController.h"
#import "BookDetailViewController.h"
#import "Book.h"
#import "SynchronizeThread.h"

@interface BooksViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSURLConnection * connection;

@end



@implementation BooksViewController

@synthesize fetchedResultsController=_fetchedResultsController, managedObjectContext=_managedObjectContext,connection=_connection;
@synthesize booksActivityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // test if data have been loaded
    [self.booksActivityIndicator startAnimating];
    if (![[SynchronizeThread sharedInstance:_managedObjectContext] isInitData]){
        // wait for the end of data loading. An event will be launch to performFetch
    } else {
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)viewWillAppear
{
    [self.tableView reloadData];
}


- (void)viewDidUnload
{
    // Release any properties that are loaded in viewDidLoad or can be recreated lazily.
    self.fetchedResultsController = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell to show the book's title
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = book.title;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *BookIdentifier = @"BookIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BookIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BookIdentifier];
    
    return cell;
}

#pragma mark -
#pragma mark Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    //    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"author" ascending:YES];
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstLetter" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:titleDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetter" cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    // Memory management.
    
    return _fetchedResultsController;
}


/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


#pragma mark - Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowSelectedBook"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Book *selectedBook = (Book *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        // Pass the selected book to the new view controller.
        BookDetailViewController *bookDetailViewController = (BookDetailViewController *)[segue destinationViewController];
        bookDetailViewController.book = selectedBook;
    }
}

- (IBAction)resfreshTable:(UIBarButtonItem *)sender {
    [[self fetchedResultsController] performFetch:nil];
    [self.tableView reloadData];
    if ([[SynchronizeThread sharedInstance:_managedObjectContext] initData]) {
        [booksActivityIndicator stopAnimating];
    }
}

@end
