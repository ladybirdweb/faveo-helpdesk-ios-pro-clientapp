//
//  ReplyTicketViewController.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "ReplyTicketViewController.h"
#import "LeftMenuViewController.h"
#import "ActionSheetStringPicker.h"
#import "HexColors.h"
#import "Utils.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "GlobalVariables.h"
//#import "BDCustomAlertView.h"
#import <HSAttachmentPicker/HSAttachmentPicker.h>
#import "TicketDetailViewController.h"
#import "SVProgressHUD.h"


@interface ReplyTicketViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,HSAttachmentPickerDelegate>
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    // NSString * count1;
    NSMutableArray *usersArray;
    
    NSArray  * ccListArray;
    
    HSAttachmentPicker *_menu;
    
    NSData *attachNSData;
    NSString *file123;
    NSString *base64Encoded;
    NSString *typeMime;
    
    
}

@end

@implementation ReplyTicketViewController


//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
  //  self.title=@"Reply Ticket";
 
    self.tableview1.separatorColor=[UIColor clearColor];
    
    
    UIButton *attachmentButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [attachmentButton setImage:[UIImage imageNamed:@"attach1"] forState:UIControlStateNormal];
    [attachmentButton addTarget:self action:@selector(addAttachmentPickerButton) forControlEvents:UIControlEventTouchUpInside];
    [attachmentButton setFrame:CGRectMake(12, 7, 22, 22)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    // [rightBarButtonItems addSubview:addBtn];
    [rightBarButtonItems addSubview:attachmentButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    utils=[[Utils alloc]init];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    

    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // to set black background color mask for Progress view
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    [self.messageTextView setInputAccessoryView:toolBar];
    
    _submitButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];

   
}

-(void)removeKeyBoard
{
    
    [_messageTextView resignFirstResponder];
}

//This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view.
-(void)viewWillAppear:(BOOL)animated
{
    [self viewDidLoad];
    
}


// After adding reply method when we click on submit method, below method is called
- (IBAction)submitButtonClicked:(id)sender {
    

     [SVProgressHUD showWithStatus:@"Please wait"];
     [_messageTextView resignFirstResponder];
    
    if([_messageTextView.text isEqualToString:@""] || [_messageTextView.text length]==0)
    {
        [utils showAlertWithMessage:@"Enter the reply content.It can not be empty." sendViewController:self];
        [SVProgressHUD dismiss];
    }else
    {
      //  [self replyTicketMethodCall];
       
        [self performSelector:@selector(replyTicketMethodCall) withObject:self afterDelay:5.0];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//Asks the delegate whether the specified text should be replaced in the text view.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if (range.length == 0) {
        if ([text isEqualToString:@"\n"]) {
            _messageTextView.text = [NSString stringWithFormat:@"%@\n\t",_messageTextView.text];
            return NO;
        }
    }
    
    if(textView == _messageTextView)
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
        
        NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890,.1234567890!@#$^&*()--=+/?:;{}[]| "];
        
        
        if([text rangeOfCharacterFromSet:set].location == NSNotFound)
        {
            return NO;
        }
    }
    
    
    return YES;
}

// Here attachment picker will initialize
-(void)addAttachmentPickerButton
{
    _menu = [[HSAttachmentPicker alloc] init];
    _menu.delegate = self;
    [_menu showAttachmentMenu];
    
}
//After clicking attachment button, attachment picker is ready to display
- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu showController:(UIViewController * _Nonnull)controller completion:(void (^ _Nullable)(void))completion {
    UIPopoverPresentationController *popover = controller.popoverPresentationController;
    if (popover != nil) {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        //  popover.sourceView = self.openPickerButton;
    }
    [self presentViewController:controller animated:true completion:completion];
}

// It will show error message, if any error is occured while selecting or displying picker
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

// It calls the ticket reply api
-(void)replyTicketMethodCall
{
   
   
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        [utils showAlertWithMessage:NO_INTERNET sendViewController:self];
        [SVProgressHUD dismiss];
        
    }else{
        
        
        @try{
        
            NSString *urlString=[NSString stringWithFormat:@"%@helpdesk/reply/withdetails?token=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"]];
            
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
            
            
            // reply content parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"reply_content\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[_messageTextView.text dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            NSString * tickerId=[NSString stringWithFormat:@"%@",globalVariables.ticket_id];
            // ticket id parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ticket_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[tickerId dataUsingEncoding:NSUTF8StringEncoding]];
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
            // "message": "Successfully replied"
            
           
            
            if ([jsonData objectForKey:@"message"]){
                
                NSString * msg=[jsonData objectForKey:@"message"];
                
                
                if([msg isEqualToString:@"Successfully replied"])
                {
                    
                   [SVProgressHUD dismiss];
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Success.", nil)
                                                      subtitle:NSLocalizedString(@"Posted your reply.", nil)
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
                
                     [self.view setNeedsDisplay];
                     [self.navigationController popViewControllerAnimated:YES];
                    
                }
                
                else if ([jsonData objectForKey:@"message"])
                {
                    
                    NSString *str=[jsonData objectForKey:@"message"];
                    
                    if([str isEqualToString:@"Token expired"])
                    {
                        MyWebservices *web=[[MyWebservices alloc]init];
                        [web refreshToken];
                        [self replyTicketMethodCall];
                        
                    }
                }
                else
                {
                    [self->utils showAlertWithMessage:@"Something went wrong. Please try again." sendViewController:self];
                   [SVProgressHUD dismiss];
                }
                NSLog(@"Thread-Ticket-Reply-closed");
                
            }
            if ([jsonData objectForKey:@"result"]){
                
                NSDictionary *resultDict=[jsonData objectForKey:@"result"];
                
                 if([[resultDict objectForKey:@"fails"] isEqualToString:@"Access denied"])
                 {
                      [self->utils showAlertWithMessage:@"Access Denied - You role or login credentials has been changed." sendViewController:self];
                      [SVProgressHUD dismiss];
                 }
                
            }
            
        }@catch (NSException *exception)
        {
            [utils showAlertWithMessage:exception.name sendViewController:self];
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            [SVProgressHUD dismiss];
            return;
        }
        @finally
        {
            NSLog( @" I am in replytTicket method in TicketDetail ViewController" );
            
        }
        
    }
}

@end
