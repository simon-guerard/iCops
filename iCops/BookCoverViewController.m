//
//  BookCoverViewController.m
//  iCops
//
//  Created by Simon Guérard on 30/07/13.
//  Copyright (c) 2013 Simon Guérard. All rights reserved.
//

#import "BookCoverViewController.h"

@interface BookCoverViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *bookCover;

@end

@implementation BookCoverViewController

@synthesize urlCover=_urlCover,bookCover=_bookCover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGImageRef imageRef = ([ImageIOHelper MyCreateCGImageFromUrl:_urlCover]);
    _bookCover.image = [UIImage imageWithCGImage:imageRef];;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
