//
//  MyProfile.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 17/08/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class MyProfile
 
 @brief This class contain informations of the user.
 
 @discussion It includes user profile, username or full name, email of ther user. Also it contais some another options for editing profile, logout and change password features.
 */
@interface MyProfile : UITableViewController <SlideNavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

/*!
 @property sampleTableView
 
 @brief This tableVIew property used for showing tableView.
 */
@property (weak, nonatomic) IBOutlet UITableView *sampleTableView;

/*!
 @property profileImage
 
 @brief This imageView property used to show user profile picture.
 */
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

/*!
 @property userName
 
 @brief This imageView property used to show user name
 */
@property (weak, nonatomic) IBOutlet UILabel *userName;

/*!
 @property userEmail
 
 @brief This imageView property used to show user email
 */
@property (weak, nonatomic) IBOutlet UILabel *userEmail;


/*!
 @property editProfileLabel
 
 @brief This label property used to an label as Edit profile and used as a button.
 */
@property (weak, nonatomic) IBOutlet UILabel *editProfileLabel;

/*!
 @property changePasswordLabel
 
 @brief This label property used to an label as Change Password and used as a button.
 */
@property (weak, nonatomic) IBOutlet UILabel *changePasswordLabel;


/*!
 @property logoutLabel
 
 @brief This label property used to an label as Logout  and used as a button.
 */
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;


@end
