//
//  GlobalVariables.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "GlobalVariables.h"

@implementation GlobalVariables


+ (instancetype)sharedInstance
{
    static GlobalVariables *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GlobalVariables alloc] init];
        NSLog(@"SingleTon-GlobalVariables");
    });
    return sharedInstance;
}


@end
