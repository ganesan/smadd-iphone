//
//  MainViewController.m
//  SmAddSample
//
//  Created by sumy on 11/07/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

#pragma IBAction section
- (IBAction)addSmAddView:(id)sender {
    if(!smAddView) {
        smAddView = [[SmAddViewController alloc] initWithNibName:nil bundle:nil];
        [smAddView setIsAdInTop:NO];
        [smAddView setEnableAdNameSortByPriority:@"iad,housead"];
        [smAddView setSmaddAdServerUrl:@"http://public.sumyapp.com/adpriority_smaddtest1.html"];
        // 複数のSmAddViewを導入する場合、tagを付けてください。どのようなあたいでも構いません。
        [smAddView setTag:@"1"];
        [smAddView setFrame:CGRectMake(0, 400-44, 320, 60)];
        [self.view addSubview:smAddView.view];
        [smAddView startAd];
    }
    else if(!smAddView2) {
        smAddView2 = [[SmAddViewController alloc] initWithNibName:nil bundle:nil];
        [smAddView2 setIsAdInTop:YES];
        [smAddView2 setEnableAdNameSortByPriority:@"iad,housead"];
        [smAddView2 setSmaddAdServerUrl:@"http://public.sumyapp.com/adpriority_smaddtest2.html"];
        // 複数のSmAddViewを導入する場合、tagを付けてください。どのようなあたいでも構いません。
        [smAddView setTag:@"2"];
        [smAddView2 setFrame:CGRectMake(0, 0, 320, 60)];
        [self.view addSubview:smAddView2.view];
        [smAddView2 startAd];
    }
}

- (IBAction)refreshSmAddView:(id)sender {
    if(smAddView) {
        [smAddView stopAd];
        [smAddView startAd];
    }
    if(smAddView2) {
        [smAddView2 stopAd];
        [smAddView2 startAd];
    }
}

- (IBAction)removeSmAddView:(id)sender {
    if(smAddView2) {
        [smAddView2.view removeFromSuperview];
        [smAddView2 stopAd];
        [smAddView2 release];
        smAddView2 = nil;
    }
    else if(smAddView) {
        [smAddView.view removeFromSuperview];
        [smAddView stopAd];
        [smAddView release];
        smAddView = nil;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 国別に異なる広告設定を使用したい場合
    NSLog(@"currentLocale = %@", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]);
    if([[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"JP"]) {
        smAddView = [[SmAddViewController alloc] initWithNibName:nil bundle:nil
                                                       isAdInTop:NO
                                      enableAdNameSortByPriority:@"adlantis,admob,admaker,housead"];
    }
    else {
        smAddView = [[SmAddViewController alloc] initWithNibName:nil bundle:nil
                                                       isAdInTop:NO
                                      enableAdNameSortByPriority:@"iad,admob,iad,admaker,housead"];
    }
    [smAddView setFrame:CGRectMake(0, 400-44, 320, 60)];
    [self.view addSubview:smAddView.view];
    
    if (&UIApplicationDidEnterBackgroundNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillDisappear:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillAppear:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
    }
}

#pragma mark - View lifecycle
- (void)applicationWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [smAddView startAd];
    [smAddView2 startAd];
}

- (void)applicationWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    [smAddView stopAd];
    [smAddView2 stopAd];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [smAddView stopAd], [smAddView release];
    [smAddView2 stopAd],[smAddView2 release];
    [super dealloc];
}

@end
