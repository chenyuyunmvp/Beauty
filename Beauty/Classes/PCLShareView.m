//
//  PCLShareView.m
//  Beauty
//
//  Created by  Michael on 1/18/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "PCLShareView.h"
#import "Constants.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import "PCLCommonController.h"

static const CGFloat ShareOptionHeight = 160.f;

@implementation PCLShareView
@synthesize labelTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = RGB_COLOR(24, 21, 18, 1.f);
        UIImage *logoImage = [UIImage imageNamed:@"Logo"];
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 20.f, logoImage.size.width, logoImage.size.height)];
        logoView.image = logoImage;
        logoView.backgroundColor = [UIColor clearColor];
        [self addSubview:logoView];
        
        shareView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, frame.size.width, ShareOptionHeight)];
        shareView.backgroundColor = [UIColor blackColor];
        shareView.opaque = 1.0f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320.f, ShareOptionHeight)];
        imageView.image = [UIImage imageNamed:@"share-bg"];
        [shareView addSubview:imageView];
        
        [self addSubview:shareView];
        shareView.alpha = 1.0f;
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 48.f)];
        [shareView addSubview:titleView];
        
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 0, frame.size.width-80.f, 48.f)];
        labelTitle.font = [UIFont systemFontOfSize:18.f];
        labelTitle.backgroundColor = [UIColor clearColor];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.textAlignment = NSTextAlignmentCenter;
        labelTitle.text = @"分享杂志";
        [titleView addSubview:labelTitle];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *closeImage = [UIImage imageNamed:@"Close"];
        [cancelBtn setImage:closeImage forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(frame.size.width-closeImage.size.width-10.f, (48.f-closeImage.size.height)/2, closeImage.size.width, closeImage.size.height);
        [cancelBtn addTarget:self action:@selector(cancelView:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:cancelBtn];
        
        UIView *optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 48.f, frame.size.width, ShareOptionHeight-48.f)];
        [shareView addSubview:optionView];
        
        UIButton *weChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *weChatImage = [UIImage imageNamed:@"WeChat"];
        [weChatBtn setImage:weChatImage forState:UIControlStateNormal];
        weChatBtn.frame = CGRectMake(76.f, (ShareOptionHeight-weChatImage.size.height-48.f)/2, weChatImage.size.width, weChatImage.size.height);
        [weChatBtn addTarget:self action:@selector(weChatShare:) forControlEvents:UIControlEventTouchUpInside];
        [optionView addSubview:weChatBtn];
        
        UIButton *sinaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *sinaBtnImage = [UIImage imageNamed:@"Sina"];
        [sinaBtn setImage:sinaBtnImage forState:UIControlStateNormal];
        sinaBtn.frame = CGRectMake(178.f, (ShareOptionHeight-sinaBtnImage.size.height-48.f)/2, sinaBtnImage.size.width, sinaBtnImage.size.height);
        [sinaBtn addTarget:self action:@selector(sinaShare:) forControlEvents:UIControlEventTouchUpInside];
        [optionView addSubview:sinaBtn];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 0.95f;
            shareView.frame = CGRectMake(0, screenHeight-ShareOptionHeight, frame.size.width, ShareOptionHeight);
        } completion:^(BOOL finished) {
            
        }];
    }
    return self;
}

- (void)cancelView:(UIButton *)btn {
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
        shareView.frame = CGRectMake(0, screenHeight, self.frame.size.width, ShareOptionHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)weChatShare:(UIButton *)btn {
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
        shareView.frame = CGRectMake(0, screenHeight, self.frame.size.width, ShareOptionHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weibo://"]])
    {
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.text = @"测试微信sdk发送文字到weChat!";
        req.bText = YES;
        req.scene = WXSceneSession;
        
        [WXApi sendReq:req];
    } else {
        [[PCLCommonController sharedInstance] showAlertMessage:@"请确认已安装微信客户端."];
    }
}

- (void)sinaShare:(UIButton *)btn {
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
        shareView.frame = CGRectMake(0, screenHeight, self.frame.size.width, ShareOptionHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = @"测试通过WeiboSDK发送文字到微博!";
    
//    WBProvideMessageForWeiboResponse *response = [WBProvideMessageForWeiboResponse responseWithMessage:message];
//    WBWebpageObject *webpage = [WBWebpageObject object];
//    webpage.objectID = @"identifier1";
//    webpage.title = @"分享网页标题";
//    webpage.description = [NSString stringWithFormat:@"分享网页内容简介-%.0f", [[NSDate date] timeIntervalSince1970]];
//    webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg" ofType:@"png"]];
//    webpage.webpageUrl = @"http://sina.cn?a=1";
//    message.mediaObject = webpage;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weibo://"]])
    {
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
//        request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
//                             @"Other_Info_1": [NSNumber numberWithInt:123],
//                             @"Other_Info_2": @[@"obj1", @"obj2"],
//                             @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    
        [WeiboSDK sendRequest:request];
    } else {
        [[PCLCommonController sharedInstance] showAlertMessage:@"请确认已安装新浪微博客户端."];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
