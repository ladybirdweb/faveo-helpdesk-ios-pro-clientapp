//
//  ConversationTableViewCell.m
//  Faveo Helpdesk Client App
//
//  Created by Mallikarjun on 23/07/18.
//  Copyright © 2018 Ladybird Web Solution Pvt Ltd. All rights reserved.
//


#import "HexColors.h"
#import "ConversationTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ConversationTableViewCell

@synthesize delegate = _delegate;

- (IBAction)clickedOnAttachment:(id)sender {
    if ([self.delegate respondsToSelector:@selector(buttonTouchedForCell:)])
        [self.delegate buttonTouchedForCell:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//        NSURL *url = [NSURL URLWithString:@"http://www.amazon.com"];
//        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
   

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUserProfileimage:(NSString*)imageUrl
{
   // self.profilePicView.layer.borderWidth=1.25f;
    self.profilePicView.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    [self.profilePicView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                           placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    

}

//- (IBAction)clickedOnAttachment:(id)sender {
//    
//    
//}
@end
