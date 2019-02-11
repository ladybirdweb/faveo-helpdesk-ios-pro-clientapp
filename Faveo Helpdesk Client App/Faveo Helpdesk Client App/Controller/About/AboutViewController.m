//
//  AboutViewController.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "AboutViewController.h"
#import "HexColors.h"


@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _versionNumberLabel.text=@"version: 1.0";
    _textview.editable=NO;
    [self setTitle:NSLocalizedString(@"About",nil)];
    _websiteButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
   
    self.navigationController.navigationBar.hidden = NO;
    [[self navigationController] setNavigationBarHidden:NO];

}



#pragma mark - SlideNavigationController Methods -
// This method used to show or hide slide navigation controller icon on navigation bar
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

// after clcking on button, it will redirect to Faveo Helpdesk website
- (IBAction)btnClicked:(id)sender {
    
  //  NSURL *url = [NSURL URLWithString:@"http://www.faveohelpdesk.com/"];
    
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"http://www.faveohelpdesk.com/"];
    [application openURL:url options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Opened url");
        }
    }];
}

@end
