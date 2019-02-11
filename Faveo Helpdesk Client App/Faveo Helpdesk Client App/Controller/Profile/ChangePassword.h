//
//  ChangePassword.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 26/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class ChangePassword
 
 @brief This class used to change/update password of the user.
 
 @discussion It includes 3 textFields old password, new password and confirm password, after clicking on update button it will update the password of the user.
 */

@interface ChangePassword : UITableViewController

/*!
 @property oldpassword
 
 @brief This is an textField property
 
 @discussion It used to accept the value of old password
 */
@property (weak, nonatomic) IBOutlet UITextField *oldpassword;

/*!
 @property newpassword
 
 @brief This is an textField property
 
 @discussion It used to accept the value of new password
 */
@property (weak, nonatomic) IBOutlet UITextField *newpassword;

/*!
 @property confirmpassword
 
 @brief This is an textField property
 
 @discussion It used to accept the value of new password again
 */
@property (weak, nonatomic) IBOutlet UITextField *confirmpassword;

@property (weak, nonatomic) IBOutlet UIButton *updateButtonOutlet;

/*!
 @method updateButtonClicked
 
 @brief This is an button action method
 
 @discussion After calling this method user password will be updated.
 
 @code
 
- (IBAction)updateButtonClicked:(id)sender;
 
 @endcode
 
 */
- (IBAction)updateButtonClicked:(id)sender;


@end
