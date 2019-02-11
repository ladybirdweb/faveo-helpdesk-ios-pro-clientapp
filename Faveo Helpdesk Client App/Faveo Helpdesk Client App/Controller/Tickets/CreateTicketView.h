//
//  CreateTicketView.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>

/*!
 @class CreateTicketView
 
 @brief This class contain Ticket  create process.
 
 @discussion Here  we can create a ticket by filling some necessary information. After filling valid infomation, ticket will be crated.
 */
@interface CreateTicketView : UITableViewController


/*!
 @property messageTextView
 
 @brief It is textView property that allows a user to enter message for the ticket.
 */
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

/*!
 @property subjectTextView
 
 @brief It is textView property that allows a user to enter subject for the ticket.
 */
@property (weak, nonatomic) IBOutlet UITextView *subjectTextView;

/*!
 @property priorityTextField
 
 @brief It is textView property that allows a user to select ticket priority
 */
@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

/*!
 @property helptopicTextField
 
 @brief It is textView property that allows a user to select helptopic
 */
@property (weak, nonatomic) IBOutlet UITextField *helptopicTextField;

/*!
 @property submitButtonOutlet
 
 @brief It is button property.
 */
@property (weak, nonatomic) IBOutlet UIButton *submitButtonOutlet;


/*!
 @property countryDic
 
 @brief This is Dictionary that represents list of Country Names.
 
 @discussion An object representing a static collection of key-value pairs, for use instead ofa Dictionary constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSDictionary * countryDic;

/*!
 @property staffArray
 
 @brief This is array that represents list of Agent Lists.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSMutableArray * staffArray;

/*!
 @property codeArray
 
 @brief This is array that represents list of Country Codes.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * codeArray;

/*!
 @property countryArray
 
 @brief This is array that represents list of Country names.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * countryArray;

/*!
 @property priorityArray
 
 @brief This is array that represents list of Priorities.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * priorityArray;

/*!
 @property helptopicsArray
 
 @brief This is array that represents list of Help Topics.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * helptopicsArray;


//UIImageView *fileImage;
// UILabel *fileName123;
//UILabel *fileSize123;


/*!
 @property fileImage
 
 @brief This is an Image Property.
 
 @discussion This is used to show an icon (attachment type) of selected attachment.
 */
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;


/*!
 @property fileName123
 
 @brief This is an Label Property.
 
 @discussion This is used to show file name of the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *fileName123;

/*!
 @property fileSize123
 
 @brief This is an Label Property.
 
 @discussion This is used to show file size of the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *fileSize123;

/*!
 @method priorityClicked
 
 @brief This will gives List of Ticket Priorities.
 
 @discussion After clicking this button whatever we done any chnages in ticket, it will save and updated in ticket details.
 
 @code
 
 - (IBAction)priorityClicked:(id)sender;
 
 @endocde
 */
- (IBAction)priorityClicked:(id)sender;

/*!
 @method helpTopicClicked
 
 @brief It will gives List of Help Topics.
 
 @discussion After clicking this button it will show list of help topics.
 
 The help topics can be Support Query, Sales Query or Operational Query.
 
 @code
 
 - (IBAction)helpTopicClicked:(id)sender;
 
 @endcode
 
 */
- (IBAction)helptopicClicked:(id)sender;


/*!
 @method submitClicked
 
 @brief This is an button that perform an action.
 
 @discussion  After cicking this submit button, the data enetered in textfiled while ticket creation will be saved.
 
 @code
 
 - (IBAction)submitClicked:(id)sender;
 
 @endcode
 
 */
- (IBAction)submitButtonClicked:(id)sender;


@end
