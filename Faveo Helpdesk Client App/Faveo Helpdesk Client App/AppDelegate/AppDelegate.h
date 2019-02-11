//
//  AppDelegate.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class AppDelegate
 
 @brief This is a class class that receives application-level messages, including the applicationDidFinishLaunching message most commonly used to initiate the creation of other views.
 
 @discussion The app delegate works alongside the app object to ensure your app interacts properly with the system and with other apps. Specifically, the methods of the app delegate give you a chance to respond to important changes. For example, you use the methods of the app delegate to respond to state transitions, such as when your app moves from foreground to background execution, and to respond to incoming notifications.
 In many cases, the methods of the app delegate are the only way to receive these important notifications.
 
 */
@interface AppDelegate : UIResponder <UIApplicationDelegate>

/*!
 @property window
 
 @brief An object that provides the backdrop for your app’s user interface and provides important event-handling behaviors.
 */
@property (strong, nonatomic) UIWindow *window;


@end

