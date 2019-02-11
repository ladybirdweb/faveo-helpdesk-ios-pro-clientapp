//
//  LoginViewController.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "OpenTicketsViewController.h"
#import "Utils.h"
#import "HexColors.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "GlobalVariables.h"
#import "SVProgressHUD.h"
#import "AppConstanst.h"
#import "Reachability.h"
#import "URLViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface LoginViewController () <UITextFieldDelegate,RMessageProtocol>
{
    Utils *utils;
    NSUserDefaults *userdefaults;
    NSString *errorMsg;
    NSString *baseURL;
    GlobalVariables *globalVariables;
    
}

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginButtonOutlet;

@end

@implementation LoginViewController

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
   
    // setting go button instead of next or donw on keyboard
   
    [_usernameTextField setReturnKeyType:UIReturnKeyDone];
    [_passwordTextField setReturnKeyType:UIReturnKeyDone];
    
    
    utils=[[Utils alloc]init];
    userdefaults=[NSUserDefaults standardUserDefaults];
    
    UIButton *hideShow = [[UIButton alloc] initWithFrame:CGRectMake(-30, 0,20,20)];
    [hideShow setImage:[UIImage imageNamed:@"show"]  forState:UIControlStateNormal];
    
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.rightView = hideShow;
    self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    [hideShow addTarget:self action:@selector(hideShow:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // to set black background color mask for Progress view
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    _loginButtonOutlet.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];

    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//This method is used to show and hide eye icon on password textField.
- (void)hideShow:(id)sender
{
    
    UIButton *hideShow = (UIButton *)self.passwordTextField.rightView;
    if (!self.passwordTextField.secureTextEntry)
    {
        self.passwordTextField.secureTextEntry = YES;
        [hideShow setImage:[UIImage imageNamed:@"show"] forState:UIControlStateNormal];
    }
    else
    {
        self.passwordTextField.secureTextEntry = NO;
        [hideShow setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
    }
    [self.passwordTextField becomeFirstResponder];
    
    
}

//Notifies the view controller that its view was added to a view hierarchy.
-(void)viewDidAppear:(BOOL)animated{
    [self.usernameTextField becomeFirstResponder];
    
}

//Asks the delegate if the text field should process the pressing of the return button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField== _usernameTextField){
        
        [_usernameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    }
    if(textField== _passwordTextField){
        
        [_passwordTextField resignFirstResponder];
    }
    return YES;
}


//After clicking on Login button this method called. This method will check username and password and returns the response. It uses authenticate API for validating credentials and role of an user.

- (IBAction)loginButtonClicked:(id)sender {
   
      //Testing code - for crashin the app
      //  [[Crashlytics sharedInstance] crash];
    [_passwordTextField resignFirstResponder];
    
    if (((self.usernameTextField.text.length==0 || self.passwordTextField.text.length==0)))
    {
        if (self.usernameTextField.text.length==0 && self.passwordTextField.text.length==0){
            [utils showAlertWithMessage:  NSLocalizedString(@"Please insert username & password", nil) sendViewController:self];
        }else if(self.usernameTextField.text.length==0 && self.passwordTextField.text.length!=0)
        {
            [utils showAlertWithMessage:NSLocalizedString(@"Please insert username", nil) sendViewController:self];
        }else if(self.usernameTextField.text.length!=0 && self.passwordTextField.text.length==0)
        {
            [utils showAlertWithMessage: NSLocalizedString(@"Please insert password", nil)sendViewController:self];
        }
    }
    else {
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
        {
            
            [RMessage
             showNotificationWithTitle:NSLocalizedString(@"Something failed", nil)
             subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check it!", nil)
             type:RMessageTypeError
             customTypeName:nil
             callback:nil];
            
            
        }else{
            
            [SVProgressHUD showWithStatus:@"Validating data"];
            
            
          //  globalVariables.appURL =appURL1;
            
            NSString *url=[NSString stringWithFormat:@"%@/api/v1/authenticate",@"https://support.faveohelpdesk.com"];
            
             [self->userdefaults synchronize];
            
            // NSString *params=[NSString string];
            NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:self.usernameTextField.text,@"username",self.passwordTextField.text,@"password",API_KEY,@"api_key",IP,@"ip",nil];
            
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
            [request setURL:[NSURL URLWithString:url]];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setTimeoutInterval:60];
            
            [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil]];
            [request setHTTPMethod:@"POST"];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
            
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    NSLog(@"dataTaskWithRequest error: %@", error);
                    return;
                }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    NSLog(@"Status code in Login : %ld",(long)statusCode);
                    NSLog(@"Status code in Login : %ld",(long)statusCode);
                    
                    if (statusCode != 200) {
                        
                        
                        if(statusCode == 404)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                           [SVProgressHUD dismiss];
                            [self->utils showAlertWithMessage:@"The requested URL was not found on this server." sendViewController:self];
                        }
                        
                        else if(statusCode == 405)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [SVProgressHUD dismiss];
                            [self->utils showAlertWithMessage:@"The request method is known by the server but has been disabled and cannot be used." sendViewController:self];
                        }
                        else if(statusCode == 500)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [SVProgressHUD dismiss];
                            [self->utils showAlertWithMessage:@"Internal Server Error. Something has gone wrong on the website's server." sendViewController:self];
                        }
                        
                    }
                    
                }
                
                NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                NSLog(@"Login Response is : %@",replyStr);
                
                NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSLog(@"JSON is : %@",jsonData);
                
                //main if 1
                if ([replyStr containsString:@"success"] && [replyStr containsString:@"message"] ) {
                    
                    
                    NSString *msg=[jsonData objectForKey:@"message"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                  
                    if([msg isEqualToString:@"Invalid credentials"])
                    {
                        [self->utils showAlertWithMessage:@"Invalid Credentials.Enter valid username or password" sendViewController:self];
                        [SVProgressHUD dismiss];
                    }
                    else if([msg isEqualToString:@"API disabled"])
                    {
                        [self->utils showAlertWithMessage:@"API is disabled in web, please enable it from Admin panel." sendViewController:self];
                        [SVProgressHUD dismiss];
                    }
                    else{
                        
                        [self->utils showAlertWithMessage:msg sendViewController:self];
                        [SVProgressHUD dismiss];
                        
                    }
                    
                  });
                }
                
                else         //success = true
                    if ([replyStr containsString:@"success"] && [replyStr containsString:@"data"] ) {
                        {
                            
                            NSDictionary *userDataDict=[jsonData objectForKey:@"data"];
                            NSString *tokenString=[NSString stringWithFormat:@"%@",[userDataDict objectForKey:@"token"]];
                            NSLog(@"Token is : %@",tokenString);
                            
                            [self->userdefaults setObject:[userDataDict objectForKey:@"token"] forKey:@"token"];
                            
                            NSDictionary *userDetailsDict=[userDataDict objectForKey:@"user"];
                            
                            NSString * userId=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"id"]];
                            
                            NSString * firstName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"first_name"]];
                            
                            NSString * lastName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"last_name"]];
                            
                            NSString * userName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"user_name"]];
                            
                            NSString * userProfilePic=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"profile_pic"]];
                            
                            NSString * userRole=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"role"]];
                            
                            NSString * email=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"email"]];
                            
                            [self->userdefaults setObject:email forKey:@"user_email"];
                            [self->userdefaults setObject:userName forKey:@"userName"];
                            [self->userdefaults setObject:firstName forKey:@"user_FirstName"];
                            [self->userdefaults setObject:lastName forKey:@"user_LasttName"];
                            
                            [self->userdefaults setObject:userId forKey:@"user_id"];
                            [self->userdefaults setObject:userProfilePic forKey:@"profile_pic"];
                            [self->userdefaults setObject:userRole forKey:@"role"];
                            
                            NSString *profileName;
                            if ([userName isEqualToString:@""]) {
                                profileName=userName;
                            }else{
                                profileName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
                            }
                            
                            
                            [self->userdefaults setObject:profileName forKey:@"profile_name"];
