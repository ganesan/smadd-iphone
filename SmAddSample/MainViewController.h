//
//  MainViewController.h
//  SmAddSample
//
//  Created by sumy on 11/07/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "SmAddViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
    SmAddViewController *smAddView;
    SmAddViewController *smAddView2;
}


- (IBAction)showInfo:(id)sender;
- (IBAction)addSmAddView:(id)sender;
- (IBAction)refreshSmAddView:(id)sender;
- (IBAction)removeSmAddView:(id)sender;
@end
