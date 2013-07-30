//
//  BookDetailViewController.m
//  iCops
//
//  Created by Simon Guérard on 07/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import "BookDetailViewController.h"
#import "BookCoverViewController.h"

@interface BookDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *formatLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bookCover;

@end

@implementation BookDetailViewController

@synthesize titleLabel=_titleLabel, authorLabel=_authorLabel,formatLabel=_formatLabel,book=_book,bookCover=_bookCover;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // Configure the title, title bar, and table view.
    self.title = @"Info";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Redisplay the data.
    self.authorLabel.text = _book.author.name;
    self.titleLabel.text = _book.title;
    NSLog(@"book's format: %@", _book.format);
    self.formatLabel.text = _book.format;
    NSLog(@"book's image: %@", _book.image);
    CGImageRef imageRef = [ImageIOHelper MyCreateCGImageFromData:self.book.image];
    UIImage * image = [UIImage imageWithCGImage:imageRef];
    self.bookCover.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source methods

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"identifier%@",[segue identifier]);
    if ([[segue identifier] isEqualToString:@"ShowCoverBook"]) {
        
        // Pass the selected book to the new view controller.
        BookCoverViewController *bookCoverViewController = (BookCoverViewController *)[segue destinationViewController];
        bookCoverViewController.urlCover = _book.imgLink;
    }
}

@end