//                            [self->userdefaults setObject:@"https://www.support.ladybirdweb.com/" forKey:@"baseURL"];
                            
                            NSString *url2=[NSString stringWithFormat:@"%@/",@"https://support.faveohelpdesk.com"];
                            
                            [self->userdefaults setObject:url2 forKey:@"baseURL"];
                            
                            NSString *url3=[NSString stringWithFormat:@"%@/api/v1/",@"https://support.faveohelpdesk.com"];
                            
                             [self->userdefaults setObject:url3 forKey:@"companyURL"];

                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                
                            dispatch_async(dispatch_get_main_queue(), ^{
                              
                                [self->userdefaults setObject:self->_usernameTextField.text forKey:@"username"];
                                
                                [self->userdefaults setObject:self.passwordTextField.text forKey:@"password"];
                                
                            });
                            
                             });
                            
                            [self->userdefaults setBool:YES forKey:@"loginSuccess"];
                            [self->userdefaults synchronize];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if([userRole isEqualToString:@"user"]){
                                    
                                    OpenTicketsViewController *openTicketsVC=[self.storyboard  instantiateViewControllerWithIdentifier:@"openId"];
                                    [self.navigationController pushViewController:openTicketsVC animated:YES];
                                    //[self.navigationController popViewControllerAnimated:YES];
                                    [[self navigationController] setNavigationBarHidden:NO];
                                    
                                    
                                    if (self.navigationController.navigationBarHidden) {
                                        [self.navigationController setNavigationBarHidden:NO];
                                    }
                                    
                                    [RMessage showNotificationInViewController:self.navigationController
                                                                         title:NSLocalizedString(@"Welcome.",nil)
                                                                      subtitle:NSLocalizedString(@"You have logged in successfully.",nil)
                                                                     iconImage:nil
                                                                          type:RMessageTypeSuccess
                                                                customTypeName:nil
                                                                      duration:RMessageDurationAutomatic
                                                                      callback:nil
                                                                   buttonTitle:nil
                                                                buttonCallback:nil
                                                                    atPosition:RMessagePositionNavBarOverlay
                                                          canBeDismissedByUser:YES];
                                    
                                    [SVProgressHUD dismiss];
                                    
                                }else
                                {
                                    [self->utils showAlertWithMessage:@"Invalid entry for Agent or Admin. This app is used by users only." sendViewController:self];
                                    
                                    [self->userdefaults setBool:NO forKey:@"loginSuccess"];
                                    [self->userdefaults synchronize];
                                    
                                    [SVProgressHUD dismiss];
                                }
                            });
                            
                            
                        }   //end sucess=true if  here
                        
                        
                    }else
                    {
                        
                        
                        [self->utils showAlertWithMessage:@"Whoops! Something went Wrong! Please try again." sendViewController:self];
                        [SVProgressHUD dismiss];
                        
                    }
                
                
    
                
            }] resume];
            
        }
        
    }
    
    
}


//- (IBAction)troubleButton:(id)sender {
//    
//    URLViewController *urlView=[self.storyboard  instantiateViewControllerWithIdentifier:@"URLViewControllerId"];
//    
//    [self presentViewController:urlView animated:YES completion:nil];
//}
@end
