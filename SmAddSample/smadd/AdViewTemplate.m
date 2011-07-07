//
//  AdViewTemplate.m
//
//  Created by sumy on 11/02/06.
//  Copyright 2011 sumyapp. All rights reserved.
//

#import "AdViewTemplate.h"
#import "SmAddGlobal.h"

@implementation AdViewTemplate
@synthesize webView;
@synthesize url;
@synthesize bannerLinkUrlHost;
@synthesize delegate;
@synthesize controller;

- (id)initWithFrame:(CGRect)frame {
	SMADD_LOG_METHOD
    self = [super initWithFrame:frame];
    if (self) {
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		[webView setBackgroundColor:[UIColor clearColor]];
		[webView setOpaque:NO];		
		[self addSubview:webView];
	    [webView setDelegate:self];
    }
    return self;
}

- (void)start {
	SMADD_LOG_METHOD
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webViewDidStartLoad:(UIWebView *)web {
	SMADD_LOG_METHOD
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
	SMADD_LOG_METHOD
	NSString* str = [[request URL] absoluteString];
	NSRange range = [str rangeOfString:bannerLinkUrlHost];
	if (0 != range.length) {
		return YES;
	}
	
	QuickWebViewController* qwview = [[[QuickWebViewController alloc] initWithNibName:@"QuickWebViewController" bundle:nil] autorelease];
	qwview.url = str;
	[self.controller presentModalViewController:qwview animated:YES];
	return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)awebView {
	SMADD_LOG_METHOD
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if(self.delegate != nil){
		[self.delegate adViewTemplateDidLoadAd:self];
	} else {
		SMADD_LOG(@"webViewDidFinishLoad: EXCEPTION_ERROR");
	}
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
	SMADD_LOG_METHOD
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if(self.delegate != nil){
		[self.delegate adViewTemplate:self didFailToReceiveAdWithError:error];
	} else {
		SMADD_LOG(@"webView:didFailLoadWithError: EXCEPTION_ERROR");
	}
	
}

- (void)dealloc {
	SMADD_LOG_METHOD
	webView.delegate = nil;
	[webView release];
	[url release];
	[bannerLinkUrlHost release];
	self.delegate = nil;
    [super dealloc];
}
@end
