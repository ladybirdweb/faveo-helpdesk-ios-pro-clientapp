
//
//  AppConstant.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//





#ifndef AppConstanst_h
#define AppConstanst_h

#define APP_NAME    @"Faveo Helpdesk"
#define ALERT_COLOR    @"#FFCC00"
#define SUCCESS_COLOR    @"#4CD964"
#define FAILURE_COLOR    @"#d50000"
#define APP_URL    @""
#define API_KEY @""
#define NO_INTERNET @"There is no Internet Connection"
#define IP @""
#define APP_VERSION @"1.0"

#define BILLING_API @"https://billing.faveohelpdesk.com/api/check-url"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#endif /* AppConstanst_h */

