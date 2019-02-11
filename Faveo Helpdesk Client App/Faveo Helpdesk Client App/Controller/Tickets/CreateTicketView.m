//
//  CreateTicketView.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "CreateTicketView.h"
#import "AppConstanst.h"
#import "Utils.h"
#import "GlobalVariables.h"
#import "MyWebservices.h"
#import "OpenTicketsViewController.h"
#import "Reachability.h"
#import "ActionSheetStringPicker.h"
#import "HexColors.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "SVProgressHUD.h"
#import "IQKeyboardManager.h"
#import "UITextField+AutoSuggestion.h"
#import "UIImageView+Letters.h"
#import <HSAttachmentPicker/HSAttachmentPicker.h>
#import <QuartzCore/QuartzCore.h>


@interface CreateTicketView ()<RMessageProtocol,UITextFieldDelegate,UITextViewDelegate,HSAttachmentPickerDelegate>
{
    
    Utils *utils;
    NSUserDefaults *userDefaults;
  
    NSNumber *help_topic_id;
    NSNumber *priority_id;
   
    NSMutableArray * pri_idArray;
    NSMutableArray * helpTopic_idArray;
    
    GlobalVariables *globalVariables;
    NSDictionary *priDicc1;
    
    NSMutableArray *userNameArray;
    
    NSArray *ticketStatusArray;
 
    HSAttachmentPicker *_menu;
    NSData *attachNSData;
    NSString *file123;
    NSString *base64Encoded;
    NSString *typeMime;
    
   
    
}

// Picker view methods
- (void)helpTopicWasSelected:(NSNumber *)selectedIndex element:(id)element;
- (void)priorityWasSelected:(NSNumber *)selectedIndex element:(id)element;
- (void)actionPickerCancelled:(id)sender;

@end

@implementation CreateTicketView

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];

    
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 316, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    [self.messageTextView setInputAccessoryView:toolBar];
    [self.subjectTextView setInputAccessoryView:toolBar];
 
    
   
   // dept_id=[[NSNumber alloc]init];
    help_topic_id=[[NSNumber alloc]init];
    priority_id=[[NSNumber alloc]init];
    
    
    utils=[[Utils alloc]init];
    userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    

    [self readFromPlist];
    
    [self setTitle:NSLocalizedString(@"Create Ticket",nil)];
    
    // UIBar item for attachment button
    UIButton *attachmentButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [attachmentButton setImage:[UIImage imageNamed:@"attach1"] forState:UIControlStateNormal];
    [attachmentButton addTarget:self action:@selector(addAttachmentPickerButton) forControlEvents:UIControlEventTouchUpInside];
    [attachmentButton setFrame:CGRectMake(0, 0, 20, 20)];
    
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [rightBarButtonItems addSubview:attachmentButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    // to set black background color mask for Progress view
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
    
    [_priorityTextField endEditing:YES];
    [_helptopicTextField endEditing:YES];

    
     self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _submitButtonOutlet.backgroundColor= [UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark - SlideNavigationController Methods -
// This method used to show or hide slide navigation controller icon on navigation bar
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

-(void)removeKeyboard{
    
    [_subjectTextView resignFirstResponder];
    [_messageTextView resignFirstResponder];
    
}
-(void)removeKeyBoard
{
    
    [_subjectTextView resignFirstResponder];
    [_messageTextView resignFirstResponder];

}



//This method used for taking values from Plist file. Plist is one king of database used for temporary storage used in within mobile app
-(void)readFromPlist{
    // Read plist from bundle and get Root Dictionary out of it
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"faveoData.plist"];
    
    @try{
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        {
            plistPath = [[NSBundle mainBundle] pathForResource:@"faveoData" ofType:@"plist"];
        }
     //   NSDictionary *resultDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *resultDic = globalVariables.dependencyDataDict;
        
        NSLog(@"resultDic--%@",resultDic);
        
    
        NSArray *helpTopicArray=[resultDic objectForKey:@"helptopics"];
        NSArray *prioritiesArray=[resultDic objectForKey:@"priorities"];
    
        
      
        NSMutableArray *helptopicMU=[[NSMutableArray alloc]init];
        NSMutableArray *priMU=[[NSMutableArray alloc]init];
     
    
        helpTopic_idArray=[[NSMutableArray alloc]init];
        pri_idArray=[[NSMutableArray alloc]init];
    
    
    
        priDicc1=[NSDictionary dictionaryWithObjects:priMU forKeys:pri_idArray];
        
        
        for (NSDictionary *dicc in prioritiesArray) {
            if ([dicc objectForKey:@"priority"]) {
                [priMU addObject:[dicc objectForKey:@"priority"]];
                [pri_idArray addObject:[dicc objectForKey:@"priority_id"]];
            }
            
        }
        
       
        for (NSDictionary *dicc in helpTopicArray) {
            if ([dicc objectForKey:@"topic"]) {
                [helptopicMU addObject:[dicc objectForKey:@"topic"]];
                [helpTopic_idArray addObject:[dicc objectForKey:@"id"]];
                
            }
        }
        
    
        _helptopicsArray=[helptopicMU copy];
        _priorityArray=[priMU copy];
        
        
     //   _helptopicsArray = [_helptopicsArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
     //   _priorityArray = [_priorityArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        

    }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        return;
    }
    @finally
    {
        NSLog( @" I am in readFromList method in CreateTicket ViewController" );
        
    }
    
}



