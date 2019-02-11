//
//  TicketSearchViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 09/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "TicketSearchViewController.h"
#import "Utils.h"
#import "GlobalVariables.h"
#import "MyWebservices.h"
#import "AppDelegate.h"
#import "AppConstanst.h"
#import "HexColors.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "Reachability.h"
#import "LoadingTableViewCell.h"
#import "TicketTableViewCell.h"
#import "UIImageView+Letters.h"
#import "TicketDetailViewController.h"

#import "SVProgressHUD.h"

@interface TicketSearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    NSDictionary *tempDict;
    NSString * dataFromSearchTextField;
    NSString * ticketidIs;
    
    
    NSMutableArray *usersArray;
    NSMutableArray *userNameArray;
    NSMutableArray *firstNameArray;  // it is combination first ad last name
    NSMutableArray * staff1_idArray;
    NSMutableArray *profilePicArray;
}

@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, strong) NSArray *indexPaths;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalTickets; //
@property (nonatomic, strong) NSString *nextPageUrl;

@property (strong, nonatomic) NSMutableArray *sampleDataArray;
@property (strong, nonatomic) NSMutableArray *filteredSampleDataArray;

@end

@implementation TicketSearchViewController

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"Search",nil)];
    
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    _mutableArray=[[NSMutableArray alloc]init];
    _filteredSampleDataArray = [[NSMutableArray alloc] init];

    usersArray =[[NSMutableArray alloc]init];
    userNameArray=[[NSMutableArray alloc]init];
    firstNameArray =[[NSMutableArray alloc]init];
    staff1_idArray =[[NSMutableArray alloc]init];
    profilePicArray =[[NSMutableArray alloc]init];
    
    
    // to set black background color mask for Progress view
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// This method asks the delegate whether the specified text should be replaced in the text view.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"Search String is : %@",_seachTextField.text);
    dataFromSearchTextField=[NSString stringWithFormat:@"%@",_seachTextField.text];
    
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_seachTextField resignFirstResponder];
    return YES;
}



//It notifies the view controller that its view was added to a view hierarchy.
-(void)viewDidAppear:(BOOL)animated{
    [self.seachTextField becomeFirstResponder];
}

- (IBAction)searchButtonClicked:(id)sender {
    
    NSLog(@"Ticket Search API Called.");
    [self ticketSearchApiCall:_seachTextField.text];
    [_seachTextField resignFirstResponder];
    [SVProgressHUD showWithStatus:@"Getting tickets"];
    
}



//After clicking on search ticket, below method is called i.e ticket search API is called
-(void)ticketSearchApiCall:(NSString *)searchText
{
    
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
        
    }
    
    NSString *urlString=[searchText stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString * url= [NSString stringWithFormat:@"%@api/v1/helpdesk/ticket-search?token=%@&search=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],urlString];
    NSLog(@"URL is : %@",url);
    
    
    MyWebservices *webservices=[MyWebservices sharedInstance];
    [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        
        
        NSLog(@"Error is is : %@",error);
        NSLog(@"Message is is : %@",msg);
 //        NSLog(@"JSON is is : %@",json);
        
        if (error || [msg containsString:@"Error"]) {
            [self->refresh endRefreshing];
            
             [SVProgressHUD dismiss];
            
            if (msg) {
                
                NSLog(@"Message is : %@",msg);
                
                if([msg isEqualToString:@"Error-402"])
                {
                    NSLog(@"Message is : %@",msg);
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access denied - Either your role has been changed or your login credential has been changed."] sendViewController:self];
                }
                else{
                    
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                }
                
                
            }else if(error)  {
                [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                NSLog(@"Thread-Ticket-Search-Refresh-error == %@",error.localizedDescription);
            }
            return ;
        }
        
        if ([msg isEqualToString:@"tokenRefreshed"]) {
            
            [self ticketSearchApiCall:searchText];
            NSLog(@"Thread-Ticket-Search-call");
            return;
        }
        
        if (json) {
            
            //   NSLog(@"Thread-Ticket-SearchAPI-Json-%@",json);
            
            self->_filteredSampleDataArray=[[NSMutableArray alloc]initWithCapacity:11];
            
            NSDictionary * dict1 = [json objectForKey:@"result"];
            
            self->_filteredSampleDataArray = [dict1 objectForKey:@"data"];
            
            
            //  NSLog(@"Mutable Array is--%@",_filteredSampleDataArray);
            
            
            self->_nextPageUrl =[dict1 objectForKey:@"next_page_url"];
            // NSLog(@"Next page url is : %@",_nextPageUrl);
            
            self->_path1=[dict1 objectForKey:@"path"];
            
            self->_currentPage=[[dict1 objectForKey:@"current_page"] integerValue];
            self->_totalTickets=[[dict1 objectForKey:@"total"] integerValue];
            self->_totalPages=[[dict1 objectForKey:@"last_page"] integerValue];
            
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    if([self->_filteredSampleDataArray count] == 0){
                        
                        [self->utils showAlertWithMessage:@"No data found." sendViewController:self];
                    }
                    
                    [self.tableview1 reloadData];
                    [SVProgressHUD dismiss];
                    
                });
            });
            
        }
        
    }];
    
    
}

