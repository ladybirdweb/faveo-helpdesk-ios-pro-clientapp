//
//  ReplyTicketViewController.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class ReplyTicketViewController
 
 @brief This class used to give reply to the ticket.
 
 @discussion In this reply view user can able to see existing cc names and can able to add new cc to the ticket while giving an reply to the ticket.
 
 */
@interface ReplyTicketViewController : UITableViewController

/*!
 @property messageTextView
 
 @brief This textView used add an message for the ticket.
 */
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

/*!
 @property tableview1
 
 @brief This is tableView instance used for internal purpose.
 */
@property (strong, nonatomic) IBOutlet UITableView *tableview1;

/*!
 @property addCCLabelButton
 
 @brief This is label property and used as an button. After clicking this button it will navigate to the add cc view.
 */
@property (weak, nonatomic) IBOutlet UILabel *addCCLabelButton;

- (void)viewDidLoad;
- (IBAction)submitButtonClicked:(id)sender;


/*!
 @property submitButton
 
 @brief This is button property.
 */
@property (weak, nonatomic) IBOutlet UIButton 
*submitButton;

@property (weak, nonatomic) IBOutlet UILabel *replyTicketLabel;


/*!
 @property fileImage
 
 @brief This is imageView property used to show and icon for the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;

/*!
 @property fileName123
 
 @brief This is label property used to show file name for the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *fileName123;

/*!
 @property fileSize123
 
 @brief This is label property used to show file size for the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *fileSize123;

/*!
 @property viewCCLabel
 
 @brief This is label property used as an button. When user clicks on this label, it will show an list of cc users which are belonging with the tickets.
 */
@property (weak, nonatomic) IBOutlet UILabel *viewCCLabel;

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;


@end

