//
//  PCLCommonController.h
//  PCLady
//
//  Created by  Michael on 11/5/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define progressHudTag      99

@interface PCLCommonController : NSObject

+ (PCLCommonController *)sharedInstance;
- (void)showLoadingView:(UIView *)view text:(NSString *)str;
- (void)hideLoadingView:(UIView *)view;
- (void)showAlertMessage:(NSString *)alertMessage;

@end
