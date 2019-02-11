//
//  LeftMenuViewController.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "HexColors.h"
#import "AppConstanst.h"
#import "GlobalVariables.h"
#import "MyWebservices.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RMessage.h"
#import "RMessageView.h"
#import "Reachability.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "UIImageView+Letters.h"
#import "SlideNavigationController.h"
#import "SVProgressHUD.h"
#import "CreateTicketView.h"
#import "OpenTicketsViewController.h"
#import "ClosedTicketsViewController.h"
#import "MyProfile.h"
#import "AboutViewController.h"


@interface LeftMenuViewController ()<RMessageProtocol,UITableViewDelegate>{
    
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    Utils *utils;
    UIRefreshControl *refresh;
}


@end

@implementation LeftMenuViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Left-MENU");
    
    [self addUIRefresh];
    
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
   
    
    // to set black background color mask for Progress view
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    //Showing text on Progress view
    [SVProgressHUD showWithStatus:@"Loading view"];
    
   
 //   [self.tableView reloadData];
    [self update];
    [self getDependencies];
    [SVProgressHUD dismiss];
    
}

//This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view.
-(void)viewWillAppear:(BOOL)animated{
    
    [self.tableView reloadData];
    
}

// This method updates some vaues of user and ticket related data on Left-Menu View Controller
-(void)update{
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    

    if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"Invalid credentials"])
    {
        NSString *msg=@"";
        [utils showAlertWithMessage:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [SVProgressHUD dismiss];
    }
    else if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"API disabled"])
    {   NSString *msg=@"";
        [utils showAlertWithMessage:@"API is disabled in web, please enable it from Admin panel." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
       [SVProgressHUD dismiss];
    }
    else if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"Methon not allowed"] || [[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"urlchanged"])
    {   NSString *msg=@"";
        [utils showAlertWithMessage:@"Your HELPDESK URL or Your Login credentials were changed, contact to Admin and please log back in." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [SVProgressHUD dismiss];
    }
    

     NSLog(@"Email : %@",[userDefaults objectForKey:@"user_email"]);
    _user_emailLabel.text=[userDefaults objectForKey:@"user_email"];
    
    _user_nameLabel.text=[NSString stringWithFormat:@"%@ %@",[userDefaults objectForKey:@"user_FirstName"],[userDefaults objectForKey:@"user_LasttName"]];//
   
    
    if([[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".png"] )
    {
        [_user_profileImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"profile_pic"]]
                              placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    }else
    {
        NSString *name = [[userDefaults objectForKey:@"profile_name"] substringToIndex:1];
        [_user_profileImage setImageWithString:name color:nil ];
    }
    
  
    _user_profileImage.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    
    _user_profileImage.layer.cornerRadius = _user_profileImage.frame.size.height /2;
    _user_profileImage.layer.masksToBounds = YES;
    _user_profileImage.layer.borderWidth = 0;
    
    
    _view1.alpha=0.5;
    _view1.layer.cornerRadius = 20;
    _view1.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    _view2.alpha=0.5;
    _view2.layer.cornerRadius = 20;
    _view2.backgroundColor =  [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    

    
    NSInteger open =  [globalVariables.openTicketsCount integerValue];
    NSInteger closed = [globalVariables.closedTicketsCount integerValue];
  
    
    
    if(open>99){
        _opentickets_countLabel.text=@"99+";
    }else if(open<10){
        _opentickets_countLabel.text=[NSString stringWithFormat:@"0%ld",(long)open];
    }
    else{
        _opentickets_countLabel.text=@(open).stringValue; }
    
    if(closed>99){
        _closedtickets_countLabel.text=@"99+";
    }
    else if(closed<10){
        _closedtickets_countLabel.text=[NSString stringWithFormat:@"0%ld",(long)closed];
    }
    else
        _closedtickets_countLabel.text=@(closed).stringValue;
    
    
    [self.tableView reloadData];
  //  [[AppDelegate sharedAppdelegate] hideProgressView];
    
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    UIViewController *vc ;

    
    if(indexPath.section==0 && indexPath.row==0)
    {
         NSLog(@"create");
         vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"CreateTicketViewId"];
    }
    else if(indexPath.section==0 && indexPath.row==1)
    {
         NSLog(@"open");
         vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"openId"];
    }
    else if(indexPath.section==0 && indexPath.row==2)
    {
         NSLog(@"closed");
         vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"closedId"];
    }
    else if(indexPath.section==1 && indexPath.row==0)
    {
         NSLog(@"profile");
         vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MyProfileId"];
    }
    else if(indexPath.section==2 && indexPath.row==0)
    {
         NSLog(@"about");
         vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"aboutId"];
    }
    
    else if(indexPath.section==2 && indexPath.row==1)
    {
        //logout
         NSLog(@"logout");
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
        
        
                        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"loginId"];
        
        
        
    }
    
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
    

    
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
}


