//
//  GlobalVariables.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class GlobalVariables
 
 @brief This class contains Global variable declaration
 
 @discussion It contains variable declaration that are commonly used throughout the app so that accessing and calling is very easy.
 Also it cointans Singleton class that contains global variables and global functions.It’s an extremely powerful way to share data between different parts of code without having to pass the data around manually.
 
 @superclass NSObject
 
 */
@interface GlobalVariables : NSObject


/*!
 @property ticket_id
 
 @brief It is used for defining is id of a ticket.
 */
@property (strong, nonatomic) NSNumber *ticket_id;

/*!
 @property first_name
 
 @brief It is used for defining the first name of user
 */
@property (strong, nonatomic) NSString *first_name;

/*!
 @property last_name
 
 @brief It is used for defining the last name of user
 */
@property (strong, nonatomic) NSString *last_name;

/*!
 @property ticket_number
 
 @brief It is used for defining the ticket number
 */
@property (strong, nonatomic) NSString *ticket_number;

/*!
 @property ticket_status
 
 @brief It is used for defining the status of the ticket.
 */
@property (strong, nonatomic) NSString *ticket_status;

/*!
 @property mobile_code
 
 @brief It is used for defining the mobile code
 */
@property (strong, nonatomic) NSString *mobile_code;


/*!
 @property openTicketsCount
 
 @brief It is used for defining count of open tickets
 */
@property (strong, nonatomic) NSString *openTicketsCount;

/*!
 @property closedTicketsCount
 
 @brief It is used for defining count of closed tickets
 */
@property (strong, nonatomic) NSString *closedTicketsCount;

@property (strong, nonatomic) NSString *OpenStausId;
@property (strong, nonatomic) NSString *ClosedStausId;

/*!
 @property OpenStausLabel
 
 @brief It is used for defining label for open ticket
 */
@property (strong, nonatomic) NSString *OpenStausLabel;

/*!
 @property ClosedStausLabel
 
 @brief It is used for defining label for closed ticket
 */
@property (strong, nonatomic) NSString *ClosedStausLabel;


/*!
 @property ClosedStausLabel
 
 @brief It is dictionary propert used to store values like Agents list, Ticket Status, Ticket counts, Ticket Source, SLA ..etc which are used in various places in project.
 */
@property (strong, nonatomic) NSDictionary *dependencyDataDict;

@property (strong, nonatomic) NSMutableArray *attachArrayFromConversation;

/*!
 @property ClosedStausLabel
 
 @brief It is string property used to store app url for internal use purpose
 */
@property (strong, nonatomic) NSString *appURL;



/*!
 @method sharedInstance
 
 @discussion A singleton object provides a global point of access to the resources of its class. Singletons are used in situations where this single point of control is desirable, such as with classes that offer some general service or resource. You obtain the global instance from a singleton class through a factory method.
 */
+ (instancetype)sharedInstance;


@end
