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

@interface BooksViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end



@implementation BooksViewController
{
    NSMutableArray *maListe;
}

//@synthesize fetchedResultsController=_fetchedResultsController, managedObjectContext=_managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    maListe = [NSMutableArray array];
    [maListe addObject:@"Paris"];
    [maListe addObject:@"Lyon"];
    [maListe addObject:@"Marseille"];
    [maListe addObject:@"Toulouse"];
    [maListe addObject:@"Nantes"];
    [maListe addObject:@"Nice"];
    [maListe addObject:@"Bordeaux"];
    [maListe addObject:@"Montpellier"];
    [maListe addObject:@"Rennes"];
    [maListe addObject:@"Lille"];
    [maListe addObject:@"Le Havre"];
    [maListe addObject:@"Reims"];
    [maListe addObject:@"Le Mans"];
    [maListe addObject:@"Dijon"];
    [maListe addObject:@"Grenoble"];
    [maListe addObject:@"Brest"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [maListe count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *BookIdentifier = @"BookIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BookIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BookIdentifier];
    
    // Configuration de la cellule
    NSString *cellValue = [maListe objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // indexPath.row
    // Create a view controller with the title as its
    // navigation title and push it.
    NSUInteger row = indexPath.row;
    if (row != NSNotFound)
    {
        // Create the view controller and initialize it with the
        // next level of data.
        /*
        BookDetailViewController *viewController = [[BookDetailViewController alloc]
                                            initWithTable:tableView andDataAtIndexPath:indexPath];
        [[self navigationController] pushViewController:viewController
                                               animated:YES];
         */
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowSelectedBook"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
       // Book *selectedBook = (Book *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        // Pass the selected book to the new view controller.
        BookDetailViewController *bookDetailViewController = (BookDetailViewController *)[segue destinationViewController];
        bookDetailViewController.bookName.text = @"toto";
    }
}

@end
