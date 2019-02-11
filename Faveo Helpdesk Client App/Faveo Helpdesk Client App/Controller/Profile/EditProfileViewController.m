//
//  EditProfileViewController.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 26/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "EditProfileViewController.h"
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
#import "HexColors.h"


@interface EditProfileViewController ()<RMessageProtocol,UITextViewDelegate>
{
     Utils *utils;
     NSUserDefaults *userDefaults;
     GlobalVariables *globalVariables;
}
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //#70B1FF
     self.title=NSLocalizedString(@"Edit Profile", nil);
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor hx_colorWithHexRGBAString:@"#70B1FF"]}];
    
    //SVPROGRESSVIEW
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
   
    
//    /[userDefaults objectForKey:@"profile_name"]
    _userNameTextView.text = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"userName"]];
    _firstNameTextView.text = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"user_FirstName"]];
    _lastNameTextView.text = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"user_LasttName"]];
    
    NSLog(@"User Name : %@",[userDefaults objectForKey:@"userName"]);
    NSLog(@"First Name : %@",[userDefaults objectForKey:@"user_FirstName"]);
    NSLog(@"Last Name : %@",[userDefaults objectForKey:@"user_LasttName"]);
    
    
     _updateButtonOutlet.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
    self.navigationController.navigationBar.hidden = NO;
    [[self navigationController] setNavigationBarHidden:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)updateButtonClicked:(id)sender {
    
    
    if(([_userNameTextView.text length] == 0) || ([_firstNameTextView.text length] == 0) || ([_lastNameTextView.text length] == 0))
    {
        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Warning !", nil)
                                          subtitle:NSLocalizedString(@"Please fill mandatory fields.", nil)
                                         iconImage:nil
                                              type:RMessageTypeWarning
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
    }else
    {
    [self submit];
    }
}

-(void)submit
{
       [SVProgressHUD showWithStatus:@"Saving details"];
       [self updateMethodAPICall];
    
}



-(void)updateMethodAPICall
{
    
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
    
    NSString *url =[NSString stringWithFormat:@"%@api/v2/helpdesk/user/edit?api_key=%@&token=%@&user_name=%@&first_name=%@&last_name=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],_userNameTextView.text,_firstNameTextView.text,_lastNameTextView.text];
    @try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        
        [webservices callPATCHAPIWithAPIName:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            
            
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
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Enter the data for mandatory fields or Enter valid Email. "] sendViewController:self];
                        
                    }
                    else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is : %@",msg);
                        
                    }
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-EditCustomerDetails-Refresh-error == %@",error.localizedDescription);
                    [SVProgressHUD dismiss];
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
               // [self doneSubmitMethod];
                NSLog(@"Thread--NO4-call-EditCustomerDetails");
                return;
            }
            
            
            if (json) {
                NSLog(@"JSON-EditCustomerDetails-%@",json);
                
                NSDictionary *userData=[json objectForKey:@"data"];
                NSString *msg=[userData objectForKey:@"message"];
                
                
                if([msg isEqualToString:@"Updated successfully"]){
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Success", nil)
                                                      subtitle:NSLocalizedString(@"Details Updated successfully.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeSuccess
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                    
                   // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                        
                    [self->userDefaults setObject:self->_userNameTextView.text forKey:@"userName"];
                    [self->userDefaults setObject:self->_firstNameTextView.text forKey:@"user_FirstName"];
                    [self->userDefaults setObject:self->_lastNameTextView.text forKey:@"user_LasttName"];

                //  });
                    
                    MyProfile *myProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfileId"];
                    [self.navigationController pushViewController:myProfile animated:YES];
                    
            
                }else
                {
                    [self->utils showAlertWithMessage:@"Something went wrong. Please try again later." sendViewController:self];
                    [SVProgressHUD dismiss];
                    
                }
                
                
            }
            
            NSLog(@"Thread-NO5-EditCustomerDetails-closed");
            
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
        NSLog( @" I am in doneSubmitButton method in EditClientDetails ViewController" );
        
    }
    
}
    
}





@end
