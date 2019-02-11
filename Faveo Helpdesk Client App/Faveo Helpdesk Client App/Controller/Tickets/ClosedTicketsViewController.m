//
//  ClosedTicketsViewController.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "ClosedTicketsViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "GlobalVariables.h"
#import "LoadingTableViewCell.h"
#import "HexColors.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "FTPopOverMenu.h"
#import "UIImageView+Letters.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "TicketTableViewCell.h"
#import "TicketDetailViewController.h"
#import "TicketSearchViewController.h"


@interface ClosedTicketsViewController ()<RMessageProtocol>
{
    
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    NSDictionary *tempDict;
    
    int count1;
    
    NSMutableArray *selectedArray;
    
    NSArray *ticketStatusArray;
    NSMutableArray *statusArrayforChange;
    NSMutableArray *statusIdforChange;
    NSMutableArray *uniqueStatusNameArray;
    NSString *selectedStatusName;
    NSString *selectedStatusId;
    
    
    NSString *selectedIDs;
    
}


@property (weak, nonatomic) IBOutlet UITableView *sampleTableView;

@property (strong,nonatomic) NSIndexPath *selectedPath;
@property (nonatomic, strong) NSMutableArray *mutableArray;


@end

@implementation ClosedTicketsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:NSLocalizedString(@"Closed Tickets",nil)];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    
    _mutableArray=[[NSMutableArray alloc]init];
    
    statusArrayforChange = [[NSMutableArray alloc] init];
    statusIdforChange = [[NSMutableArray alloc] init];
    uniqueStatusNameArray = [[NSMutableArray alloc] init];
    
    //To set Gesture on Tableview for multiselection
    count1=0;
    selectedArray = [[NSMutableArray alloc] init];
    
    self.sampleTableView.allowsMultipleSelectionDuringEditing = true;
    UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(EditTableView:)];
    [lpGesture setMinimumPressDuration:1];
    [self.sampleTableView addGestureRecognizer:lpGesture];
    
    
    // to set black background color mask for Progress view
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    
    
    UIButton *moreButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"search1"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //    [moreButton setFrame:CGRectMake(46, 0, 32, 32)];
    [moreButton setFrame:CGRectMake(10, 0, 35, 35)];
    
    UIButton *more =  [UIButton buttonWithType:UIButtonTypeCustom];
    [more setImage:[UIImage imageNamed:@"moreButton"] forState:UIControlStateNormal];
    [more addTarget:self action:@selector(onNavButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    // [NotificationBtn setFrame:CGRectMake(10, 0, 32, 32)];
    [more setFrame:CGRectMake(46, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    [rightBarButtonItems addSubview:moreButton];
    [rightBarButtonItems addSubview:more];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    [self addUIRefresh];
    
    if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"Invalid credentials"])
    {
        NSString *msg=@"";
         [utils showAlertWithMessage:@"Access Denied.  Your credentials has been changed. Contact to Faveo Support and try to login again." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [self showMessageForLogout:@"Access Denied.  Your credentials has been changed. Contact to Faveo Support and try to login again." sendViewController:self];
        [SVProgressHUD dismiss];
        
    }
    else if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"API disabled"])
    {   NSString *msg=@"";
          [utils showAlertWithMessage:@"API is disabled in web, please contact to Faveo Support." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        
        [SVProgressHUD dismiss];
        
    }
    else if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"Methon not allowed"] || [[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"urlchanged"])
    {   NSString *msg=@"";
          [utils showAlertWithMessage:@"Your HELPDESK URL or Your Login credentials were changed, contact to Faveo Support and please log back in." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
          [self showMessageForLogout:@"Your HELPDESK URL or Your Login credentials were changed, contact to Faveo Support and please log back in." sendViewController:self];
        [SVProgressHUD dismiss];
        
    }
    else{
        
        [SVProgressHUD showWithStatus:@"Loading tickets"];
        [self reload];
        [self getDependencies];
        
    }
    
}


-(void)searchButtonClicked
{
    NSLog(@"Clicked");
    
    TicketSearchViewController * search=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketSearchViewControllerId"];
    [self.navigationController pushViewController:search animated:YES];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (self.selectedPath != nil) {
        [_sampleTableView selectRowAtIndexPath:self.selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    [[self navigationController] setNavigationBarHidden:NO];
    //[[self navigationController] setNavigationBarHidden:NO];
    
}

-(void)EditTableView:(UIGestureRecognizer*)gesture{
    [self.sampleTableView setEditing:YES animated:YES];
    
}


// Handling the tableview even we reload the tablview, edit view will not vanish even we scroll
- (void)reloadTableView
{
    NSArray *indexPaths = [self.sampleTableView indexPathsForSelectedRows];
    
    [self.sampleTableView reloadData];
    for (NSIndexPath *path in indexPaths) {
        [self.sampleTableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


// This method calls an API for getting tickets, it will returns an JSON which contains 10 records with ticket details.
-(void)reload{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [refresh endRefreshing];
        
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
        
        
        NSString * url= [NSString stringWithFormat:@"%@api/v1/helpdesk/user/ticket/list?token=%@&status=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],@"closed"];
        NSLog(@"URL is : %@",url);
        
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                
                NSLog(@"Reload Method Inbox Error is : %@",error );
                NSLog(@"Reload Method Inbox Message is : %@",msg );
                NSLog(@"Reload Method Inbox JSON is: %@",json);
                
                if (error || [msg containsString:@"Error"]) {
                    [self->refresh endRefreshing];
                    
                    
                    if (msg) {
                        
                        
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                            [SVProgressHUD dismiss];
                            
                        }
                        
                        else if([msg isEqualToString:@"Error-422"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Unprocessable Entity. Please try again later."] sendViewController:self];
                            [SVProgressHUD dismiss];
                        }
                        else if([msg isEqualToString:@"Error-404"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                            [SVProgressHUD dismiss];
                        }
                        else if([msg isEqualToString:@"Error-405"] ||[msg isEqualToString:@"405"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                            [SVProgressHUD dismiss];
                        }
                        else if([msg isEqualToString:@"Error-500"] ||[msg isEqualToString:@"500"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Internal Server Error.Something has gone wrong on the website's server."] sendViewController:self];
                            [SVProgressHUD dismiss];
                        }
                        
                        else{
                            
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                            [SVProgressHUD dismiss];
                        }
                        
                    }else if(error)  {
                        NSLog(@"Error is : %@",error);
                        
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                        [SVProgressHUD dismiss];
                    }
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    
                    [self reload];
                    NSLog(@"Thread--NO4-call-getInbox");
                    return;
                }
                
                if ([msg isEqualToString:@"tokenNotRefreshed"]) {
                    
                       [self showMessageForLogout:@"Your HELPDESK URL or Your Login credentials were changed, contact to Faveo Support and please log back in." sendViewController:self];
                    
                    [SVProgressHUD dismiss];
                    
                    return;
                }
                
                
                if (json) {
                    //NSError *error;
                    //  NSLog(@"Thread-NO4--getInboxAPI--%@",json);
                    NSDictionary *data1Dict=[json objectForKey:@"data"];
                    
                    if(![[data1Dict objectForKey:@"ticket"] isKindOfClass:[NSArray class]]){
                        
                        [self->utils showAlertWithMessage:@"Tickets are not available" sendViewController:self];
                        [SVProgressHUD dismiss];
                    }
                    else{
                        
                    
                    self->_mutableArray = [data1Dict objectForKey:@"ticket"];
                    
                    
                    NSString * count = [NSString stringWithFormat:@"%lu",(unsigned long)[self->_mutableArray count]];
                    self->globalVariables.closedTicketsCount =count;
                    
                    //                    self->_nextPageUrl =[data1Dict objectForKey:@"next_page_url"];
                    //                    self->_path1=[data1Dict objectForKey:@"path"];
                    //                    self->_currentPage=[[data1Dict objectForKey:@"current_page"] integerValue];
                    //                    self->_totalTickets=[[data1Dict objectForKey:@"total"] integerValue];
                    //                    self->_totalPages=[[data1Dict objectForKey:@"last_page"] integerValue];
                    
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self->refresh endRefreshing];
                            [self reloadTableView];
                            [SVProgressHUD dismiss];
                            
                        });
                    });
                
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                }
            }];
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
            NSLog( @" I am in reload method in Closed Tickets ViewController" );
            
            
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//This method asks the data source to return the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    
    if ([_mutableArray count] != 0)
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                = 1;
        tableView.backgroundView = nil;
        
    }
    else{
        
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        noDataLabel.text             = NSLocalizedString(@"",nil);
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        tableView.backgroundView = noDataLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
    }
    
    return numOfSections;
    
}

// This method returns the number of rows (table cells) in a specified section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    //    if (self.currentPage == self.totalPages
    //        || self.totalTickets == _mutableArray.count) {
    //        return _mutableArray.count;
    //    }
    
    return _mutableArray.count;
    
}

//
//// This method tells the delegate the table view is about to draw a cell for a particular row
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//
//     cell.selectionStyle=UITableViewCellSelectionStyleNone;
//      cell.selectionStyle=UITableViewCellSelectionStyleBlue;
//
//    if (indexPath.row == [_mutableArray count] - 1 ) {
//        NSLog(@"nextURL111  %@",_nextPageUrl);
//
//        if (( ![_nextPageUrl isEqual:[NSNull null]] ) && ( [_nextPageUrl length] != 0 )) {
//
//            [self loadMore];
//
//
//        }
//        else{
//
//            [RMessage showNotificationInViewController:self
//                                                 title:nil
//                                              subtitle:NSLocalizedString(@"All Caught Up", nil)
//                                             iconImage:nil
//                                                  type:RMessageTypeSuccess
//                                        customTypeName:nil
//                                              duration:RMessageDurationAutomatic
//                                              callback:nil
//                                           buttonTitle:nil
//                                        buttonCallback:nil
//                                            atPosition:RMessagePositionBottom
//                                  canBeDismissedByUser:YES];
//        }
//    }
//
//
//
//}



// This method asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if (indexPath.row == [_mutableArray count]) {
        
        LoadingTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LoadingCellID"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        }
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1];
        [activityIndicator startAnimating];
        return cell;
    }else{
        
        
        TicketTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"TableViewCellID"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
        
        // tempDict= [_mutableArray objectAtIndex:indexPath.row];
        
        
        @try{
            
            //            //last replier
            //            NSString *replyer12=[finaldic objectForKey:@"last_replier"];
            //            [Utils isEmpty:replyer12];
            //
            //            if  (![Utils isEmpty:replyer12] || ![replyer12 isEqualToString:@""])
            //            {
            //                if([replyer12 isEqualToString:@"client"])
            //                {
            //                    cell.viewMain.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#F2F2F2"];
            //                }else
            //                {
            //                    NSLog(@"I am in else condition..!");
            //                }
            //
            //            }else
            //            {
            //                NSLog(@"I am in else condition..!");
            //            }
            
            
            //ticket number
            NSString *ticketNumber=[finaldic objectForKey:@"ticket_number"];
            
            [Utils isEmpty:ticketNumber];
            
            
            if  (![Utils isEmpty:ticketNumber] && ![ticketNumber isEqualToString:@""])
            {
                cell.ticketIdLabel.text=ticketNumber;
            }
            else
            {
                cell.ticketIdLabel.text=NSLocalizedString(@"Not Available", nil);
            }
            
            
            //agent info
            NSDictionary *assigneeDict=[finaldic objectForKey:@"assignee"];
            
            if([NSNull null] != [finaldic objectForKey:@"assignee"]) {
                
                NSString *assigneeFirstName= [assigneeDict objectForKey:@"first_name"];
                NSString *assigneeLaststName= [assigneeDict objectForKey:@"last_name"];
                NSString *assigneeUserName= [assigneeDict objectForKey:@"user_name"];
                
                [Utils isEmpty:assigneeFirstName];
                [Utils isEmpty:assigneeLaststName];
                [Utils isEmpty:assigneeUserName];
                
                if (![Utils isEmpty:assigneeFirstName] || ![Utils isEmpty:assigneeLaststName])
                {
                    if  (![Utils isEmpty:assigneeFirstName] && ![Utils isEmpty:assigneeLaststName])
                    {
                        cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",assigneeFirstName,assigneeLaststName];
                    }
                    else
                    {
                        cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",assigneeFirstName,assigneeLaststName];
                    }
                }  else if(![Utils isEmpty:assigneeUserName])
                {
                    cell.agentLabel.text= assigneeUserName;
                }
                
                
            }
            else {
                
                cell.agentLabel.text= NSLocalizedString(@"Unassigned", nil);
                
            }
            
            
            
            //ticket owner/customer info
            
            NSDictionary *customerDict=[finaldic objectForKey:@"from"];
            
            NSString *fname= [customerDict objectForKey:@"first_name"];
            NSString *lname= [customerDict objectForKey:@"last_name"];
            NSString*userName=[customerDict objectForKey:@"user_name"];
            
            [Utils isEmpty:fname];
            [Utils isEmpty:lname];
            [Utils isEmpty:userName];
            
            
            if  (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
            {
                if (![Utils isEmpty:fname] && ![Utils isEmpty:lname])
                {   cell.mailIdLabel.text=[NSString stringWithFormat:@"%@ %@",fname,lname];
                }
                else{
                    cell.mailIdLabel.text=[NSString stringWithFormat:@"%@ %@",fname,lname];
                }
            }
            else if(![Utils isEmpty:userName])
            {
                cell.mailIdLabel.text=userName;
            }
            else
            {
                cell.mailIdLabel.text=NSLocalizedString(@"Not Available", nil);
            }
            
            
            //            //Image view
            //            if([[customerDict objectForKey:@"profile_pic"] hasSuffix:@"system.png"] || [[customerDict objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[customerDict objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[customerDict objectForKey:@"profile_pic"] hasSuffix:@".png"] )
            //            {
            //                [cell setUserProfileimage:[customerDict objectForKey:@"profile_pic"]];
            //            }
            //            else if(![Utils isEmpty:fname])
            //            {
            //                [cell.profilePicView setImageWithString:fname color:nil ];
            //            }
            //            else
            //            {
            //                [cell.profilePicView setImageWithString:userName color:nil ];
            //            }
            
            if([[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".png"] )
            {
                [cell setUserProfileimage:[userDefaults objectForKey:@"profile_pic"]];
                
            }else
            {
                [cell.profilePicView setImageWithString:[userDefaults objectForKey:@"profile_name"] color:nil ];
            }
            
            
            //updated time of ticket
            cell.timeStampLabel.text=[utils getLocalDateTimeFromUTC:[finaldic objectForKey:@"updated_at"]];
            
            
        } @catch (NSException *exception)
        {
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            [utils showAlertWithMessage:exception.name sendViewController:self];
            // return;
        }
        @finally
        {
            NSLog( @" I am in cellForRowAtIndexPath method in Leftmenu ViewController" );
            
        }
        // ______________________________________________________________________________________________________
        ////////////////for UTF-8 data encoding ///////
        //   cell.ticketSubLabel.text=[finaldic objectForKey:@"title"];
        
        
        
        // NSString *encodedString = @"=?UTF-8?Q?Re:_Robin_-_Implementing_Faveo_H?= =?UTF-8?Q?elp_Desk._Let=E2=80=99s_get_you_started.?=";
        
        
        
        
        
        NSString *encodedString =[finaldic objectForKey:@"title"];
        
        //   NSString *encodedString =@"Sample Ticket Titile";
        
        [Utils isEmpty:encodedString];
        
        if  ([Utils isEmpty:encodedString]){
            cell.ticketSubLabel.text=@"No Title";
        }
        else
        {
            
            NSMutableString *decodedString = [[NSMutableString alloc] init];
            
            if ([encodedString hasPrefix:@"=?UTF-8?Q?"] || [encodedString hasSuffix:@"?="])
            {
                NSScanner *scanner = [NSScanner scannerWithString:encodedString];
                NSString *buf = nil;
                //  NSMutableString *decodedString = [[NSMutableString alloc] init];
                
                while ([scanner scanString:@"=?UTF-8?Q?" intoString:NULL]
                       || ([scanner scanUpToString:@"=?UTF-8?Q?" intoString:&buf] && [scanner scanString:@"=?UTF-8?Q?" intoString:NULL])) {
                    if (buf != nil) {
                        [decodedString appendString:buf];
                    }
                    
                    buf = nil;
                    
                    NSString *encodedRange;
                    
                    if (![scanner scanUpToString:@"?=" intoString:&encodedRange]) {
                        break; // Invalid encoding
                    }
                    
                    [scanner scanString:@"?=" intoString:NULL]; // Skip the terminating "?="
                    
                    // Decode the encoded portion (naively using UTF-8 and assuming it really is Q encoded)
                    // I'm doing this really naively, but it should work
                    
                    // Firstly I'm encoding % signs so I can cheat and turn this into a URL-encoded string, which NSString can decode
                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"%" withString:@"=25"];
                    
                    // Turn this into a URL-encoded string
                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"=" withString:@"%"];
                    
                    
                    // Remove the underscores
                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    
                    // [decodedString appendString:[encodedRange stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    NSString *str1= [encodedRange stringByRemovingPercentEncoding];
                    [decodedString appendString:str1];
                    
                    
                }
                
                NSLog(@"Decoded string = %@", decodedString);
                
                //   cell.ticketSubLabel.text= decodedString; //countthread
                cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",decodedString,[finaldic objectForKey:@"thread_count"]];
            }
            else{
                
                // cell.ticketSubLabel.text= encodedString;
                cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",encodedString,[finaldic objectForKey:@"thread_count"]];
                
            }
            
        }
        ///////////////////////////////////////////////////
        //____________________________________________________________________________________________________
        
        
        // [cell setUserProfileimage:[finaldic objectForKey:@"profile_pic"]];
        @try{
            
            
            if ( ( ![[finaldic objectForKey:@"status_name"] isEqual:[NSNull null]] ) && ( [[finaldic objectForKey:@"status_name"] length] != 0 ) ) {
                
                if ([[finaldic objectForKey:@"status_name"] isEqualToString:@"Halt_SLA"]) {
                    
                    [cell.overDueLabel setHidden:YES];
                    [cell.today setHidden:YES];
                }
                else
                {
                    if ( ( ![[finaldic objectForKey:@"duedate"] isEqual:[NSNull null]] ) && ( [[finaldic objectForKey:@"duedate"] length] != 0 ) ) {
                        
                        if([utils compareDates:[finaldic objectForKey:@"duedate"]]){
                            [cell.overDueLabel setHidden:NO];
                            [cell.today setHidden:YES];
                        }else
                        {
                            [cell.overDueLabel setHidden:YES];
                            [cell.today setHidden:NO];
                        }
                        
                    }
                    
                }
            }
            
            
            
            
            NSString * source1=[finaldic objectForKey:@"source_name"];
            
            if([source1 isEqualToString:@"web"] || [source1 isEqualToString:@"Web"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"internert"];
            }else  if([source1 isEqualToString:@"email"] ||[source1 isEqualToString:@"Email"] )
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"agentORmail"];
            }else  if([source1 isEqualToString:@"agent"] || [source1 isEqualToString:@"Agent"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"agentORmail"];
            }else  if([source1 isEqualToString:@"facebook"] || [source1 isEqualToString:@"Facebook"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"fb"];
            }else  if([source1 isEqualToString:@"twitter"] || [source1 isEqualToString:@"Twitter"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"twitter"];
            }else  if([source1 isEqualToString:@"call"] || [source1 isEqualToString:@"Call"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"call"];
            }else if([source1 isEqualToString:@"chat"] || [source1 isEqualToString:@"Chat"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"chat"];
            }
            
            
            
            //  collaborator_count_relation
            NSString *cc= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"collaborator_count"]];  //collaborator_count
            NSString *attachment1= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"attachment_count"]];
            //countcollaborator
            
            NSLog(@"CC is %@ named",cc);
            NSLog(@"CC is %@ named",cc);
            NSLog(@"CC is %@ named",cc);
            //
            NSLog(@"attachment is %@ named",attachment1);
            NSLog(@"attachment is %@ named",attachment1);
            
            
            if(![attachment1 isEqualToString:@"0"])
            {
                
                cell.ccImgView.image=[UIImage imageNamed:@"attach"];
                
                
            }
            
