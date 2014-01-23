//
//  PCLMagazineScanView.h
//  PCLady
//
//  Created by  Michael on 10/26/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODRefreshControl.h"

@interface PCLMagazineScanView : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSDictionary *magazineInfo;
    UIScrollView *pageScroll;
    UIView *pageSelectView;
    UIScrollView *page;
    BOOL isPageShowing;
    NSInteger selectedPage;
    
    NSArray *articlesArray;
    
    UIScrollView *lastScrollView;
    NSMutableDictionary *imageLoadingDict;
    
    NSTimer *imageLoadingTimer;

    NSMutableDictionary *pagingDict;
    
    UIView *bottomOptionView;
    UIImageView *logoView;
    ODRefreshControl *refreshView;
    BOOL looseLoadMore;
    BOOL isSearchResult;
}

@property (nonatomic) NSInteger selectedPage;
@property (nonatomic, assign) BOOL isSearchResult;

- (id)initWithMagazineInfo:(NSDictionary *)dict;

@end
