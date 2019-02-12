//
//  MyWebservices.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import "MyWebservices.h"
#import "AppConstanst.h"
#import "AppDelegate.h"
#import "GlobalVariables.h"
#import "Utils.h"


@interface MyWebservices(){
    
    NSString *tokenRefreshed;
    GlobalVariables *globalVariables;
    Utils *utils;
}
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@end


@implementation MyWebservices


+ (instancetype)sharedInstance
{
    static MyWebservices *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MyWebservices alloc] init];
        NSLog(@"SingleTon-MYwebserves");
    });
    return sharedInstance;
}


-(NSString*)refreshToken{
    NSLog(@"Thread--refreshToken()");
    
    dispatch_semaphore_t sem;
    __block NSString *result=nil;
    sem = dispatch_semaphore_create(0);
    
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    //http://servicedesk.ml/helpdeskadvance/public
   // NSString *url=[NSString stringWithFormat:@"%@/api/v1/authenticate",@"https://support.faveohelpdesk.com"];
     NSString *url=[NSString stringWithFormat:@"%@/api/v1/authenticate",@"http://servicedesk.ml/helpdeskadvance/public"];
    
    NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:[_userDefaults objectForKey:@"username"],@"username",[_userDefaults objectForKey:@"password"],@"password",API_KEY,@"api_key",IP,@"ip",nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    
    //[request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:45.0];
    
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil]];
    [request setHTTPMethod:@"POST"];
    
    //    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
    
    NSURLSession *session=[NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Thread--refreshToken error: %@", error);
            return ;
        }
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            
            
            NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"Thread--refreshToken--Get your response == %@", replyStr);
            
            if([replyStr hasPrefix:@"<!DOCTYPE html>"] || [replyStr containsString:@"<!DOCTYPE html>"] || [replyStr hasSuffix:@"<!DOCTYPE html>"])
            {
                NSString * msg = @"urlchanged";
                
                [self->_userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
                NSLog(@"Thread--token-Not-Refreshed");
                
            }
            else
                if ([replyStr containsString:@"success"] || [replyStr containsString:@"data"] || [replyStr containsString:@"result"]) {
                    
                    NSError *error=nil;
                    NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    if (error) {
                        return;
                    }
                    
                    NSLog(@"JSON Data is : %@",jsonData);
                    NSLog(@"JSON Data is : %@",jsonData);
                    
                    
                    if([replyStr containsString:@"result"])
                    {
                        
                        NSDictionary * erroDict = [jsonData objectForKey:@"result"];
                        NSString *errorMessage = [erroDict objectForKey:@"error"];
                        
                        if([errorMessage isEqualToString:@"Methon not allowed"])
                        {
                            NSString *msg =@"Methon not allowed";
                            [self->_userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
                        }
                        
                    }
                    else  if([replyStr containsString:@"message"])
                    {
                        NSString *msg=[jsonData objectForKey:@"message"];
                        
                        
                        if([msg isEqualToString:@"Invalid credentials"])
                        {
                            [self->_userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
                        }
                        
                        else if([msg isEqualToString:@"API disabled"])
                        {
                            [self->_userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
                        }
                        
                    }
                    else{
                        NSDictionary *userDataDict=[jsonData objectForKey:@"data"];
                        
                        
                        NSString *tokenString=[NSString stringWithFormat:@"%@",[userDataDict objectForKey:@"token"]];
                        NSLog(@"Token is : %@",tokenString);
                        
                        [self->_userDefaults setObject:tokenString forKey:@"token"];
                        
                        
                        
                        NSDictionary *userDetailsDict=[userDataDict objectForKey:@"user"];
                        NSLog(@"Data is: %@",userDetailsDict);
                        
                        NSString * userId=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"id"]];
                        
                        NSString * email=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"email"]];
                        NSString * userName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"user_name"]];
                        NSString * firstName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"first_name"]];
                        NSString * lastName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"last_name"]];
                        
                        NSString * userProfilePic=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"profile_pic"]];
                        
                        [self->_userDefaults setObject:email forKey:@"user_email"];
                        [self->_userDefaults setObject:userName forKey:@"userName"];
                        [self->_userDefaults setObject:firstName forKey:@"user_FirstName"];
                        [self->_userDefaults setObject:lastName forKey:@"user_LasttName"];
                        [self->_userDefaults setObject:userProfilePic forKey:@"profile_pic"];
                        
                        NSString *role123=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"role"]];//role
                        NSLog(@"Role from Web Services class : %@",role123);
                        
                        [self->_userDefaults setObject:role123 forKey:@"msgFromRefreshToken"];
                        
                        [self->_userDefaults setObject:userId forKey:@"user_id"];
                        
                        [self->_userDefaults synchronize];
                        self->globalVariables=[GlobalVariables sharedInstance];
                        
                        result=@"tokenRefreshed";
                        NSLog(@"Thread--refreshToken-tokenRefreshed");
                    }
                    
                } //end main if 
            
        } // end response class/method
        
        dispatch_semaphore_signal(sem);
    }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return result;
}