//            if(![cc isEqualToString:@"<null>"])
//            {
//                cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
//                
//            }
//            
//            if(![attachment1 isEqualToString:@"0"])
//            {
//                if([cc isEqualToString:@"<null>"])
//                {
//                    cell.ccImgView.image=[UIImage imageNamed:@"attach"];
//                }else
//                {
//                    cell.attachImgView.image=[UIImage imageNamed:@"attach"];
//                    
//                }
//                
//            }
            
            
            
            
            //priority color
            // NSDictionary *priorityDict=[finaldic objectForKey:@"priority_color"];
            cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:[finaldic objectForKey:@"priority_color"]] CGColor];
            
            
            
        }@catch (NSException *exception)
        {
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            [utils showAlertWithMessage:exception.name sendViewController:self];
            //return;
        }
        @finally
        {
            NSLog( @" I am in cellForAtIndexPath method in Inobx ViewController" );
            
        }
        
        // }
        return cell;
    }
    
}



// This method tells the delegate that the specified row is now selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    self.selectedPath = indexPath;
    
    NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
    
    if ([tableView isEditing]) {
        
        
        //taking id from selected rows
        [selectedArray addObject:[finaldic objectForKey:@"id"]];
        
        
        count1=(int)[selectedArray count];
        NSLog(@"Selected count is :%i",count1);
        NSLog(@"Slected Array Id : %@",selectedArray);
        
        
        selectedIDs = [selectedArray componentsJoinedByString:@","];
        NSLog(@"Slected Ticket Id are : %@",selectedIDs);
        
        
        
    }else{
        
        
          TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
        
        
        NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
        
        
        globalVariables.ticket_id=[finaldic objectForKey:@"id"];
        globalVariables.ticket_status=[finaldic objectForKey:@"status_name"];
        globalVariables.ticket_number=[finaldic objectForKey:@"ticket_number"];
        // globalVariables.ticketStatusBool=@"ticketView";
        
        
        NSDictionary *customerDict=[finaldic objectForKey:@"from"];
        
        globalVariables.first_name=[customerDict objectForKey:@"first_name"];
        globalVariables.last_name=[customerDict objectForKey:@"last_name"];
        //globalVariables.userIdFromInbox=[customerDict objectForKey:@"id"];
        
        
         [self.navigationController pushViewController:td animated:YES];
        
        
    }
}

