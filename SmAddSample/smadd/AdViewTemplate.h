//
//  AdViewTemplate.h
//
//  Created by sumy on 11/02/06.
//  Copyright 2011 sumyapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickWebViewController.h"

@protocol AdViewTemplateDelegate;

@interface AdViewTemplate : UIView <UIWebViewDelegate> {
	UIWebView *webView;
	NSString *url;
	// example, sumyapp.com, not equal url's host
	NSString *bannerLinkUrlHost;
	
	// delegate
	id <AdViewTemplateDelegate> delegate;
	UIViewController *controller;
}
-(void)start;

@property (readwrite, retain) UIWebView *webView;
@property (readwrite, retain) NSString *url;
@property (readwrite, retain) NSString *bannerLinkUrlHost;
@property (nonatomic, assign) id <AdViewTemplateDelegate> delegate;
@property (nonatomic, assign) UIViewController *controller;
@end

@protocol AdViewTemplateDelegate
- (void)adViewTemplate:(AdViewTemplate *)adView didFailToReceiveAdWithError:(NSError *)error;
- (void)adViewTemplateDidLoadAd:(AdViewTemplate *)adView;
@end