- (void)reloadTableView
{
    [self.tableview1 reloadData];
}


//This method returns the number of rows (table cells) in a specified section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
        NSInteger numOfSections = 0;
    
        if ([_filteredSampleDataArray count]==0)
        {
            // CGRectMake(0, -10, tableView.bounds.size.width, tableView.bounds.size.height)
            UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
            //CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/2);
            
            
          //  noDataLabel.text             =  NSLocalizedString(@"No Records..!!!",nil);
            noDataLabel.text             =  NSLocalizedString(@"",nil);
            noDataLabel.textColor        = [UIColor blackColor];
            noDataLabel.textAlignment    = NSTextAlignmentCenter;
            tableView.backgroundView = noDataLabel;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
        }
        else
        {
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            numOfSections                = 1;
            tableView.backgroundView = nil;
        }
        
        return numOfSections;
    
}

//This method asks the data source to return the number of sections in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        if (self.currentPage == self.totalPages
            || self.totalTickets == _filteredSampleDataArray.count) {
            return _filteredSampleDataArray.count;
        }
        
        return _filteredSampleDataArray.count + 1;
}


////This method tells the delegate the table view is about to draw a cell for a particular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
        if (indexPath.row == [_filteredSampleDataArray count] - 1 ) {
            NSLog(@"nextURL111  %@",_nextPageUrl);
            
            if (( ![_nextPageUrl isEqual:[NSNull null]] ) && ( [_nextPageUrl length] != 0 )) {
                
                [self loadMoreforSearchResults];
                
                
            }
            else{
                
                [RMessage showNotificationInViewController:self
                                                     title:nil
                                                  subtitle:NSLocalizedString(@"All Caught Up", nil)
                                                 iconImage:nil
                                                      type:RMessageTypeSuccess
                                            customTypeName:nil
                                                  duration:RMessageDurationAutomatic
                                                  callback:nil
                                               buttonTitle:nil
                                            buttonCallback:nil
                                                atPosition:RMessagePositionBottom
                                      canBeDismissedByUser:YES];
            }
        }
    
    
    
}