// This method tells the delegate that the specified row is now deselected.
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedPath = indexPath;
    
    NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
    
    
    //removing id from selected rows
    [selectedArray removeObject:[finaldic objectForKey:@"id"]];
    
    
    count1=(int)[selectedArray count];
    NSLog(@"Selected count is :%i",count1);
    NSLog(@"Slected Id : %@",selectedArray);
    
    selectedIDs = [selectedArray componentsJoinedByString:@","];
    
    NSLog(@"Slected Ticket Id are : %@",selectedIDs);
    
    
    if (!selectedArray.count) {
        [self.sampleTableView setEditing:NO animated:YES];
        
    }
    
}




#pragma mark - SlideNavigationController Methods -
// This method used to show or hide slide navigation controller icon on navigation bar
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}


// This methodn used to show refresh behind the table view.
-(void)addUIRefresh{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *refreshing = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refreshing",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle,NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    refresh=[[UIRefreshControl alloc] init];
    refresh.tintColor=[UIColor whiteColor];
      refresh.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
  //  refresh.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#BDBDBD"];
    refresh.attributedTitle =refreshing;
    [refresh addTarget:self action:@selector(reloadd) forControlEvents:UIControlEventValueChanged];
    [_sampleTableView insertSubview:refresh atIndex:0];
    
}







