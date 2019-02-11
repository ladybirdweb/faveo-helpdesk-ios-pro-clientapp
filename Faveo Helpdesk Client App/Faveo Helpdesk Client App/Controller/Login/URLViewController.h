//
//  URLViewController.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 12/10/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

- (IBAction)cancelButton:(id)sender;

- (IBAction)nextButtonClicked:(id)sender;

@end
