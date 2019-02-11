//
//  ChangePassword.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 26/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "ChangePassword.h"
#import "HexColors.h"
#import "GlobalVariables.h"
#import "Utils.h"
#import "Reachability.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "HexColors.h"
#import "SVProgressHUD.h"
#import "MyWebservices.h"
#import "AppConstanst.h"
#import "MyProfile.h"


@interface ChangePassword ()<RMessageProtocol,UITextViewDelegate>
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
}

@end

@implementation ChangePassword

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    self.title=NSLocalizedString(@"Change Password", nil);
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor hx_colorWithHexRGBAString:@"#70B1FF"]}];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    
//    UIButton *hideShow1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,20,20)];
//    [hideShow1 setImage:[UIImage imageNamed:@"show"]  forState:UIControlStateNormal];
//
//    UIButton *hideShow2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,20,20)];
//    [hideShow2 setImage:[UIImage imageNamed:@"show"]  forState:UIControlStateNormal];
//
//    UIButton *hideShow3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,20,20)];
//    [hideShow3 setImage:[UIImage imageNamed:@"show"]  forState:UIControlStateNormal];
    
    
//    self.oldpassword.secureTextEntry = YES;
//    self.newpassword.secureTextEntry = YES;
//    self.confirmpassword.secureTextEntry = YES;

    
//    self.oldpassword.rightView = hideShow1;
//    self.newpassword.rightView = hideShow2;
//    self.confirmpassword.rightView = hideShow3;
//
//    self.oldpassword.rightViewMode = UITextFieldViewModeAlways;
//    self.newpassword.rightViewMode = UITextFieldViewModeAlways;
//    self.confirmpassword.rightViewMode = UITextFieldViewModeAlways;
    
    
//    [hideShow1 addTarget:self action:@selector(hideShow1:) forControlEvents:UIControlEventTouchUpInside];
//    [hideShow2 addTarget:self action:@selector(hideShow2:) forControlEvents:UIControlEventTouchUpInside];
//    [hideShow3 addTarget:self action:@selector(hideShow3:) forControlEvents:UIControlEventTouchUpInside];
//
    
    
    
    //SVPROGRESSVIEW
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    self.navigationController.navigationBar.hidden = NO;
    [[self navigationController] setNavigationBarHidden:NO];
    
    _updateButtonOutlet.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
}


//- (void)hideShow1:(id)sender
//{
//
//    UIButton *hideShow = (UIButton *)self.oldpassword.rightView;
//    if (!self.oldpassword.secureTextEntry)
//    {
//        self.oldpassword.secureTextEntry = YES;
//        [hideShow setImage:[UIImage imageNamed:@"show"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        self.oldpassword.secureTextEntry = NO;
//        [hideShow setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
//    }
//    [self.oldpassword becomeFirstResponder];
//
//
//}
//
//- (void)hideShow2:(id)sender
//{
//
//    UIButton *hideShow = (UIButton *)self.newpassword.rightView;
//    if (!self.newpassword.secureTextEntry)
//    {
//        self.newpassword.secureTextEntry = YES;
//        [hideShow setImage:[UIImage imageNamed:@"show"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        self.newpassword.secureTextEntry = NO;
//        [hideShow setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
//    }
//    [self.newpassword becomeFirstResponder];
//
//
//}
//
//- (void)hideShow3:(id)sender
//{
//
//    UIButton *hideShow = (UIButton *)self.confirmpassword.rightView;
//    if (!self.confirmpassword.secureTextEntry)
//    {
//        self.confirmpassword.secureTextEntry = YES;
//        [hideShow setImage:[UIImage imageNamed:@"show"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        self.confirmpassword.secureTextEntry = NO;
//        [hideShow setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
//    }
//    [self.confirmpassword becomeFirstResponder];
//
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)updateButtonClicked:(id)sender {
    
    NSString *oldPass = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"password"]];
    
    NSString *newPass = [NSString stringWithFormat:@"%@",_newpassword.text];
    NSString *conPass = [NSString stringWithFormat:@"%@",_confirmpassword.text];
    
    if([_oldpassword.text length] == 0 && [_newpassword.text length] == 0 && [_confirmpassword.text length]==0){
        
        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Enter all field values."] sendViewController:self];
        
    }
    else if([_oldpassword.text length] != 0 && ([_newpassword.text length] == 0 || [_confirmpassword.text length] ==0)){
        
        if([_newpassword.text length] == 0 ){
            
            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Enter newpassword value."] sendViewController:self];
            
        }else if([_confirmpassword.text length] == 0 ){
            
            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Enter Confirm password value."] sendViewController:self];
        }
        
    }
    else if([_oldpassword.text length] != 0 && [_newpassword.text length] != 0 && [_confirmpassword.text length] ==0){
        
            
            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Enter Confirm password value."] sendViewController:self];
        
        
    }else if (![newPass isEqualToString:conPass]){
        
        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"New password value and Confirm value must be same. "] sendViewController:self];
    }
    
    else if(![_oldpassword.text isEqualToString:oldPass]){
        
        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Old Password is Incorrect"] sendViewController:self];
        
    }
    else{
        
        
        [self changePassMethodCalled];
    }
    
    
    

   
    
}