-(void)addUIRefresh{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *refreshing = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refreshing",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle,NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    refresh=[[UIRefreshControl alloc] init];
    refresh.tintColor=[UIColor whiteColor];
      refresh.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
   // refresh.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#BDBDBD"];
    refresh.attributedTitle =refreshing;
    [refresh addTarget:self action:@selector(reloadd) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refresh atIndex:0];
    
}

-(void)reloadd{
   
    [self update];
    [self.tableView reloadData];
    
    [refresh endRefreshing];
 //   [[AppDelegate sharedAppdelegate] hideProgressView];
}


-(void)showMessageForLogout:(NSString*)message sendViewController:(UIViewController *)viewController
{
    UIAlertController *alertController = [UIAlertController   alertControllerWithTitle:APP_NAME message:message  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction  actionWithTitle:@"Logout"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action)
                                   {
                                       
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
                                       
                                       UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                                bundle: nil];
                                       UIViewController *vc ;
                                       
                                       vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"Login"];
                                       
                                       [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                                                withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                                        andCompletion:nil];
                                       
                                   }];
    [alertController addAction:cancelAction];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
    
}


// This method used to get some values like Agents list, Ticket Status, Ticket counts, Ticket Source, SLA ..etc which are used in various places in project.
-(void)getDependencies{
    
    NSLog(@"Thread-NO1-getDependencies()-start");
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        
        //connection unavailable
        [SVProgressHUD dismiss];
        
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
        
        
        
    }else{
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/dependency?api_key=%@&ip=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"]];
        
        NSLog(@"URL is : %@",url);
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
                
                
                if (error || [msg containsString:@"Error"]) {
                    
                    [SVProgressHUD dismiss];
                    
                    if( [msg containsString:@"Error-401"])
                        
                    {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Your Credential Has been changed"] sendViewController:self];
                        
                        
                    }
                    else
                        if( [msg containsString:@"Error-429"])
                            
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"your request counts exceed our limit"] sendViewController:self];
                            
                            
                        }
                    
                        else if( [msg containsString:@"Error-403"])
                            
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials/Role has been changed. Contact to Admin and try to login again."] sendViewController:self];
                            
                            
                        }
                    
                        else if([msg isEqualToString:@"Error-404"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                            
                        }
                    
                    
                        else{
                            NSLog(@"Error message is %@",msg);
                            NSLog(@"Thread-NO4-getdependency-Refresh-error == %@",error.localizedDescription);
                            if([error.localizedDescription isEqualToString:@"The request timed out."])
                            {
                                [self->utils showAlertWithMessage:@"The request timed out" sendViewController:self];
                            }else
                                
                                [self->utils showAlertWithMessage:error.localizedDescription sendViewController:self];
                            [SVProgressHUD dismiss];
                            
                            return ;
                        }
                }
                
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self getDependencies];
                    NSLog(@"Thread--NO4-call-getDependecies");
                    return;
                }
                
                
                if (json) {
                    
                    //  NSLog(@"Thread-NO4-getDependencies-dependencyAPI--%@",json);
                  //  NSDictionary *resultDic = [json objectForKey:@"data"];
                    
                    self->globalVariables.dependencyDataDict = [json objectForKey:@"data"];
    
                   // self->ticketStatusArray=[resultDic objectForKey:@"status"];
                }
                NSLog(@"Thread-NO5-getDependencies-closed");
            }
             ];
        }@catch (NSException *exception)
        {
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            [utils showAlertWithMessage:exception.name sendViewController:self];
            [SVProgressHUD dismiss];
            return;
        }
        @finally
        {
            NSLog( @" I am in getDependencies method in Inbox ViewController" );
            
            
        }
    }
    
}

//This method will delete the cookies and removes data stored in NSUserDefaults
-(void)wipeDataInLogout{
    
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
    
    [self->userDefaults setObject:@"" forKey:@"msgFromRefreshToken"];
    
}


@end
