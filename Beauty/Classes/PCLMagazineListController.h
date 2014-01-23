//
//  PCLMagazineListController.h
//  PCLady
//
//  Created by  Michael on 10/27/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCLMagazineListController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSDictionary *magazineInfo;
    UITableView *pageTable;
    UIView *bottomOptionView;
    UIImageView *logoView;
    
    BOOL imageLoadingDone;
    NSTimer *imageLoadingTimer;
    
    NSString *searchStr;
}

@property (nonatomic, strong) NSString *searchStr;

- (id)initWithMagazineInfo:(NSDictionary *)dict;

@end
