/*****************************************************************************
 *
 * FILE:	RootViewController.m
 * DESCRIPTION:	iOSDevSendai: Root view controller
 * DATE:	Thu, Dec  8 2011
 * UPDATED:	Fri, Dec  9 2011
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2011 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2011 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: RootViewController.m,v 1.5 2011/10/20 17:20:33 kouichi Exp $
 *
 *****************************************************************************/

#import "RootViewController.h"
#import "ImageView.h"

@interface RootViewController ()
@property (nonatomic,retain) ImageView *	imageView;
@property (nonatomic,retain) Filters *		filters;
@end

@interface RootViewController (Private)
-(void)showModalViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@implementation RootViewController

@synthesize	imageView	= _imageView;
@synthesize	filters		= _filters;

-(id)init
{
  self = [super init];
  if (self != nil) {
    self.title	= NSLocalizedString(@"iOSDevSendai", @"");
  }
  return self;
}

-(void)dealloc
{
  self.imageView = nil;
  self.filters	 = nil;
  [super dealloc];
}

-(void)didReceiveMemoryWarning
{
  /*
   * Invoke super's implementation to do the Right Thing,
   * but also release the input controller since we can do that.
   * In practice this is unlikely to be used in this application,
   * and it would be of little benefit,
   * but the principle is the important thing.
   */
  [super didReceiveMemoryWarning];
}

/*
 * Automatically invoked after -loadView
 * This is the preferred override point for doing additional setup
 * after -initWithNibName:bundle:
 */
-(void)viewDidLoad
{
  [super viewDidLoad];

  ImageView *	imageView;
  imageView = [[ImageView alloc]
		initWithImage:[UIImage imageNamed:@"castle.jpeg"]];
  [self.view addSubview:imageView];
  self.imageView = imageView;
  [imageView release];

  [self.view addSubview:[imageView slider]];

  UIBarButtonItem *	filterButton;
  filterButton = [[UIBarButtonItem alloc]
		  initWithTitle:NSLocalizedString(@"Filter", @"")
		  style:UIBarButtonItemStyleBordered
		  target:self
		  action:@selector(filterAction:)];
  self.navigationItem.rightBarButtonItem = filterButton;
  [filterButton release];

  Filters *	filters;
  filters = [[Filters alloc] init];
  [filters setDelegate:self];
  self.filters = filters;
  [filters release];

  // Set default filter
  self.title = [filters title];
  [self.imageView setFilter:[filters filter] withInputKey:[filters inputKey]];
}

-(void)viewDidUnload
{
  self.imageView = nil;
  self.filters	 = nil;
  [super viewDidUnload];
}

/*****************************************************************************/

#pragma mark UIBarButtonItem action
-(void)filterAction:(id)sender
{
  [self.filters showFiltersInView:self.view.window];
}

/*****************************************************************************/

#pragma mark FiltersDelegate
-(void)filtersDidSelectFilter:(Filters *)filters
{
  self.title = [filters title];
  [self.imageView setFilter:[filters filter] withInputKey:[filters inputKey]];
}

/*****************************************************************************/

-(void)showModalViewController:(UIViewController *)viewController
	animated:(BOOL)animated
{
  UINavigationController *	navigationController;
  navigationController = [[UINavigationController alloc]
			  initWithRootViewController:viewController];
  navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [self.navigationController presentViewController:viewController
			     animated:animated
			     completion:^(){}];
  [navigationController release];
}

@end
