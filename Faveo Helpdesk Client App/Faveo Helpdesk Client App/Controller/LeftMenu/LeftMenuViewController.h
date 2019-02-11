//
//  LeftMenuViewController.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class LeftMenuViewController
 
 @brief This class contain menu driven view i.e displayed in table view format.
 
 @discussion This class contains and defines slide out design pattern.
 This class defines a table view, and that table view contain a list of menus like Create Ticket, Ticket List, Inbox Tickets, My Tickets, Unassigned Tickets, Closed Tickets, Trash Tickets, Client List and Logout.
 After Clicking on perticular menu it will goes to next ViewController (page).
 
 */
@interface LeftMenuViewController : UITableViewController


@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@property (strong, nonatomic) IBOutlet UITableView *tableViewOutlet;

/*!
 @property user_profileImage
 
 @brief This is an property name for declaring user Profile Image.
 */
@property (weak, nonatomic) IBOutlet UIImageView *user_profileImage;

/*!
 @property user_nameLabel
 
 @brief This is an property name for declaring user name.
 */
@property (weak, nonatomic) IBOutlet UILabel *user_nameLabel;

/*!
 @property user_emailLabel
 
 @brief This is an property name for declaring user email.
 */
@property (weak, nonatomic) IBOutlet UILabel *user_emailLabel;


/*!
 @property opentickets_countLabel
 
 @brief This is an property declared for showing count of open tickets.
 
 @discussion This is simply count. In open tickets, you will see the count that is an integer number so that we can easily understood that How many tockets are there in open tickets.
 
 @remark This shows an Integer number.
 */
@property (weak, nonatomic) IBOutlet UILabel *opentickets_countLabel;

/*!
 @property closedtickets_countLabel
 
 @brief This is an property declared for showing count of closed tickets.
 
 @discussion This is simply count. In closed tickets, you will see the count that is an integer number so that we can easily understood that How many tockets are there in closed tickets.
 
 @remark This shows an Integer number.
 */
@property (weak, nonatomic) IBOutlet UILabel *closedtickets_countLabel;

/*!
 @property view1, view2
 
 @brief This is an property used for creating view.
 
 @discussion They are used to create view for showing count label of the ticket.
 */
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

/*!
 @method update
 
 @brief This method used for updating the data into side-menu view.
 
 @discussion This method used to show data like ticket count, user profile, user name on side-menu when viewDidLoad method is called.
 
 @code
 
 -(void)update;
 
 @endcode
 
 */
-(void)update;

/*!
 @method reloadd
 
 @brief This method used for reloading the tableView
 
 @discussion Using this method, we can able to update the values in tableView.
 
 @code
 
 -(void)reloadd;
 
 @endcode
 
 */
-(void)reloadd;

/*!
 @method addUIRefresh
 
 @brief This method used to show refresh view behind the tableView.
 
 @discussion Using this method, we can able user can able to refresh the tableView so that the data inside the tableView will update while updating this values in tableView background it show an loader with text "Refreshing"
 
 @code
 
 -(void)addUIRefresh;
 
 @endcode
 
 */
-(void)addUIRefresh;
//-(void)wipeDataInLogout;


@end
