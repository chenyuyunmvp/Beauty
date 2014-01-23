//
//  TKOWActivity.m
//  Tapatalk
//
//  Created by Luo Hui on 13-7-2.
//
//

#import "TKOWActivity.h"
#import "OWActivityViewController.h"

@implementation TKOWActivity

- (id)initWithTitle:(NSString *)title image:(UIImage *)image actionBlock:(OWActivityActionBlock)actionBlock
{
    UIImage * backgroundImg = [UIImage imageNamed:@"SlideButtonBackgroundOW"];
    // maybe @2x
    CGFloat scale = backgroundImg.scale;
    CGSize size = backgroundImg.size;
    size.height *= scale;
    size.width *= scale;
    
    CGFloat scale2 = image.scale;
    CGSize size2 = image.size;
    size2.height *= scale2;
    size2.width *= scale2;
    
    UIGraphicsBeginImageContext(size);
    //Draw backgroundImg
    [backgroundImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //Draw image
    [image drawInRect:CGRectMake((size.width-size2.width)/2,
                                 (size.height-size2.height)/2,
                                 size2.width,
                                 size2.height)];
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    OWActivityActionBlock newBlock =
    ^(OWActivity *activity, OWActivityViewController *activityViewController){
        [activityViewController dismissViewControllerAnimated:YES completion:nil];
        if (actionBlock) {
            if ([activity.title isEqualToString:@"Web View"]) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    actionBlock(activity,activityViewController);
                });
            } else {
                actionBlock(activity,activityViewController);
            }
        }
    };
    self = [super initWithTitle:title image:resultImage actionBlock:newBlock];
    if (self) {
    }
    return self;
}
@end
