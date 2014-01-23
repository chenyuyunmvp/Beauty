//
//  PCLMainController.h
//  PCLady
//
//  Created by  Michael on 10/13/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CycleScrollView.h"

@interface PCLMainController : UIViewController <UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSArray *magazineArray;
    NSMutableArray *magazineListArray;
    NSMutableArray *cycleImagesArray;
    UIScrollView *magazineListScroll;
    UIButton *downloadButton;
    UIButton *cancelSearchButton;

    NSMutableArray *allItems;
    NSMutableArray *searchResults;
    NSMutableDictionary *loadingDict;
    
    NSTimer *loadingTimer;
    UITableView *resultsTable;
    NSTimer *imageLoadingTimer;
    NSInteger selectedIndex;
    
    NSString *keySearchStr;
}

@end
