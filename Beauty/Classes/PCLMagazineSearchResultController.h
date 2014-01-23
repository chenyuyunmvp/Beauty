//
//  PCLMagazineSearchResultController.h
//  Beauty
//
//  Created by  Michael on 1/18/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCLMagazineSearchResultController : UIViewController <UIScrollViewDelegate> {
    NSDictionary *magazineInfoDict;
    
    UIButton *downloadBtn;
    NSString *keySearchStr;
}

@property (nonatomic, strong) NSString *keySearchStr;

- (id)initWithInfo:(NSDictionary *)dict;

@end
