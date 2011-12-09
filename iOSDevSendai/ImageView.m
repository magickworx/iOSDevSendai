/*****************************************************************************
 *
 * FILE:	ImageView.m
 * DESCRIPTION:	iOSDevSendai: Filtered image view
 * DATE:	Thu, Dec  8 2011
 * UPDATED:	Thu, Dec  8 2011
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
 * $Id: ImageView.m,v 1.2 2011/11/08 16:15:35 kouichi Exp $
 *
 *****************************************************************************/

#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "ImageView.h"

#define	kMaxSizeWidth	320.0
#define	kMaxSizeHeight	320.0

@interface ImageView ()
@property (nonatomic,retain) UIImage *	image;
@property (nonatomic,retain) UILabel *	label;
@property (nonatomic,retain) CIImage *	filteredImage;
@property (nonatomic,retain) CIFilter *	filter;
@property (nonatomic,retain) NSString *	inputKey;
@end

@interface ImageView (Private)
-(void)reloadData;
-(void)applyFilter;
-(void)displayText:(NSString *)text;
@end

@implementation ImageView

@synthesize	slider		= _slider;
@synthesize	label		= _label;
@synthesize	image		= _image;
@synthesize	filteredImage	= _filteredImage;
@synthesize	filter		= _filter;
@synthesize	inputKey	= _inputKey;

-(id)initWithImage:(UIImage *)image
{
  CGRect	frame = CGRectMake(0.0, 0.0, kMaxSizeWidth, kMaxSizeHeight);

  self = [super initWithFrame:frame];
  if (self != nil) {
    self.image	= image;

    // create camera toolbar
    CGFloat	x = 0.0;
    CGFloat	y = frame.size.height;
    CGFloat	w = frame.size.width;
    CGFloat	h = 44.0;

    UISlider *	slider;
    slider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [slider setContinuous:YES];
    [slider setBackgroundColor:[UIColor clearColor]];
    [slider setMinimumValue:0.0];
    [slider setMaximumValue:100.0];
    [slider addTarget:self
	    action:@selector(sliderChangeAction:)
	    forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self
	    action:@selector(sliderStopAction:)
	    forControlEvents:UIControlEventTouchUpInside];
    _slider = slider;
    [_slider retain];
    [slider release];

    // create label for attention
    CGFloat	dw = self.frame.size.width  * 0.9;
    CGFloat	dh = self.frame.size.height * 0.5;
    CGFloat	dx = self.frame.origin.x + (self.frame.size.width  - dw) * 0.5;
    CGFloat	dy = self.frame.origin.y + (self.frame.size.height - dh) * 0.5;
    UILabel *	label;
    label = [[UILabel alloc] initWithFrame:CGRectMake(dx, dy, dw, dh)];
    [label setFont:[UIFont boldSystemFontOfSize:64.0]];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setAlpha:0.0];
    [self addSubview:label];
    self.label = label;
    [label release];

    [self reloadData];
  }
  return self;
}

-(void)dealloc
{
  [_slider release], _slider = nil;
  self.label	= nil;
  self.image	= nil;
  self.filteredImage	= nil;
  self.filter	= nil;
  self.inputKey	= nil;
  [super dealloc];
}

-(void)drawRect:(CGRect)rect
{
  if (self.filteredImage == nil) { return; }

  CALayer *	layer = [self layer];
  [layer setMasksToBounds:YES];
  [layer setBorderWidth:10.0];
  [layer setBorderColor:[UIColor whiteColor].CGColor];

  CGRect	frame = CGRectInset(rect, 10.0, 10.0);

  [[UIImage imageWithCIImage:self.filteredImage] drawInRect:frame];
}

/*****************************************************************************/

-(void)setFilter:(CIFilter *)filter withInputKey:(NSString *)inputKey
{
  self.filter	= filter;
  self.inputKey	= inputKey;

  NSDictionary *	attributes;
  attributes  = [[filter attributes] objectForKey:inputKey];
  [self.slider setMinimumValue:[[attributes objectForKey:kCIAttributeSliderMin] floatValue]];
  [self.slider setMaximumValue:[[attributes objectForKey:kCIAttributeSliderMax] floatValue]];
  [self.slider setValue:[[attributes objectForKey:kCIAttributeDefault] floatValue]];

  /*
   * -setDefaults instructs the filter to configure its parameters with their
   * specified default values.
   */
  [self.filter setDefaults];

  [self.filter setValue:[NSNumber numberWithFloat:[self.slider value]]
	       forKey:self.inputKey];

  [self reloadData];
}

/*****************************************************************************/

-(void)reloadData
{
  if (self.image == nil) { return; }

  CIImage *	image;
  image = [[CIImage alloc] initWithCGImage:self.image.CGImage options:nil];
  self.filteredImage = image;
  [image release];

  // Inform UIKit that we need to be redrawn.
  [self setNeedsDisplay];
}

-(void)applyFilter
{
  if (self.filter) {
    [self.filter setValue:self.filteredImage forKey:kCIInputImageKey];
    @try {
      self.filteredImage = self.filter.outputImage;
    }
    @catch (NSException * e) {
    }
  }

  [self setNeedsDisplay];
}

/*****************************************************************************/

#pragma mark UISlider action
-(void)sliderChangeAction:(UISlider *)sender
{
  [self displayText:[NSString stringWithFormat:@"%.1f", [sender value]]];
}

#pragma mark UISlider action
-(void)sliderStopAction:(UISlider *)sender
{
  if (self.inputKey != nil) {
    [self.filter setValue:[NSNumber numberWithFloat:[sender value]]
 		 forKey:self.inputKey];
    [self applyFilter];
  }
}

/*****************************************************************************/

-(void)displayText:(NSString *)text
{
  [self.label setAlpha:1.0];
  [self.label setText:text];

  [UIView animateWithDuration:1.2f
	  animations:^{
	    [self.label setAlpha:0.0f];
	  }
	  completion:^(BOOL finished) {
	  }];
}

@end
