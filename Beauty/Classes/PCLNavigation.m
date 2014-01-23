//
//  PCLNavigation.m
//  PCLady
//
//  Created by  Michael on 11/11/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLNavigation.h"

#define NavigationTitleTag          500
#define NavigationImageTag          501

@implementation UINavigationController (Category)

- (void)NavigateWithBackgroundImage:(UIImage *)img {
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationBar setBackgroundImage:[img stretchableImageWithLeftCapWidth:5 topCapHeight:5] forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationBar.barTintColor = RGB_COLOR(98, 165, 224, 1.f);

    CGRect frame = self.navigationBar.frame;
    UILabel *label = (UILabel *)[self.navigationBar viewWithTag:NavigationTitleTag];
    if (nil != label) {
        [label removeFromSuperview];
    }
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
    label.font = [UIFont systemFontOfSize:18.f];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = NavigationTitleTag;
    [self.navigationBar addSubview:label];
    
    UIImageView *imageView = (UIImageView *)[self.navigationBar viewWithTag:NavigationImageTag];
    if (nil != imageView) {
        [imageView removeFromSuperview];
    }
    UIImage *image = [UIImage imageNamed:@"Logo-Small"];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = NavigationImageTag;
    imageView.hidden = YES;
    imageView.frame = CGRectMake((frame.size.width-image.size.width)/2, (frame.size.height-image.size.height)/2, image.size.width, image.size.height);
    [self.navigationBar addSubview:imageView];
    
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)setNavigationTitle:(NSString *)title {
    CGRect frame = self.navigationBar.frame;
    UILabel *label = (UILabel *)[self.navigationBar viewWithTag:NavigationTitleTag];
    label.text = title;
    CGSize size = [title sizeWithFont:label.font constrainedToSize:CGSizeMake(frame.size.width, frame.size.height)];
    label.frame = CGRectMake((frame.size.width-size.width)/2, 0, size.width, frame.size.height);
    
    UIImageView *imageView = (UIImageView *)[self.navigationBar viewWithTag:NavigationImageTag];
    UIImage *image = [UIImage imageNamed:@"Logo-Small"];
    imageView.image = image;
    imageView.frame = CGRectMake((label.frame.origin.x-image.size.width-5), (frame.size.height-image.size.height)/2, image.size.width, image.size.height);
    if (title.length > 0) {
        imageView.hidden = NO;
        label.hidden = NO;
    } else {
        imageView.hidden = YES;
        label.hidden = YES;
    }
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
}

@end