// This method asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        if (indexPath.row == [_filteredSampleDataArray count])
        {
            LoadingTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LoadingCellID"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                
            }
            UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1];
            [activityIndicator startAnimating];
            return cell;
            
        }else
        {
            TicketTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"TableViewCellID"];
            
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            @try{
                //user name deatils
                NSDictionary *searchDictionary=[_filteredSampleDataArray objectAtIndex:indexPath.row];
                //  NSLog(@"searchDictionary is : %@",searchDictionary);
                
                NSString*profilPic;
                NSString *fname;
                NSString *lname;
                NSString*userName;
                
                if([NSNull null] != [searchDictionary objectForKey:@"user"]) {
                   
                    NSDictionary *userDict = [searchDictionary objectForKey:@"user"];
                   
                    fname = [userDict objectForKey:@"first_name"];
                    lname = [userDict objectForKey:@"last_name"];
                    userName =[userDict objectForKey:@"user_name"];
                    profilPic =[userDict objectForKey:@"profile_pic"];
                    
                    [Utils isEmpty:fname];
                    [Utils isEmpty:lname];
                    [Utils isEmpty:userName];
                    [Utils isEmpty:profilPic];
                    
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
                    
                    
                }else
                {
                    
                    cell.mailIdLabel.text=NSLocalizedString(@"Not Available", nil);
                }
            
                
                
                // ticket numbner
                NSString *ticketNumber=[searchDictionary objectForKey:@"ticket_number"];
                
                [Utils isEmpty:ticketNumber];
                if  (![Utils isEmpty:ticketNumber] && ![ticketNumber isEqualToString:@""])
                {
                    cell.ticketIdLabel.text=ticketNumber;
                }
                else
                {
                    cell.ticketIdLabel.text=NSLocalizedString(@"Not Available", nil);
                }
                
                //Image view
                if([profilPic hasSuffix:@"system.png"] || [profilPic hasSuffix:@".jpg"] || [profilPic hasSuffix:@".jpeg"] || [profilPic hasSuffix:@".png"] )
                {
                    [cell setUserProfileimage:profilPic];
                }
                else if(![Utils isEmpty:fname])
                {
                    fname = [fname substringToIndex:2];
                    [cell.profilePicView setImageWithString:fname color:nil ];
                }
                else
                {
                    userName = [userName substringToIndex:2];
                    [cell.profilePicView setImageWithString:userName color:nil ];
                }
                
                
                //priority
                //   if(( ![[searchDictionary objectForKey:@"priority"] isEqual:[NSNull null]] ) )
                NSDictionary *priorityDict=[searchDictionary objectForKey:@"priority"];
                NSString * color=[priorityDict objectForKey:@"priority_color"];
                
                if(![Utils isEmpty:color])
                {
                    cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:color]CGColor];
                }
                else{
                    // cell.indicationView.layer.backgroundColor=[UIColor clea];
                    NSLog(@"I am in else condition");
                    
                }
                
                // ticket
                
                NSMutableArray * ticketThredArray= [searchDictionary objectForKey:@"thread"];
                //
                if(( ![[searchDictionary objectForKey:@"thread"] isEqual:[NSNull null]] ) )
                {
                    NSDictionary *ticketDict=[ticketThredArray objectAtIndex:0];
                    
                  //  NSLog(@"ticket dict 111111 is : %@",ticketDict);
                  //  NSLog(@"ticket dict 111111 is : %@",ticketDict);
                    
                    if(( ![[ticketDict objectForKey:@"ticket_id"] isEqual:[NSNull null]] ) )
                        
                    {
                        NSString * ticketidIs= [NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"ticket_id"]];
                        NSLog(@"Ticket id is : %@",ticketidIs);
                        
                    }
                    
                    if(( ![[ticketDict objectForKey:@"title"] isEqual:@""] ) || ( ![[ticketDict objectForKey:@"title"] isEqual:[NSNull null]] ) )
                    {
                        NSString * ticketTitle= [NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"title"]];
                        NSLog(@"Ticket Title is : %@",ticketTitle);
                        
                        
                        NSString *encodedString =[NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"title"]];
                        
                        
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
                                
                                cell.ticketSubLabel.text= decodedString; //countthread
                                //   cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",decodedString,[finaldic objectForKey:@"countthread"]];
                            }
                            else{
                                
                                cell.ticketSubLabel.text= encodedString;
                                //  cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",encodedString,[finaldic objectForKey:@"countthread"]];
                                
                            }
                            
                        }
                        
                        
                        
                        //   cell.ticketSubLabel.text=ticketTitle;
                    }
                    
                }else
                {
                    cell.ticketSubLabel.text=@"No Title - EMPTY JSON ";
                    
                }//end ticket thread
                
                
                //due/oberdue
                
                if(( ![[searchDictionary objectForKey:@"duedate"] isEqual:[NSNull null]] ) )
                    
                {
                    
                    if([utils compareDates:[searchDictionary objectForKey:@"duedate"]]){
                        [cell.overDueLabel setHidden:NO];
                        [cell.today setHidden:YES];
                    }else
                    {
                        [cell.overDueLabel setHidden:YES];
                        [cell.today setHidden:NO];
                    }
                    
                }
                else{
                    NSLog(@"due date is empty");
                }
                
                
                // updated at
                
                if(( ![[searchDictionary objectForKey:@"updated_at"] isEqual:[NSNull null]] ) )
                {
                    NSString *str1=[searchDictionary objectForKey:@"updated_at"];
                    
                    cell.timeStampLabel.text=[utils getLocalDateTimeFromUTC:str1];
                }else{
                    cell.timeStampLabel.text=@"";
                    NSLog(@"updated date is empty");
                }
                
                