// This method used to reload view
-(void)reloadd{
    [self reload];
    //    [refresh endRefreshing];
}


-(void)onNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event
{
    NSLog(@"11111111*********111111111111");
    
    
#ifdef IfMethodOne
    CGRect rect = [self.navigationController.navigationBar convertRect:[event.allTouches.anyObject view].frame toView:[[UIApplication sharedApplication] keyWindow]];
    
    [FTPopOverMenu showFromSenderFrame:rect
                         withMenuArray:@[@"MenuOne",@"MenuTwo",@"MenuThree",@"MenuFour"]
                            imageArray:@[@"Pokemon_Go_01",@"Pokemon_Go_02",@"Pokemon_Go_03",@"Pokemon_Go_04",]
                             doneBlock:^(NSInteger selectedIndex) {
                                 NSLog(@"done");
                             } dismissBlock:^{
                                 NSLog(@"cancel");
                             }];
    
    
#else
    
    
    //taking status names array for dependecy api
    for (NSDictionary *dicc in self->ticketStatusArray) {
        if ([dicc objectForKey:@"name"]) {
            [self->statusArrayforChange addObject:[dicc objectForKey:@"name"]];
            [self->statusIdforChange addObject:[dicc objectForKey:@"id"]];
        }
        
    }
    
    
    //removing duplicated status names
    for (id obj in self->statusArrayforChange) {
        if (![uniqueStatusNameArray containsObject:obj]) {
            [uniqueStatusNameArray addObject:obj];
        }
    }
    
    [FTPopOverMenu showFromEvent:event
                   withMenuArray:uniqueStatusNameArray
                      imageArray:uniqueStatusNameArray
                       doneBlock:^(NSInteger selectedIndex) {
                           
                           
                           self->selectedStatusName=[self->uniqueStatusNameArray objectAtIndex:selectedIndex];
                           NSLog(@"Status is : %@",self->selectedStatusName);
                           
                           
                           for (NSDictionary *dic in self->ticketStatusArray)
                           {
                               NSString *idOfStatus = dic[@"name"];
                               
                               if([idOfStatus isEqual:self->selectedStatusName])
                               {
                                   self->selectedStatusId= dic[@"id"];
                                   
                                   NSLog(@"id is : %@",self->selectedStatusId);
                               }
                           }
                           
                           if([self->selectedStatusName isEqualToString:@"Closed"] || [self->selectedStatusName isEqualToString:@"closed"])
                           {
                               [self->utils showAlertWithMessage:NSLocalizedString(@"Ticket is Already Closed",nil) sendViewController:self];
                               [SVProgressHUD dismiss];
                           }
                           else{
                               
                               [self askConfirmationForStatusChange];
                               
                               // [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                           }
                           
                       }
                    dismissBlock:^{
                        
                    }];
    
#endif
    
}

-(void)askConfirmationForStatusChange
{
    if ([Utils isEmpty:selectedIDs] || [selectedIDs isEqualToString:@""] ||[selectedIDs isEqualToString:@"(null)" ] )
    {
        [utils showAlertWithMessage:@"Please select the tickets for changing status of ticket." sendViewController:self];
        [SVProgressHUD dismiss];
    }
    else{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Ticket Status"
                                     message:@"are you sure you want to change ticket status?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"No"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Yes"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                       
                                       
                                       [SVProgressHUD showWithStatus:@"Please wait"];
                                       [self performSelector:@selector(changeStatusMethod1) withObject:self afterDelay:5.0];
                                   
                                    //   [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                                       
                                   }];
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

-(void)changeStatusMethod1{
   
    [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
}


// This method used to change status of ticket
-(void)changeStatusMethod:(NSString *)nameOfStatus idIs:(NSString *)idOfStatus
{
    
    NSLog(@"Status Name is : %@",nameOfStatus);
    NSLog(@"Id is : %@",idOfStatus);
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
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
        
        [SVProgressHUD showWithStatus:@"changing status"];
        
        
        
        NSString *url= [NSString stringWithFormat:@"%@api/v2/helpdesk/status/change?api_key=%@&token=%@&ticket_id=%@&status_id=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],selectedIDs,idOfStatus];
        NSLog(@"URL is : %@",url);
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [SVProgressHUD dismiss];
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    
                    if([msg isEqualToString:@"Error-403"])
                    {
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
                        [SVProgressHUD dismiss];
                    }
                    else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        [SVProgressHUD dismiss];
                    }
                    //  NSLog(@"Message is : %@",msg);
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getTicketStausChange-Refresh-error == %@",error.localizedDescription);
                    [SVProgressHUD dismiss];
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                NSLog(@"Thread--NO4-call-postTicketStatusChange");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-Status-Change-Close-%@",json);
                
                
                if([[json objectForKey:@"message"] isKindOfClass:[NSArray class]])
                {
                    [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
                    [SVProgressHUD dismiss];
                    
                }
                else{
                    
                    NSString * msg=[json objectForKey:@"message"];
                    
                    if([msg hasPrefix:@"Status changed"]){
                        
                        if (self.navigationController.navigationBarHidden) {
                            [self.navigationController setNavigationBarHidden:NO];
                        }
                        
                        [RMessage showNotificationInViewController:self.navigationController
                                                             title:NSLocalizedString(@"success.", nil)
                                                          subtitle:NSLocalizedString(@"Ticket Status Changed.", nil)
                                                         iconImage:nil
                                                              type:RMessageTypeSuccess
                                                    customTypeName:nil
                                                          duration:RMessageDurationAutomatic
                                                          callback:nil
                                                       buttonTitle:nil
                                                    buttonCallback:nil
                                                        atPosition:RMessagePositionNavBarOverlay
                                              canBeDismissedByUser:YES];
                        
                        
                        ClosedTicketsViewController *closedticketsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"closedId"];
                        [self.navigationController pushViewController:closedticketsVC animated:YES];
                        
                    }else
                    {
                        
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
                        [SVProgressHUD dismiss];
                        
                    }
                    
                }
            }
            
            NSLog(@"Thread-NO5-postTicketStatusChange-closed");
            
        }];
    }
    
    
    
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
                    NSDictionary *resultDic = [json objectForKey:@"data"];
                    
                    self->globalVariables.dependencyDataDict = [json objectForKey:@"data"];
                    
                    
                    self->ticketStatusArray=[resultDic objectForKey:@"status"];
                    
                    
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

-(void)showMessageForLogout:(NSString*)message sendViewController:(UIViewController *)viewController
{
    UIAlertController *alertController = [UIAlertController   alertControllerWithTitle:APP_NAME message:message  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction  actionWithTitle:@"Logout"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action)
                                   {
                                       [self logout];
                                       
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
                                       
                                       LoginViewController *login=[self.storyboard instantiateViewControllerWithIdentifier:@"loginId"];
                                       [self.navigationController pushViewController: login animated:YES];
                                   }];
    
    [alertController addAction:cancelAction];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
    
}

-(void)logout
{
    
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"faveoData.plist"];
    NSError *error;
    
    if(![[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error])
    {
        NSLog(@"Error while removing the plist %@", error.localizedDescription);
        //TODO: Handle/Log error
    }
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
    
    
}




@end