- (IBAction)priorityClicked:(id)sender {
    
    @try{
        [self.view endEditing:YES];
        if (!_priorityArray||![_priorityArray count]) {
            _priorityTextField.text=NSLocalizedString(@"Not Available",nil);
            priority_id=0;
            
        }else{
            [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select Priority",nil) rows:_priorityArray initialSelection:0 target:self successAction:@selector(priorityWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
        }
    }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        return;
    }
    @finally
    {
        NSLog( @" I am in PriorityCLicked method in CreateTicket ViewController" );
        
    }
    
    
}



- (IBAction)helptopicClicked:(id)sender {
    
    @try{
        [self.view endEditing:YES];
        if (!_helptopicsArray||!_helptopicsArray.count) {
            _helptopicTextField.text=NSLocalizedString(@"Not Available",nil);
            help_topic_id=0;
        }else{
            [ActionSheetStringPicker showPickerWithTitle:@"Select Helptopic" rows:_helptopicsArray initialSelection:0 target:self successAction:@selector(helpTopicWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
        }
    }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        return;
    }
    @finally
    {
        NSLog( @" I am in HelptopicCLicked method in CreateTicket ViewController" );
        
    }
    
}


- (IBAction)submitButtonClicked:(id)sender {
    
    [self removeKeyBoard];
    
    [SVProgressHUD showWithStatus:@"Please wait"];
    
    @try{
        
       
        
        if(self.helptopicTextField.text.length==0 && self.subjectTextView.text.length==0 && self.priorityTextField.text.length==0 && self.messageTextView.text.length==0)
        {
            [SVProgressHUD dismiss];
            
            if (self.navigationController.navigationBarHidden) {
                [self.navigationController setNavigationBarHidden:NO];
            }
            
            [RMessage showNotificationInViewController:self.navigationController
                                                 title:NSLocalizedString(@"Warning !", nil)
                                              subtitle:NSLocalizedString(@"Please fill all mandatory fields.", nil)
                                             iconImage:nil
                                                  type:RMessageTypeWarning
                                        customTypeName:nil
                                              duration:RMessageDurationAutomatic
                                              callback:nil
                                           buttonTitle:nil
                                        buttonCallback:nil
                                            atPosition:RMessagePositionNavBarOverlay
                                  canBeDismissedByUser:YES];
            
            
        }
        else
                if (self.helptopicTextField.text.length==0) {
                    
                    [SVProgressHUD dismiss];
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Warning !", nil)
                                                      subtitle:NSLocalizedString(@"Please select Help-Topic.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeWarning
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                    
                }else if (self.subjectTextView.text.length==0) {
                    
                    [SVProgressHUD dismiss];
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Warning !", nil)
                                                      subtitle:NSLocalizedString(@"Please enter Subject.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeWarning
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                }else if (self.subjectTextView.text.length<5) {
                    
                    [SVProgressHUD dismiss];
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Warning !", nil)
                                                      subtitle:NSLocalizedString(@"Subject requires at least 5 characters.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeWarning
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                }else if (self.messageTextView.text.length==0){
                    
                    [SVProgressHUD dismiss];
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Warning !", nil)
                                                      subtitle:NSLocalizedString(@"Please enter Message.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeWarning
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                }else if (self.messageTextView.text.length<10){
                    
                    [SVProgressHUD dismiss];
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Warning !", nil)
                                                      subtitle:NSLocalizedString(@"Message requires at least 10 characters.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeWarning
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                }
                else if (self.priorityTextField.text.length==0){
                    
                    [SVProgressHUD dismiss];
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Warning !", nil)
                                                      subtitle:NSLocalizedString(@"Please select Priority.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeWarning
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                }
                else {
                    
                    [self performSelector:@selector(postTicketCreate) withObject:self afterDelay:5.0];    //[self postTicketCreate]; //[self createTicket];
                    
                }
        
    }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        return;
    }
    @finally
    {
        NSLog( @" I am in submitt button method in Create ticket ViewController" );
        
    }
    
}







- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}


- (void)helpTopicWasSelected:(NSNumber *)selectedIndex element:(id)element {
    help_topic_id=(helpTopic_idArray)[(NSUInteger) [selectedIndex intValue]];
    self.helptopicTextField.text = (_helptopicsArray)[(NSUInteger) [selectedIndex intValue]];
}

- (void)priorityWasSelected:(NSNumber *)selectedIndex element:(id)element {
    
    priority_id=(pri_idArray)[(NSUInteger) [selectedIndex intValue]];
    self.priorityTextField.text = (_priorityArray)[(NSUInteger) [selectedIndex intValue]];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}


// this method used to control writing data/texts in textfields and textviews.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  
    
    if(textView == _subjectTextView)
    {
        
        if([text isEqualToString:@" "])
        {
            if(!textView.text.length)
            {
                return NO;
            }
        }
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length < textView.text.length)
        {
            
            return  YES;
        }
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length >500)
        {
            return NO;
        }
        
        NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.';;:?()*&%, "];
        
        
        if([text rangeOfCharacterFromSet:set].location == NSNotFound)
        {
            return NO;
        }
    }
    
    else if(textView == _messageTextView)
    {
        
        if([text isEqualToString:@" "])
        {
            if(!textView.text.length)
            {
                return NO;
            }
        }
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length < textView.text.length)
        {
            
            return  YES;
        }
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length >500)
        {
            return NO;
        }
        
        NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.';;:?()*&%, "];
        
        
        if([text rangeOfCharacterFromSet:set].location == NSNotFound)
        {
            return NO;
        }
    }
    
    
    return YES;
}





