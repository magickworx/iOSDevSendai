/*****************************************************************************
 *
 * FILE:	AdsBannerView.m
 * DESCRIPTION:	Ads management view class
 * DATE:	Fri, Dec  9 2011
 * UPDATED:	Sat, Feb 25 2012
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2011-2012 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2011-2012 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
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

NSString * const	kAdsBannerViewDidFailToReceiveAdNotification = @"AdsBannerViewDidFailToReceiveAdNotification";

#define	kAdBannerWidth	320.0
#define	kAdBannerHeight	50.0

#if	ENABLE_AD_MOB_BANNER
#define	MY_BANNER_UNIT_ID	@"SET_YOUR_ADMOB_PUBLISHER_IDENTIFIER"
#endif	// ENABLE_AD_MOB_BANNER

@interface AdsBannerView ()
@property (nonatomic,retain) UIViewController *	rootViewController;
@property (nonatomic,retain) ADBannerView *	iAdBanner;
#if	ENABLE_AD_MOB_BANNER
@property (nonatomic,retain) GADBannerView *	adMobBanner;
#endif	// ENABLE_AD_MOB_BANNER
@end

@interface AdsBannerView (Privates)
#if	ENABLE_AD_MOB_BANNER
-(void)switchAdMob;
#endif	// ENABLE_AD_MOB_BANNER
@end

@implementation AdsBannerView

@synthesize	rootViewController	= _rootViewController;
@synthesize	iAdBanner		= _iAdBanner;
#if	ENABLE_AD_MOB_BANNER
@synthesize	adMobBanner		= _adMobBanner;
#endif	// ENABLE_AD_MOB_BANNER

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

#if	ENABLE_AD_MOB_BANNER
    CGFloat	x = 0.0;
    CGFloat	y = 0.0;
    CGFloat	w = GAD_SIZE_320x50.width;
    CGFloat	h = GAD_SIZE_320x50.height;
    GADBannerView *	adMobBanner;
    adMobBanner = [[GADBannerView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    adMobBanner.hidden	 = YES;
    adMobBanner.delegate = self;
    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    adMobBanner.adUnitID = MY_BANNER_UNIT_ID;
    /*
     * Let the runtime know which UIViewController to restore after talking
     * the user wherever the ad goes and add it to the view hierachy.
     */
    adMobBanner.rootViewController = controller;
#if	ENABLE_AD_MOB_ONLY
    // Initiate a generic request to load it with an ad.
    GADRequest *	request = [GADRequest request];
#if	defined(DEBUG) || defined(ENABLE_DEVICE_DEBUG)
    request.testDevices = [NSArray arrayWithObjects:
	GAD_SIMULATOR_ID,	// Simulator
	[[UIDevice currentDevice] uniqueIdentifier],
	nil];
#endif	// DEBUG
    [adMobBanner loadRequest:request];
#endif	// ENABLE_AD_MOB_ONLY
    self.adMobBanner = adMobBanner;
    [adMobBanner release];
#endif	// ENABLE_AD_MOB_BANNER
  }
  return self;
}

-(void)dealloc
{
  self.rootViewController = nil;
  self.iAdBanner.delegate = nil;
  self.iAdBanner = nil;
#if	ENABLE_AD_MOB_BANNER
  self.adMobBanner.delegate = nil;
  self.adMobBanner = nil;
#endif	// ENABLE_AD_MOB_BANNER
  [super dealloc];
}

/*****************************************************************************/

#if	ENABLE_AD_MOB_BANNER
-(void)switchAdMob
{
  if (self.iAdBanner != nil) {
    self.iAdBanner.delegate = nil;
    [self.iAdBanner removeFromSuperview];
    [self addSubview:self.adMobBanner];
    self.iAdBanner = nil;

    // Initiate a generic request to load it with an ad.
    GADRequest *	request = [GADRequest request];
#if	defined(DEBUG) || defined(ENABLE_DEVICE_DEBUG)
    request.testDevices = [NSArray arrayWithObjects:
	GAD_SIMULATOR_ID,	// Simulator
	[[UIDevice currentDevice] uniqueIdentifier],
	nil];
#endif	// DEBUG
    [self.adMobBanner loadRequest:request];
  }
}
#endif	// ENABLE_AD_MOB_BANNER

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

  [[NSNotificationCenter defaultCenter]
    postNotificationName:kAdsBannerViewDidFailToReceiveAdNotification
    object:error];

#if	DEBUG
  NSLog(@"DEBUG[error] %@", [error localizedDescription]);
#endif	// DEBUG

#if	ENABLE_AD_MOB_BANNER
  [self switchAdMob];
#endif	// ENABLE_AD_MOB_BANNER
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

#if	ENABLE_AD_MOB_BANNER
  [self switchAdMob];
#endif	// ENABLE_AD_MOB_BANNER
}

/*****************************************************************************/

#if	ENABLE_AD_MOB_BANNER
#pragma mark GADBannerViewDelegate
/*
 * Sent when loadRequest: has succeeded, this is a good opportunity to add the
 * sender to the view hierarchy if it's been hidden unitl now.
 */
-(void)adViewDidReceiveAd:(GADBannerView *)banner
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

#pragma mark GADBannerViewDelegate
/*
 * Sent when loadRequest: has failed, typicaly because of network failure, an
 * application configuration error, or a lack of ad inventory.
 */
-(void)adView:(GADBannerView *)banner
	didFailToReceiveAdWithError:(GADRequestError *)error
{
  self.hidden = YES;
  banner.hidden = YES;

  [[NSNotificationCenter defaultCenter]
    postNotificationName:kAdsBannerViewDidFailToReceiveAdNotification
    object:error];
#if	DEBUG
  NSLog(@"DEBUG[AdMob] error=%@", error);
#endif	// DEBUG
}

#pragma mark GADBannerViewDelegate
/*
 * Sentimmediately before the user is presented with a full-screen ad UI in
 * response to their touching the sender. At this point you should pause any
 * animations, timers or other activities that assume user interaction and
 * save app state, much like on UIApplicationDidEnterBackgroundNotification.
 */
-(void)adViewWillPresentScreen:(GADBannerView *)banner
{
}

#pragma mark GADBannerViewDelegate
// Sent when the user has exited the sender's full-screen UI
- (void)adViewDidDismissScreen:(GADBannerView *)banner
{
}

#pragma mark GADBannerViewDelegate
/*
 * Sent immediately before sender's full-screen UI is dismissed, restoring
 * your app and the roow view controller. At this point you should restart any
 * foreground activities paused as part of adViewWillPresentScreen:.
 */
- (void)adViewWillDismissScreen:(GADBannerView *)banner
{
}

#pragma mark GADBannerViewDelegate
/*
 * Sent just before the application gets background or terminated as a result
 * of the user touching a Click-to-App-Store or Click-to-iTunes banner.
 * The normal UIApplicationDelegate notification like
 * applicationDidEnterBackground: arrive immediately before this.
 */
-(void)adViewWillLeaveApplication:(GADBannerView *)banner
{
}
#endif	// ENABLE_AD_MOB_BANNER

@end
