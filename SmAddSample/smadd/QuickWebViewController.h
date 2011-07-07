//
//  QuickWebViewController.h
//
//  Created by sumy on 10/03/02.
//  Copyright 2010 sumyapp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuickWebViewController : UIViewController {
	IBOutlet UIWebView *webView;
	NSString *url;
}
- (IBAction)closeThisView;
- (IBAction)openSafari;
@property (readwrite, retain) NSString *url;
@end