//                //Agent info
//                if(( ![[searchDictionary objectForKey:@"assignee"] isEqual:[NSNull null]] ) )
//
//                {
//                    NSObject *obj=[searchDictionary objectForKey:@"assignee"];
//                    if([obj isKindOfClass:[NSArray class]])
//                    {
//                        cell.agentLabel.text=@"Unassigned";
//                    }else{
//
//                        NSDictionary *userDict=[searchDictionary objectForKey:@"assignee"];
//                        NSString*firstName=[userDict objectForKey:@"first_name"];
//                        NSString*laststName=[userDict objectForKey:@"last_name"];
//                        NSString*userName=[userDict objectForKey:@"user_name"];
//
//                        [Utils isEmpty:firstName];
//                        [Utils isEmpty:laststName];
//                        [Utils isEmpty:userName];
//
//                        if(![Utils isEmpty:firstName] || ![Utils isEmpty:firstName])
//                        {
//                            if(![Utils isEmpty:firstName] && ![Utils isEmpty:firstName])
//                            {
//                                cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",firstName,laststName];
//                            }else
//                            {
//                                cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",firstName,laststName];
//                            }
//
//                        }
//                        else if(![Utils isEmpty:userName])
//                        {
//                            cell.agentLabel.text=[NSString stringWithFormat:@"%@",userName];
//                        }
//                        else
//                        {
//                            cell.agentLabel.text=@"Unassigned";
//                        }
//                    }
//                } //end userDict
                
            }@catch (NSException *exception)
            {
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                [utils showAlertWithMessage:exception.name sendViewController:self];
                // return;
            }
            @finally
            {
                NSLog( @" I am in CellForRowAtIndexPath method for Ticket Search ViewController" );
                
            }
            
            return cell;
        }
    
}

