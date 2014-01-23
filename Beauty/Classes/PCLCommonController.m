//
//  PCLCommonController.m
//  PCLady
//
//  Created by  Michael on 11/5/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLCommonController.h"
#import "UIImage+animatedGIF.h"

@interface PCLCommonController ()

@end


static PCLCommonController *sharedInstance = nil;

@implementation PCLCommonController

+ (PCLCommonController *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)showLoadingView:(UIView *)view text:(NSString *)str {
//    MBProgressHUD *progressHud = (MBProgressHUD *)[view viewWithTag:progressHudTag];
//    if (nil != progressHud) {
//        return;
//    }
//    progressHud = [[MBProgressHUD alloc] initWithView:view];
//    progressHud.tag = progressHudTag;
//    progressHud.labelText = str;
//    [view addSubview:progressHud];
//    [progressHud show:YES];
    
    UIView *tipView = (UIView *)[view viewWithTag:progressHudTag];
    if (nil != tipView) {
        [tipView removeFromSuperview];
    }
    
    tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    tipView.backgroundColor = RGB_COLOR(38, 38, 38, 0.9f);
    tipView.tag = progressHudTag;
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mmbbzxlogo@2x" ofType:@"gif"]];
    UIImage *image = [UIImage animatedImageWithAnimatedGIFData:data];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;
    imageView.frame = CGRectMake((view.frame.size.width-image.size.width)/2, (view.frame.size.height-image.size.height)/2, image.size.width, image.size.height);
    [tipView addSubview:imageView];
    
    [view addSubview:tipView];
}

- (void)hideLoadingView:(UIView *)view {
    UIView *tipView = (UIView *)[view viewWithTag:progressHudTag];
    [UIView animateWithDuration:0.3f animations:^{
        tipView.hidden = YES;
    } completion:^(BOOL finished){
        [tipView removeFromSuperview];
    }];
}

- (void)showAlertMessage:(NSString *)alertMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
