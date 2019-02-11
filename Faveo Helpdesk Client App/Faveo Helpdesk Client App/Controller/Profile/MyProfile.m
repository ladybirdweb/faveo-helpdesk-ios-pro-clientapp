//
//  MyProfile.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 17/08/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "MyProfile.h"
#import "GlobalVariables.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+Letters.h"
#import "ChangePassword.h"
#import "EditProfileViewController.h"
#import "SVProgressHUD.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "SlideNavigationController.h"

@interface MyProfile ()<RMessageProtocol>
{
    
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    Utils *utils;
    
}

@end

@implementation MyProfile

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"My Profile";
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    
    self.profileImage.layer.cornerRadius = 80 / 2.0;
    self.profileImage.layer.borderWidth = 1;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.layer.masksToBounds = YES;
    
    CGRect newFrame = CGRectMake( self.view.frame.origin.x, self.view.frame.origin.y, 80, 80);
    
    self.profileImage.frame = newFrame;
    
    
    
    if([[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".png"] )
    {
        [_profileImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"profile_pic"]]
                         placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    }else
    {
        NSString *name = [[userDefaults objectForKey:@"profile_name"] substringToIndex:2];
        [_profileImage setImageWithString:name color:nil ];
    }
    
    
    // Giving action to label
    _editProfileLabel.userInteractionEnabled = YES;
    _changePasswordLabel.userInteractionEnabled =YES;
    _logoutLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editUserProfileClicked)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changepasswordClicked)];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutClicked)];
    
    
    [_editProfileLabel addGestureRecognizer:tap1];
    [_changePasswordLabel addGestureRecognizer:tap2];
    [_logoutLabel addGestureRecognizer:tap3];
    
    //SVPROGRESSVIEW
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    
    [SVProgressHUD dismiss];
}


-(void)viewWillAppear:(BOOL)animated{
    
    self.userName.text = [NSString stringWithFormat:@"%@ %@",[userDefaults objectForKey:@"user_FirstName"],[userDefaults objectForKey:@"user_LasttName"]];
    
    
    self.userEmail.text= [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"user_email"]];
    
    
    self.navigationController.navigationBar.hidden = NO;
    [[self navigationController] setNavigationBarHidden:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SlideNavigationController Methods -
// This method used to show or hide slide navigation controller icon on navigation bar
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}


-(void)editUserProfileClicked{
    
    NSLog(@"Clicked");
    
    EditProfileViewController * editProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfileId"];
    
    [self.navigationController pushViewController:editProfile animated:YES];
    
    
    
}

-(void)changepasswordClicked
{
    
    NSLog(@"Clicked");
    
    ChangePassword * chnageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordId"];
    [self.navigationController pushViewController:chnageVC animated:YES];
    
}


-(void)logoutClicked{
    
    NSLog(@"Logout Clicked");
    
    [self wipeDataInLogout];
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    [RMessage showNotificationInViewController:self.navigationController
                                         title:NSLocalizedString(@" Faveo Helpdesk ", nil)
                                      subtitle:NSLocalizedString(@"You've logged out, successfully...!", nil)
                                     iconImage:nil
                                          type:RMessageTypeSuccess
                                customTypeName:nil
                                      duration:RMessageDurationAutomatic
                                      callback:nil
                                   buttonTitle:nil
                                buttonCallback:nil
                                    atPosition:RMessagePositionNavBarOverlay
                          canBeDismissedByUser:YES];
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    UIViewController *vc ;
    
    vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"loginId"];
    
    
     [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    

}

-(void)wipeDataInLogout{
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
    
}

@end
