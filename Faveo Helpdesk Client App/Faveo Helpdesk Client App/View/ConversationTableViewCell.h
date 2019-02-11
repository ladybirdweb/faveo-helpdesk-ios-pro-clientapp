//
//  ConversationTableViewCell.h
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConversationTableViewCellDelegate;

@interface ConversationTableViewCell : UITableViewCell

@property (assign, nonatomic) id < ConversationTableViewCellDelegate > delegate;

@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;

@property (weak, nonatomic) IBOutlet UILabel *clientNameLabel;

/*!
 @property internalNoteLabel
 
 @brief It is label used for definig name of internal note.
 */
@property (weak, nonatomic) IBOutlet UILabel *internalNoteLabel;

/*!
 @property timeStampLabel
 
 @brief It is label used for definig name of time stamp.
 */
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;

/*!
 @method setUserProfileimage
 
 @param imageUrl This in an url which in string format.
 
 @discussion This method used for displaying a profile picture of a user. It uses a url, and from that url it takes an image and displayed in view.
 
 @code
 [self.profilePicView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
 placeholderImage:[UIImage imageNamed:@"default_pic.png"]];

 */
-(void)setUserProfileimage:(NSString*)imageUrl;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *view1;
- (IBAction)clickedOnAttachment:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *attachImage;

@property (weak, nonatomic) IBOutlet UIButton *attachButtonLabel;

@end

@protocol ConversationTableViewCellDelegate <NSObject>

@optional

- (void)buttonTouchedForCell:(ConversationTableViewCell *)cell;



@end