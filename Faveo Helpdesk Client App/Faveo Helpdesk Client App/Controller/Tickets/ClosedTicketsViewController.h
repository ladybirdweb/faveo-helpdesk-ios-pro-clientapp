//
//  ClosedTicketsViewController.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class ClosedTicketsViewController
 
 @brief This class contains list of closed Tickets
 
 @discussion This class uses a table view and it gives a list of closed tickets. Every ticket contain ticket number, subject, profile picture and contact number of client. After clicking a particular ticket it will moves to conversation page. Here we will see conversation between Agent and client.
 */
@interface ClosedTicketsViewController : UIViewController<SlideNavigationControllerDelegate>

@end
