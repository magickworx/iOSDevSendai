/*****************************************************************************
 *
 * FILE:	Filters.m
 * DESCRIPTION:	iOSDevSendai: Available CoreImage filter set class
 * DATE:	Thu, Dec  8 2011
 * UPDATED:	Tue, Dec 20 2011
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
 * $Id: Filters.m,v 1.2 2011/11/08 16:15:35 kouichi Exp $
 *
 *****************************************************************************/

#import "Filters.h"

@interface Filters ()
@property (nonatomic,retain) NSString *	title;
@property (nonatomic,retain) CIFilter *	filter;
@property (nonatomic,retain) NSString *	inputKey;
@end

@interface Filters (Private)
@end

@implementation Filters

@synthesize	delegate	= _delegate;
@synthesize	title		= _title;
@synthesize	filter		= _filter;
@synthesize	inputKey	= _inputKey;

-(id)init
{
  if ((self = [super init])) {
    self.delegate = nil;
    self.title	  = NSLocalizedString(@"Brightness", @"");
    self.filter   = [CIFilter filterWithName:@"CIColorControls"];
    self.inputKey = @"inputBrightness";
  }
  return self;
}

-(void)dealloc
{
  self.title	= nil;
  self.filter	= nil;
  self.inputKey	= nil;
  [super dealloc];
}

/*****************************************************************************/

enum {
  kButtonAdjustBrightness,	// 輝度
  kButtonAdjustContrast,	// 明暗
  kButtonAdjustSaturation,	// 彩度
  kButtonAdjustHue,		// 色調
  kButtonAdjustGammaAdjust,	// ガンマ
  kButtonGeometryStraighten,
  kButtonEffectSepiaTone,
  kNumberOfFilterButtons
};


-(void)showFiltersInView:(UIView *)view
{
  UIActionSheet *	actionSheet;
  actionSheet = [[UIActionSheet alloc]
		  initWithTitle:nil
		  delegate:self
		  cancelButtonTitle:nil
		  destructiveButtonTitle:nil
		  otherButtonTitles:nil];
  [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];

  [actionSheet addButtonWithTitle:NSLocalizedString(@"Brightness", @"")];
  [actionSheet addButtonWithTitle:NSLocalizedString(@"Contrast", @"")];
  [actionSheet addButtonWithTitle:NSLocalizedString(@"Saturation", @"")];
  [actionSheet addButtonWithTitle:NSLocalizedString(@"Hue", @"")];
  [actionSheet addButtonWithTitle:NSLocalizedString(@"Gamma", @"")];
  [actionSheet addButtonWithTitle:NSLocalizedString(@"Straighten", @"")];
  [actionSheet addButtonWithTitle:NSLocalizedString(@"SepiaTone", @"")];

  [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
  [actionSheet setCancelButtonIndex:([actionSheet numberOfButtons] - 1)];

  [actionSheet showInView:view];
  [actionSheet release];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet
	clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == actionSheet.cancelButtonIndex) { return; }

  switch (buttonIndex) {
    default:
    case kButtonAdjustBrightness:
      self.filter   = [CIFilter filterWithName:@"CIColorControls"];
      self.inputKey = @"inputBrightness";
      break;
    case kButtonAdjustContrast:
      self.filter   = [CIFilter filterWithName:@"CIColorControls"];
      self.inputKey = @"inputContrast";
      break;
    case kButtonAdjustSaturation:
      self.filter   = [CIFilter filterWithName:@"CIColorControls"];
      self.inputKey = @"inputSaturation";
      break;
    case kButtonAdjustHue:
      self.filter   = [CIFilter filterWithName:@"CIHueAdjust"];
      self.inputKey = @"inputAngle";
      break;
    case kButtonAdjustGammaAdjust:
      self.filter   = [CIFilter filterWithName:@"CIGammaAdjust"];
      self.inputKey = @"inputPower";
      break;
    case kButtonGeometryStraighten:
      self.filter   = [CIFilter filterWithName:@"CIStraightenFilter"];
      self.inputKey = @"inputAngle";
      break;
    case kButtonEffectSepiaTone:
      self.filter   = [CIFilter filterWithName:@"CISepiaTone"];
      self.inputKey = @"inputIntensity";
      break;
  }
  self.title = [actionSheet buttonTitleAtIndex:buttonIndex];

  if (_delegate &&
      [_delegate respondsToSelector:@selector(filtersDidSelectFilter:)]) {
    [_delegate filtersDidSelectFilter:self];
  }
}

@end
