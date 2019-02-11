//
//  URLViewController.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 12/10/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "URLViewController.h"

@interface URLViewController ()

@end

@implementation URLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)cancelButton:(id)sender {
    
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)nextButtonClicked:(id)sender {
    
    
}

@end