-(void)changePassMethodCalled{
    
    
  //  NSLog(@"Working fine....!");
    
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Error..!", nil)
                                          subtitle:NSLocalizedString(@"There is no Internet Connection...!", nil)
                                         iconImage:nil
                                              type:RMessageTypeError
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
        [SVProgressHUD dismiss];
        
    }else{
        
        //[[AppDelegate sharedAppdelegate] showProgressView];
        
        NSString *url =[NSString stringWithFormat:@"%@api/v2/helpdesk/user/change/password?api_key=%@&token=%@&old_password=%@&new_password=%@&confirm_password=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],_oldpassword.text,_newpassword.text,_confirmpassword.text];
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            
            
    
            [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                
                
                if (error || [msg containsString:@"Error"]) {
                    
                    [SVProgressHUD dismiss];
                    
                    if (msg) {
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                            
                        }
                        else if([msg isEqualToString:@"Error-402"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access denied - Either your role has been changed or your login credential has been changed."] sendViewController:self];
                        }
                        else if([msg isEqualToString:@"Error-422"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Enter the data for mandatory fields. "] sendViewController:self];
                            
                        }
                        else{
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                            NSLog(@"Error is : %@",msg);
                            
                        }
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-ChangePassword-Refresh-error == %@",error.localizedDescription);
                        [SVProgressHUD dismiss];
                    }
                    
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    // [self doneSubmitMethod];
                    NSLog(@"Thread--NO4-call-ChangePassword");
                    return;
                }
                
                
                if (json) {
                    NSLog(@"JSON-ChangePassword-%@",json);
                    
                    NSString *msg=[json objectForKey:@"message"];
                    
                    
                    
                    if([msg isEqualToString:@"Password updated successfully"]){
                        
                        if (self.navigationController.navigationBarHidden) {
                            [self.navigationController setNavigationBarHidden:NO];
                        }
                        
                        [RMessage showNotificationInViewController:self.navigationController
                                                             title:NSLocalizedString(@"Success", nil)
                                                          subtitle:NSLocalizedString(@"Password Updated successfully.", nil)
                                                         iconImage:nil
                                                              type:RMessageTypeSuccess
                                                    customTypeName:nil
                                                          duration:RMessageDurationAutomatic
                                                          callback:nil
                                                       buttonTitle:nil
                                                    buttonCallback:nil
                                                        atPosition:RMessagePositionNavBarOverlay
                                              canBeDismissedByUser:YES];
                        

                        
                        MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfileId"];
                        [self.navigationController pushViewController:myProfile animated:YES];
                        
                        
                    }else
                    {
                        [self->utils showAlertWithMessage:@"Something went wrong. Please try again later." sendViewController:self];
                        [SVProgressHUD dismiss];
                        
                    }
                    
                    
                }
                
                NSLog(@"Thread-NO5-ChangePassoword-closed");
                
            }];
        }@catch (NSException *exception)
        {
            [utils showAlertWithMessage:exception.name sendViewController:self];
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        @finally
        {
            NSLog( @" I am in doneSubmitButton method in Change Password ViewController" );
            
        }
        
    }
    

}




@end