-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



// called ticket create method
-(void)postTicketCreate
{
   
    // check MEME and file size of attachments
    NSLog(@"MEME111111111111 is : %@",typeMime);
    NSLog(@"MEME22222222222 is : %@",file123);
    
    //API call
    NSString *urlString=[NSString stringWithFormat:@"%@helpdesk/create/satellite/ticket?token=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    
    // attachment parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media_attachment[]\"; filename=\"%@\"\r\n", file123] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", typeMime] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[NSData dataWithData:attachNSData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // api key parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"api_key\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[API_KEY dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // subject parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"subject\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[_subjectTextView.text dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // message body parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"body\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[_messageTextView.text dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
   
    
    // first name parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"first_name\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[userDefaults objectForKey:@"profile_name"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
   
    
    
    // email parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[userDefaults objectForKey:@"user_email"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString * help_id=[NSString stringWithFormat:@"%@",help_topic_id];
    NSString * prio_id=[NSString stringWithFormat:@"%@",priority_id];
    
    // help topic parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"help_topic\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[help_id dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // priority id parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"priority\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[prio_id dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    NSLog(@"Request is : %@",request);
    
    
    //return and test
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"ReturnString : %@", returnString);
    
    NSError *error=nil;
    NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
    if (error) {
        return;
    }
    
    NSLog(@"Dictionary is : %@",jsonData);
    
    if([jsonData objectForKey:@"message"])
        
    {
        NSString *str= [jsonData objectForKey:@"message"];
        
        if([str isEqualToString:@"Permission denied, you do not have permission to access the requested page."] || [str hasPrefix:@"Permission denied"])
        {
            
            [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
            [SVProgressHUD dismiss];
            
        }
        if([str isEqualToString:@"API disabled"] || [str hasPrefix:@"API disabled"])
        {
            
            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
            [SVProgressHUD dismiss];
            
        }
        else{
            NSString *str=[jsonData objectForKey:@"message"];
            
            if([str isEqualToString:@"Token expired"])
            {
                
                MyWebservices *web=[[MyWebservices alloc]init];
                [web refreshToken];
                [self postTicketCreate];
                
            }else if([str isEqualToString:@"Ticket created successfully!"])
                
            {
                
                
                [SVProgressHUD dismiss];
                
                if (self.navigationController.navigationBarHidden) {
                    [self.navigationController setNavigationBarHidden:NO];
                }
                
                [RMessage showNotificationInViewController:self.navigationController
                                                     title:NSLocalizedString(@"success", nil)
                                                  subtitle:NSLocalizedString(@"Ticket created successfully.", nil)
                                                 iconImage:nil
                                                      type:RMessageTypeSuccess
                                            customTypeName:nil
                                                  duration:RMessageDurationAutomatic
                                                  callback:nil
                                               buttonTitle:nil
                                            buttonCallback:nil
                                                atPosition:RMessagePositionNavBarOverlay
                                      canBeDismissedByUser:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
                
                OpenTicketsViewController *openVC=[self.storyboard instantiateViewControllerWithIdentifier:@"openId"];
                [self.navigationController pushViewController:openVC animated:YES];
                
            }
            
        }
        
    }//end first if

    else{
        
        [self->utils showAlertWithMessage:NSLocalizedString(@"Something Went Wrong.", nil) sendViewController:self];
       // [[AppDelegate sharedAppdelegate] hideProgressView];
        [SVProgressHUD dismiss];
        
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








// Initialize attachment picker menu
-(void)addAttachmentPickerButton
{
    _menu = [[HSAttachmentPicker alloc] init];
    _menu.delegate = self;
    [_menu showAttachmentMenu];
    
}

// It will show attachment picker
- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu showController:(UIViewController * _Nonnull)controller completion:(void (^ _Nullable)(void))completion {
    UIPopoverPresentationController *popover = controller.popoverPresentationController;
    if (popover != nil) {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        //  popover.sourceView = self.openPickerButton;
    }
    [self presentViewController:controller animated:true completion:completion];
}

// if error occured it will show error message
- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu showErrorMessage:(NSString * _Nonnull)errorMessage {
    NSLog(@"%@", errorMessage);
}

// here actaul picker called, here it will show picker view and we can select attachment and after selecting file it will print file name and with its size
- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu upload:(NSData * _Nonnull)data filename:(NSString * _Nonnull)filename image:(UIImage * _Nullable)image {
    
    NSLog(@"File Name : %@", filename);
    NSLog(@"File name : %@",filename);
    
    file123=filename;
    attachNSData=data;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_fileSize123.text=[NSString stringWithFormat:@" %.2f MB",(float)data.length/1024.0f/1024.0f];
        
        
        
        //  base64Encoded = [data base64EncodedStringWithOptions:0];
        // printf("NSDATA Attachemnt : %s\n", [base64Encoded UTF8String]);
        
        
        self->_fileName123.text=filename;
        
        if([filename hasSuffix:@".doc"] || [filename hasSuffix:@".DOC"])
        {
            self->typeMime=@"application/msword";
            self->_fileImage.image=[UIImage imageNamed:@"doc"];
        }
        else if([filename hasSuffix:@".pdf"] || [filename hasSuffix:@".PDF"])
        {
            self->typeMime=@"application/pdf";
            self->_fileImage.image=[UIImage imageNamed:@"pdf"];
        }
        else if([filename hasSuffix:@".css"] || [filename hasSuffix:@".CSS"])
        {
            self->typeMime=@"text/css";
            self->_fileImage.image=[UIImage imageNamed:@"css"];
        }
        else if([filename hasSuffix:@".csv"] || [filename hasSuffix:@".CSV"])
        {
            self->typeMime=@"text/csv";
            self->_fileImage.image=[UIImage imageNamed:@"csv"];
        }
        else if([filename hasSuffix:@".xls"] || [filename hasSuffix:@".XLS"])
        {
            self->typeMime=@"application/vnd.ms-excel";
            self->_fileImage.image=[UIImage imageNamed:@"xls"];
        }
        
        else if([filename hasSuffix:@".rtf"] || [filename hasSuffix:@".RTF"])
        {
            self->typeMime=@"text/richtext";
            self->_fileImage.image=[UIImage imageNamed:@"rtf"];
        }
        else if([filename hasSuffix:@".sql"] || [filename hasSuffix:@".SQL"])
        {
            self->typeMime=@"text/sql";
            self->_fileImage.image=[UIImage imageNamed:@"sql"];
        }
        else if([filename hasSuffix:@".gif"] || [filename hasSuffix:@".GIF"])
        {
            self->typeMime=@"image/gif";
            self->_fileImage.image=[UIImage imageNamed:@"gif2"];
        }
        else if([filename hasSuffix:@".ppt"] || [filename hasSuffix:@".PPT"])
        {
            self->typeMime=@"application/mspowerpoint";
            self->_fileImage.image=[UIImage imageNamed:@"ppt"];
        }
        else if([filename hasSuffix:@".jpeg"] || [filename hasSuffix:@".JPEG"])
        {
            self->typeMime=@"image/jpeg";
            self->_fileImage.image=[UIImage imageNamed:@"jpg"];
        }
        else if([filename hasSuffix:@".docx"] || [filename hasSuffix:@".DOCX"])
        {
            self->typeMime=@"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            self->_fileImage.image=[UIImage imageNamed:@"doc"];
        }
        else if([filename hasSuffix:@".pps"] || [filename hasSuffix:@".PPS"])
        {
            self->typeMime=@"application/vnd.ms-powerpoint";
            self->_fileImage.image=[UIImage imageNamed:@"ppt"];
        }
        else if([filename hasSuffix:@".pptx"] || [filename hasSuffix:@".PPTX"])
        {
            self->typeMime=@"application/vnd.openxmlformats-officedocument.presentationml.presentation";
            self->_fileImage.image=[UIImage imageNamed:@"ppt"];
        }
        else if([filename hasSuffix:@".jpg"] || [filename hasSuffix:@".JPG"])
        {
            self->typeMime=@"image/jpg";
            self->_fileImage.image=[UIImage imageNamed:@"jpg"];
        }
        else if([filename hasSuffix:@".png"] || [filename hasSuffix:@".PNG"])
        {
            self->typeMime=@"image/png";
            self->_fileImage.image=[UIImage imageNamed:@"png"];
        }
        else if([filename hasSuffix:@".ico"] || [filename hasSuffix:@".ICO"])
        {
            self->typeMime=@"image/x-icon";
            self->_fileImage.image=[UIImage imageNamed:@"ico"];
        }
        else if([filename hasSuffix:@".txt"] || [filename hasSuffix:@".text"] || [filename hasSuffix:@".TEXT"] || [filename hasSuffix:@".com"] || [filename hasSuffix:@".f"] || [filename hasSuffix:@".hh"]  || [filename hasSuffix:@".conf"]  || [filename hasSuffix:@".f90"]  || [filename hasSuffix:@".idc"] || [filename hasSuffix:@".cxx"] || [filename hasSuffix:@".h"] || [filename hasSuffix:@".java"] || [filename hasSuffix:@".def"] || [filename hasSuffix:@".g"] || [filename hasSuffix:@".c"] || [filename hasSuffix:@".c++"] || [filename hasSuffix:@".cc"] || [filename hasSuffix:@".list"]|| [filename hasSuffix:@".log"]|| [filename hasSuffix:@".lst"] || [filename hasSuffix:@".m"] || [filename hasSuffix:@".mar"] || [filename hasSuffix:@".pl"] || [filename hasSuffix:@".sdml"])
        {
            self->typeMime=@"text/plain";
            self->_fileImage.image=[UIImage imageNamed:@"txt"];
        }
        else if([filename hasPrefix:@".bmp"])
        {
            self->typeMime=@"image/bmp";
            self->_fileImage.image=[UIImage imageNamed:@"commonImage"];
        }
        else if([filename hasPrefix:@".java"])
        {
            self->typeMime=@"application/java";
            self->_fileImage.image=[UIImage imageNamed:@"commonImage"];
        }
        else if([filename hasSuffix:@".html"] || [filename hasSuffix:@".htm"] || [filename hasSuffix:@".htmls"] || [filename hasSuffix:@".HTML"] || [filename hasSuffix:@".HTM"])
        {
            self->typeMime=@"text/html";
            self->_fileImage.image=[UIImage imageNamed:@"html"];
        }
        else  if([filename hasSuffix:@".mp3"])
        {
            self->typeMime=@"audio/mp3";
            self->_fileImage.image=[UIImage imageNamed:@"mp3"];
        }
        else  if([filename hasSuffix:@".wav"])
        {
            self->typeMime=@"audio/wav";
            self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
        }
        else  if([filename hasSuffix:@".aac"])
        {
            self->typeMime=@"audio/aac";
            self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
        }
        else  if([filename hasSuffix:@".aiff"] || [filename hasSuffix:@".aif"])
        {
            self->typeMime=@"audio/aiff";
            self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
        }
        else  if([filename hasSuffix:@".m4p"])
        {
            self->typeMime=@"audio/m4p";
            self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
        }
        else  if([filename hasSuffix:@".mp4"])
        {
            self->typeMime=@"video/mp4";
            self->_fileImage.image=[UIImage imageNamed:@"mp4"];
        }
        else if([filename hasSuffix:@".mov"])
        {
            self->typeMime=@"video/quicktime";
            self->_fileImage.image=[UIImage imageNamed:@"mov"];
        }
        
        else  if([filename hasSuffix:@".wmv"])
        {
            self->typeMime=@"video/x-ms-wmv";
            self->_fileImage.image=[UIImage imageNamed:@"wmv"];
        }
        else if([filename hasSuffix:@".flv"])
        {
            self->typeMime=@"video/x-msvideo";
            self->_fileImage.image=[UIImage imageNamed:@"flv"];
        }
        else if([filename hasSuffix:@".mkv"])
        {
            self->typeMime=@"video/mkv";
            self->_fileImage.image=[UIImage imageNamed:@"mkv"];
        }
        else if([filename hasSuffix:@".avi"])
        {
            self->typeMime=@"video/avi";
            self->_fileImage.image=[UIImage imageNamed:@"avi"];
        }
        else if([filename hasSuffix:@".zip"])
        {
            self->typeMime=@"application/zip";
            self->_fileImage.image=[UIImage imageNamed:@"zip"];
        }
        else if([filename hasSuffix:@".rar"])
        {
            self->typeMime=@"application/x-rar-compressed";
            self->_fileImage.image=[UIImage imageNamed:@"commonImage"];
        }
        else
        {
            self->_fileImage.image=[UIImage imageNamed:@"commonImage"];
        }
        
    });
}




@end