// This method calls an API for getting next page tickets, it will returns an JSON which contains 10 records with ticket details.
-(void)loadMoreforSearchResults
{
    
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
        
        
    }else{
        
        self.page = _page + 1;
        // NSLog(@"Page is : %ld",(long)_page);
        
        NSString *str=_nextPageUrl;
        NSString *Page = [str substringFromIndex:[str length] - 1];
        
        //     NSLog(@"String is : %@",szResult);
        NSLog(@"Page is : %@",Page);
        NSLog(@"Page is : %@",Page);
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        NSString *searcText=[_seachTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
       
        [webservices getNextPageURLInboxSearchResults:_path1 searchString:searcText  pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-TicketSearch-Load-more-Refresh-error == %@",error.localizedDescription);
                }
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self loadMoreforSearchResults];
                //NSLog(@"Thread--NO4-call-getInbox");
                return;
            }
            
            if (json) {
                NSLog(@"Thread-TicketSearch-Load-more-jSON--%@",json);
                
                NSDictionary * dict1 = [json objectForKey:@"result"];
                
                self->_nextPageUrl =[dict1 objectForKey:@"next_page_url"];
                self->_currentPage=[[dict1 objectForKey:@"current_page"] integerValue];
                self->_totalTickets=[[dict1 objectForKey:@"total"] integerValue];
                self->_totalPages=[[dict1 objectForKey:@"last_page"] integerValue];
                self->_path1=[dict1 objectForKey:@"path"];
                
                self->_filteredSampleDataArray= [self->_filteredSampleDataArray mutableCopy];
                [self->_filteredSampleDataArray addObjectsFromArray:[dict1 objectForKey:@"data"]];
                //   _filteredSampleDataArray = [dict1 objectForKey:@"data"];
                
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // [self.tableview reloadData];
                        //                        [self reloadTableView];
                        [self.tableview1 reloadData];
                        
                    });
                });
                
            }
            
            
        }];
        
    }
    
    
}

// This method tells the delegate that the specified row is now selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        NSDictionary *searchDictionary=[_filteredSampleDataArray objectAtIndex:indexPath.row];
        
        NSDictionary * statusValueDict=[searchDictionary objectForKey:@"statuses"];
        
        globalVariables.ticket_status=[statusValueDict objectForKey:@"name"];
        
        NSMutableArray * ticketThredArray= [searchDictionary objectForKey:@"thread"];
        //
        if(( ![[searchDictionary objectForKey:@"thread"] isEqual:[NSNull null]] ) )
        {
            NSDictionary *ticketDict=[ticketThredArray objectAtIndex:0];
            
            if(( ![[ticketDict objectForKey:@"ticket_id"] isEqual:[NSNull null]] ) )
                
            {
                ticketidIs= [NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"ticket_id"]];
                
                NSLog(@"Ticket id is : %@",ticketidIs);
                
            }
            
        }
        
        
        // first name, last name, user name owner name
        NSDictionary * userDict= [searchDictionary objectForKey:@"user"];
        
        NSString *fname= [userDict objectForKey:@"first_name"];
        
        NSString *lname= [userDict objectForKey:@"last_name"];
        
        NSString*userName=[userDict objectForKey:@"user_name"];
        
        
        
        [Utils isEmpty:fname];
        [Utils isEmpty:lname];
        [Utils isEmpty:userName];
        
        
        
        if  (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
        {
            if (![Utils isEmpty:fname] && ![Utils isEmpty:lname])
            {    globalVariables.first_name=fname;
                 globalVariables.last_name=lname;
            }
            else if (![Utils isEmpty:fname]){
                globalVariables.first_name=[NSString stringWithFormat:@"%@",fname];
                globalVariables.last_name=@"";
            }
        }
        else
        {
            if(![Utils isEmpty:userName])
            {
                globalVariables.first_name=userName;
                globalVariables.last_name=@"";
            }
            else{
                globalVariables.first_name=NSLocalizedString(@"", nil);
                globalVariables.last_name=@"";
            }
            
        }
        
        
        // ticket numbner
        NSString *ticketNumber=[searchDictionary objectForKey:@"ticket_number"];
        
        [Utils isEmpty:ticketNumber];
        if  (![Utils isEmpty:ticketNumber] && ![ticketNumber isEqualToString:@""])
        {
            globalVariables.ticket_number=ticketNumber;
        }
        else
        {
            globalVariables.ticket_number=NSLocalizedString(@"", nil);
        }
        
        
        
        globalVariables.ticket_id=(NSNumber*)ticketidIs;
        
        TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
        [self.navigationController pushViewController:td animated:YES];
        
    
   
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Calculate cell height
    return 85.0f;
}


@end

