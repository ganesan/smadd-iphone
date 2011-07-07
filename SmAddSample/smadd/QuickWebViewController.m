//
//  QuickWebViewController.m
//
//  Created by sumy on 10/03/02.
//  Copyright 2010 sumyapp. All rights reserved.
//

#import "QuickWebViewController.h"


@implementation QuickWebViewController
@synthesize url;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
- (IBAction)closeThisView{
	[self dismissModalViewControllerAnimated:YES];
}
- (IBAction)openSafari{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if (url == nil) {
		[self closeThisView];
		return;
	}
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];  
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *compURL = @"http://phobos.apple.com/WebObjects/";
	if(NSOrderedSame == [[[request URL] absoluteString] compare:compURL options:NSCaseInsensitiveSearch range:NSMakeRange(0,[compURL length])]) {
		[[UIApplication sharedApplication] openURL:[request URL]];
	}
	return YES;
}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
		return YES;
	}
	else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	//LOG(@"quickwebview dealloc");
	webView.delegate = nil;
	[webView release];
	[url release];
    [super dealloc];
}


@end
