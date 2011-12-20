/*****************************************************************************
 *
 * FILE:	AdsBannerView.m
 * DESCRIPTION:	Ads management view class
 * DATE:	Fri, Dec  9 2011
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
 * $Id: AdsBannerView.m,v 1.2 2011/11/17 13:46:41 kouichi Exp $
 *
 *****************************************************************************/

#import "AdsBannerView.h"

#define	kAdBannerWidth	320.0
#define	kAdBannerHeight	50.0

@interface AdsBannerView ()
@property (nonatomic,retain) UIViewController *	rootViewController;
@property (nonatomic,retain) ADBannerView *	iAdBanner;
@end

@implementation AdsBannerView

@synthesize	rootViewController	= _rootViewController;
@synthesize	iAdBanner		= _iAdBanner;

-(id)initWithRootViewController:(UIViewController *)controller
{
  CGRect	frame;
  frame.origin.x	= 0.0;
  frame.origin.y	= controller.view.bounds.size.height - controller.navigationController.navigationBar.bounds.size.height - kAdBannerHeight;
  frame.size.width	= kAdBannerWidth;
  frame.size.height	= kAdBannerHeight;
  self = [super initWithFrame:frame];
  if (self != nil) {
    self.rootViewController	= controller;
    self.hidden	= YES;

    ADBannerView *	iAdBanner;
    iAdBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    iAdBanner.hidden	= YES;
    iAdBanner.delegate	= self;
    iAdBanner.autoresizingMask = UIViewAutoresizingFlexibleWidth
			       | UIViewAutoresizingFlexibleHeight
			       | UIViewAutoresizingFlexibleTopMargin;
    iAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    [self addSubview:iAdBanner];
    self.iAdBanner = iAdBanner;
    [iAdBanner release];
  }
  return self;
}

-(void)dealloc
{
  self.rootViewController = nil;
  self.iAdBanner.delegate = nil;
  self.iAdBanner = nil;
  [super dealloc];
}

/*****************************************************************************/

#pragma mark ADBannerViewDelegate
/*
 * This method is invoked each time a banner loads a new advertisement.
 * Once a banner has loaded an ad, it will display that ad until another ad is
 * available. The delegate might implement this method if it wished to defer
 * placing the banner in a view hierarchy until the banner has content to
 * display.
 */
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
  self.hidden = NO;

  CGRect	frame;
  frame.origin.x	= 0.0;
  frame.origin.y	= 0.0;
  frame.size.width	= kAdBannerWidth;
  frame.size.height	= kAdBannerHeight;

  [UIView animateWithDuration:0.2
	  animations:^{
	    banner.hidden = NO;
	    banner.frame  = frame;
	  }];
}

#pragma mark ADBannerViewDelegate
/*
 * This method will be invoked when an error has occurred attempting to get
 * advertisement content. The ADError enum lists the possible error codes.
 */
-(void)bannerView:(ADBannerView *)banner
	didFailToReceiveAdWithError:(NSError *)error
{
  self.hidden = YES;
  banner.hidden = YES;
#if	DEBUG
  NSLog(@"DEBUG[error] %@", [error localizedDescription]);
#endif	// DEBUG
}

#pragma mark ADBannerViewDelegate
/*
 * This message will be sent when the user taps on the banner and some action is
 * to be taken. Actions either display full screen content in a modal session
 * or take the user to a different application. The delegate may return NO
 * to block the action from taking place, but this should be avoided
 * if possible because most advertisements pay significantly more when the
 * action takes place and, over the longer term, repeatedly blocking actions
 * will decrease the ad inventory available to the application. Applications
 * may wish to pause video, audio, or other animated content while the
 * advertisement's action executes.
 */
-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner
	willLeaveApplication:(BOOL)willLeave
{
  if (willLeave) {
    return NO;
  }
  return YES;
}

#pragma mark ADBannerViewDelegate
/*
 * This message is sent when a modal action has completed and control is
 * returned to the application. Games, media playback, and other activities
 * that were paused in response to the beginning of the action should resume
 * at this point.
 */
-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
  self.hidden = YES;
  banner.hidden = YES;
}

@end
