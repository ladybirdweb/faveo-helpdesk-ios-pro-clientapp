//
//  EditProfileViewController.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 26/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class EditProfileViewController
 
 @brief This class used to update informations of the user.
 
 @discussion It includes user profile, username or full name, email of ther user. Also it contais some another options for editing profile, logout and change password features.
 */
@interface EditProfileViewController : UITableViewController

/*!
 @property userNameTextView
 
 @brief This textView property used to add/update username
 */
@property (weak, nonatomic) IBOutlet UITextView *userNameTextView;

/*!
 @property firstNameTextView
 
 @brief This textView property used to add/update first name
 */
@property (weak, nonatomic) IBOutlet UITextView *firstNameTextView;

/*!
 @property lastNameTextView
 
 @brief This textView property used to add/update last name
 */
@property (weak, nonatomic) IBOutlet UITextView *lastNameTextView;

@property (weak, nonatomic) IBOutlet UIButton *updateButtonOutlet;

/*!
 @method updateButtonClicked
 
 @brief This is an button action method.
 
 @discussion After calling this method used details are updated.
 
 @code
 
 - (IBAction)updateButtonClicked:(id)sender;
 
 @endcode
 
 */
- (IBAction)updateButtonClicked:(id)sender;


@end