-(void)httpResponsePOST:(NSString *)urlString
              parameter:(id)parameter
        callbackHandler:(callbackHandler)block{
    NSError *err;
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    //    urlString = [urlString stringByReplacingOccurrencesOfString:@"%5B%5D"
    //                                         withString:@"[]"];
    //    NSLog(@"String 11111 is : %@",urlString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Offer-type"];
    [request setTimeoutInterval:45.0];
    
    NSData *postData = nil;
    if ([parameter isKindOfClass:[NSString class]]) {
        postData = [((NSString *)parameter) dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        // postData = [NSJSONSerialization dataWithJSONObject:parameter options:0 error:&err];
        
        postData = [NSJSONSerialization dataWithJSONObject:parameter options:kNilOptions error:&err];
    }
    [request setHTTPBody:postData];
    //[request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameter options:nil error:&err]];
    
    [request setHTTPMethod:@"POST"];
    //
    NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    NSLog(@"Thread--httpResponsePOST--Request : %@", urlString);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
    
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,nil,nil);
            });
            NSLog(@"dataTaskWithRequest error: %@", [error localizedDescription]);
            
        }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                
                if (statusCode==400) {
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                }else if (statusCode==401)
                {
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                    
                    
                }else
                    if (statusCode==429)
                    {
                        if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(nil,nil,@"tokenRefreshed");
                            });
                            NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                        }else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(nil,nil,@"tokenNotRefreshed");
                            });
                            NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                        }
                        
                        
                    }
                    else
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil, nil,[NSString stringWithFormat:@"Error-%ld",(long)statusCode]);
                        });
                return ;
            }
            
            NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([replyStr containsString:@"token_expired"]) {
                NSLog(@"Thread--httpResponsePOST--token_expired");
                
                if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenRefreshed");
                    });
                    NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenNotRefreshed");
                    });
                    NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                }
                return;
            }
            
            NSError *jsonerror = nil;
            
            id responseData =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonerror];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(jsonerror,responseData,nil);
            });
            
        }
        
    }] resume];
    
}


-(void)httpResponseGET:(NSString *)urlString
             parameter:(id)parameter
       callbackHandler:(callbackHandler)block{
    
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    //[request addValue:@"text/html" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:45.0];
    
    NSData *postData = nil;
    if ([parameter isKindOfClass:[NSString class]]) {
        postData = [((NSString *)parameter) dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        postData = [NSJSONSerialization dataWithJSONObject:parameter options:0 error:&error];
    }
    [request setHTTPBody:postData];
    
    [request setHTTPMethod:@"GET"];
    
    NSLog(@"Thread--httpResponseGET--Request : %@", urlString);
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        NSLog(@"Response is required : %@",(NSHTTPURLResponse *) response);
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,nil,nil);
            });
            NSLog(@"Thread--httpResponseGET--dataTaskWithRequest error: %@", [error localizedDescription]);
            
        }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"Status code is : %ld",(long)statusCode);
            
            
            
            if (statusCode != 200) {
                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                
                if (statusCode==400) {
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                }else if (statusCode==401){
                    
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                } else
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, nil,[NSString stringWithFormat:@"Error-%ld",(long)statusCode]);
                    });
                return ;
            }
            
            NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([replyStr containsString:@"token_expired"]) {
                NSLog(@"Thread--httpResponseGET--token_expired");
                
                if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenRefreshed");
                    });
                    NSLog(@"Thread--httpResponseGET--tokenRefreshed");
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenNotRefreshed");
                    });
                    NSLog(@"Thread--httpResponseGET--tokenNotRefreshed");
                }
                return;
            }
            
            NSError *jsonerror = nil;
            id responseData =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(jsonerror,responseData,nil);
            });
            
        }
    }] resume];
    
}




-(void)callPATCHAPIWithAPIName:(NSString *)urlString
                     parameter:(id)parameter
               callbackHandler:(callbackHandler)block{
    NSError *err;
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)request] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Offer-type"];
    [request setTimeoutInterval:45.0];
    
    NSData *postData = nil;
    if ([parameter isKindOfClass:[NSString class]]) {
        postData = [((NSString *)parameter) dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        // postData = [NSJSONSerialization dataWithJSONObject:parameter options:0 error:&err];
        
        postData = [NSJSONSerialization dataWithJSONObject:parameter options:kNilOptions error:&err];
    }
    [request setHTTPBody:postData];
    //[request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameter options:nil error:&err]];
    
    [request setHTTPMethod:@"PATCH"];
    
    //
    NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    NSLog(@"Thread--httpResponsePOST--Request : %@", urlString);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
    
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,nil,nil);
            });
            NSLog(@"dataTaskWithRequest error: %@", [error localizedDescription]);
            
        }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                
                if (statusCode==400) {
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                }else if (statusCode==401)
                {
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                    
                    
                }
                else
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, nil,[NSString stringWithFormat:@"Error-%ld",(long)statusCode]);
                    });
                return ;
            }
            
            NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([replyStr containsString:@"token_expired"]) {
                NSLog(@"Thread--httpResponsePOST--token_expired");
                
                if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenRefreshed");
                    });
                    NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenNotRefreshed");
                    });
                    NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                }
                return;
            }
            
            NSError *jsonerror = nil;
            
            id responseData =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonerror];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(jsonerror,responseData,nil);
            });
            
        }
        
    }] resume];
}


-(void)getNextPageURLInboxSearchResults:(NSString*)url searchString:(NSString*)searchData pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block;
{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    
    NSLog(@"Search data is : %@",searchData);
    //    _userDefaults=[NSUserDefaults standardUserDefaults];
    //   // NSString *urll=[NSString stringWithFormat:@"%@&api_key=%@&ip=%@&token=%@",url,API_KEY,IP,[_userDefaults objectForKey:@"token"]];
    NSLog(@"page isssss : %@",pageInt);
    
    NSString *urlAAA= [url stringByAppendingString:@"?page="];
    NSString *urlBBB= [urlAAA stringByAppendingString:pageInt];
    NSString *urlccc= [urlBBB stringByAppendingString:[NSString stringWithFormat:@"&search=%@",searchData]];
    // NSLog(@"url of search next view is 11 : %@",urlccc);
    
    NSString *finalUrl=[NSString stringWithFormat:@"%@&token=%@",urlccc,[_userDefaults objectForKey:@"token"]];
    NSLog(@"FInal 111111111 url : %@",finalUrl);
    
    [self httpResponseGET:finalUrl parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
    
}



















@end
