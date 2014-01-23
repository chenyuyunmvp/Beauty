//  PCLMainController.m
//  PCLady
//
//  Created by  Michael on 10/13/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLMainController.h"
#import "PCLMagazineScanView.h"
#import "PCLMagazineListController.h"
#import "Constants.h"
#import "PCLCommonController.h"
#import "PCLNavigation.h"
#import "PCLDataRequest.h"
#import "PCLImageLoader.h"
#import "PCLCacheManager.h"
#import "ZipArchive.h"
#import "PCLDataRequest.h"
#import "UIImage+animatedGIF.h"
#import "PCLMagazineSearchResultController.h"

#define MagazineListTag         1000
#define MagazineClickBtnTag     2000
#define MagazineDownloadBtnTag  3000
#define cellImageTag            4000
#define cancelSearchBtnTag      5000

static const CGFloat itemImageWidth = 294.f;
static const CGFloat itemGap = 14.f;
static const CGFloat itemBorderWidth = 5.f;
static const CGFloat itemTopIndent = 24.f;
static const CGFloat itemLeftIndent = 12.f;
static const CGFloat itemDownloadButtonViewHeight = 85.f;
static const CGFloat itemDownloadButtonHeight = 50.f;
static const CGFloat itemDownloadButtonWidth = 320.f;


@interface PCLMainController ()

@property(nonatomic, strong, readwrite) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchDisplayController *searchDisplay;

@end

@implementation PCLMainController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        [[PCLCacheManager sharedInstance] clearCache];
        // Custom initialization
//        self.title = @"Beauty";
        [self.navigationController setNavigationTitle:@"Beauty"];
        cycleImagesArray = [[NSMutableArray alloc] init];
        searchResults = [[NSMutableArray alloc] init];
        allItems = [[NSMutableArray alloc] init];
        loadingDict = [[NSMutableDictionary alloc] init];
        magazineListArray = [[NSMutableArray alloc] init];
        keySearchStr = @"";

//        NSString *item = @"";
//        for (int i = 0; i < 50; i++) {
//            item = [NSString stringWithFormat:@"magazine %d", i];
//            item = [NSDictionary dictionaryWithObjectsAndKeys:@"testes", @"row_image", nil];
//            [magazineListArray addObject:item];
//        }
        
        //Handle keyboard UI change
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (onIOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.navigationController NavigateWithBackgroundImage:[UIImage imageNamed:@"Top-Navbar-BG"]];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.placeholder = @"搜索";
    self.searchBar.delegate = self;
    [self.navigationController.navigationBar addSubview:self.searchBar];
    self.searchBar.hidden = YES;
    cancelSearchButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelSearchButton.tag = cancelSearchBtnTag;
    [cancelSearchButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelSearchButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [cancelSearchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelSearchButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [cancelSearchButton addTarget:self action:@selector(resignSearch) forControlEvents:UIControlEventTouchUpInside];
    cancelSearchButton.hidden = YES;
    [self.navigationController.navigationBar addSubview:cancelSearchButton];
    
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    self.searchDisplay.delegate = self;
    self.searchDisplay.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplay.searchResultsTableView.showsVerticalScrollIndicator = NO;
    
    resultsTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    resultsTable.delegate = self;
    resultsTable.dataSource = self;
//    [self.view addSubview:resultsTable];
    resultsTable.hidden = YES;
    
    NSArray *array = [[PCLCacheManager sharedInstance] LoadArrayWithKey:MagazineListKey];
    if (nil != array) {
        magazineArray = [NSArray arrayWithArray:array];
        [self reloadList];
        [NSThread detachNewThreadSelector:@selector(getListThread) toTarget:self withObject:nil];
    } else {
        [[PCLCommonController sharedInstance] showLoadingView:self.navigationController.view text:@"下载中..."];
        [NSThread detachNewThreadSelector:@selector(getListThread) toTarget:self withObject:nil];
    }
    
    loadingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setDownloadBtnState) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self resignSearchState];
    
    self.searchBar.frame = CGRectMake(0, 0, 240, 44.f);
    self.searchBar.tintColor = [UIColor blackColor];
    cancelSearchButton.frame = CGRectMake(250, 0, 50, 44.f);
    resultsTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController NavigateWithBackgroundImage:[UIImage imageNamed:@"Top-Navbar-BG"]];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search-Button"] style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    self.navigationItem.leftBarButtonItem = left;
    left.tintColor = [UIColor whiteColor];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings-Button"] style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    right.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = right;
    
    CGPoint offset = magazineListScroll.contentOffset;
    NSInteger index = offset.x / 320;
    [self.navigationController setNavigationTitle:[[magazineArray objectAtIndex:index] objectForKey:@"title"]];
    
    NSDictionary *magazineListDict = nil;
    NSString *token = nil;
    NSArray *articles = nil;
    NSString *title = nil;
    [magazineListArray removeAllObjects];
    for (NSDictionary *dict in magazineArray) {
        token = [dict objectForKey:@"token"];
        magazineListDict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, token]];
        articles = [magazineListDict objectForKey:@"articles"];
        for (int i = 0; i < articles.count; i++) {
            NSDictionary *tmpDict = [articles objectAtIndex:i];
            title = [[[tmpDict objectForKey:@"pages"] objectAtIndex:0] objectForKey:@"title"];
            if (nil != title) {
                NSMutableDictionary *article = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
                [article setObject:title forKey:@"title"];
                [article setObject:token forKey:@"magazine_token"];
                [article setObject:[NSNumber numberWithInt:i] forKey:@"index"];
                [magazineListArray addObject:article];
            }
        }
    }
    
//    NSLog(@"magazineListArray: %@", magazineListArray);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self resignSearchState];
    [self reloadList];
}

- (void)search {

    self.searchBar.hidden = NO;
    self.searchBar.text = @"";
    cancelSearchButton.hidden = NO;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [self.searchBar becomeFirstResponder];
//    [self.searchBar resignFirstResponder];
    [self.searchDisplay setActive:YES animated:YES];
}

- (void)settings {
    NSLog(@"method: %@", NSStringFromSelector(_cmd));
}

- (void)resignSearch {
    [self reloadList];
    [self resignSearchState];
}

- (void)resignSearchState {
    
    self.searchBar.hidden = YES;
    cancelSearchButton.hidden = YES;
    [self.searchBar resignFirstResponder];
    resultsTable.hidden = YES;
    keySearchStr = @"";
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search-Button"] style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    self.navigationItem.leftBarButtonItem = left;
    left.tintColor = [UIColor whiteColor];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings-Button"] style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    right.tintColor = [UIColor whiteColor];
}

- (void)reloadList {
    
    [[PCLCommonController sharedInstance] hideLoadingView:self.navigationController.view];
    [cycleImagesArray removeAllObjects];
    [self.navigationController setNavigationTitle:[[magazineArray objectAtIndex:0] objectForKey:@"title"]];
    
    [magazineListScroll removeFromSuperview];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight-100.f)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.contentSize = CGSizeMake(320*magazineArray.count, scroll.frame.size.height);
    scroll.tag = MagazineListTag;
    [self.view insertSubview:scroll belowSubview:resultsTable];
    magazineListScroll = scroll;
    
    for (int i = 0; i < magazineArray.count; i++) {
        UIImageView *imageBgView = [[UIImageView alloc] init];
        imageBgView.frame = CGRectMake(itemLeftIndent+i*(itemImageWidth+itemGap*2)-itemBorderWidth, itemTopIndent-itemBorderWidth, itemImageWidth+itemBorderWidth*2, scroll.frame.size.height-itemTopIndent*2);
        imageBgView.image = [UIImage imageNamed:@"Issue-Shadow-Height-Fixed-at-730px"];
        [scroll addSubview:imageBgView];
        
        NSDictionary *dict = [magazineArray objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(itemLeftIndent+i*(itemImageWidth+itemGap*2), itemTopIndent, itemImageWidth, scroll.frame.size.height-itemTopIndent*2-itemBorderWidth*2);
        imageView.image = [UIImage imageNamed:@"bg"];
        [scroll addSubview:imageView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:imageView.frame];
        [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = MagazineClickBtnTag+i;
        [scroll addSubview:button];
        
        NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, [dict objectForKey:@"image"]];
        [[PCLImageLoader sharedInstance] getImage:imageView withUrl:imgUrl];
    }
    
    [downloadButton removeFromSuperview];
    
    UIButton *downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake((320-itemDownloadButtonWidth)/2, scroll.frame.origin.y+scroll.frame.size.height+10.f, itemDownloadButtonWidth, itemDownloadButtonHeight)];
    downloadBtn.frame = CGRectMake(0, self.view.frame.size.height-itemDownloadButtonHeight, self.view.frame.size.width, itemDownloadButtonHeight);
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"Bottom-Navbar"] forState:UIControlStateNormal];
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"Bottom-Navbar"] forState:UIControlStateDisabled];

    [downloadBtn setImage:[UIImage imageNamed:@"BtnDownload"] forState:UIControlStateNormal];
    downloadBtn.tag = MagazineDownloadBtnTag;
    
    NSDictionary *magazineDict = [magazineArray objectAtIndex:0];
    NSString *token = [magazineDict objectForKey:@"token"];
    NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, token]];
    NSArray *array = [self getAllImageList:dict];
    BOOL isLoaded = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
    if (isLoaded) {
        downloadBtn.enabled = NO;
    } else {
    }
    
    downloadBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadBtn];
    
    downloadButton = downloadBtn;
}

- (void)reloadResultView {
    NSMutableDictionary *magazineDict = nil;
    if (searchResults.count > 0) {
        NSDictionary *dict = [searchResults objectAtIndex:0];
        NSDictionary *tempDict = nil;
        for (int i = 0; i < magazineArray.count; i++) {
            tempDict = [magazineArray objectAtIndex:i];
            if ([[tempDict objectForKey:@"token"] isEqualToString:[dict objectForKey:@"magazine_token"]]) {
                magazineDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
                NSString *firstPageImageUrl = [[[dict objectForKey:@"pages"] objectAtIndex:0] objectForKey:@"image"];
                [magazineDict setObject:firstPageImageUrl forKey:@"first_page"];
                break;
            }
        }
    }
    NSMutableArray *tempArray;
    if (keySearchStr.length > 0 && searchResults.count > 0) {
        tempArray = [NSMutableArray arrayWithObjects:magazineDict, nil];
    } else {
        tempArray = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"NotFound", @"first_page", nil], nil];
    }
    
    [magazineListScroll removeFromSuperview];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight-100.f)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.contentSize = CGSizeMake(320*tempArray.count, scroll.frame.size.height);
    scroll.tag = MagazineListTag;
    [self.view insertSubview:scroll belowSubview:resultsTable];
    magazineListScroll = scroll;
    
    for (int i = 0; i < tempArray.count; i++) {
        UIImageView *imageBgView = [[UIImageView alloc] init];
        imageBgView.frame = CGRectMake(itemLeftIndent+i*(itemImageWidth+itemGap*2)-itemBorderWidth, itemTopIndent-itemBorderWidth, itemImageWidth+itemBorderWidth*2, scroll.frame.size.height-itemTopIndent*2);
        imageBgView.image = [UIImage imageNamed:@"Issue-Shadow-Height-Fixed-at-730px"];
        [scroll addSubview:imageBgView];
        
        NSDictionary *dict = [tempArray objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(itemLeftIndent+i*(itemImageWidth+itemGap*2), itemTopIndent, itemImageWidth, scroll.frame.size.height-itemTopIndent*2-itemBorderWidth*2);
        imageView.image = [UIImage imageNamed:@"bg"];
        [scroll addSubview:imageView];
        
        if (searchResults.count > 0) {
            UIButton *button = [[UIButton alloc] initWithFrame:imageView.frame];
            [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = MagazineClickBtnTag+i;
            [scroll addSubview:button];
            
            NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, [dict objectForKey:@"first_page"]];
            [[PCLImageLoader sharedInstance] getImage:imageView withUrl:imgUrl];
            
            CGSize size = [keySearchStr sizeWithFont:[UIFont systemFontOfSize:24.f]];
            if (size.width < 30.f) {
                size.width = 30.f;
            }
            if (size.width > imageView.frame.size.width-40.f) {
                size.width = imageView.frame.size.width-40.f;
            }
            
            size.width += 10.f;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width-size.width-20.f, imageView.frame.size.height-50.f, size.width, 30.f)];
            label.font = [UIFont systemFontOfSize:24.f];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = keySearchStr;
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = RGB_COLOR(254, 93, 93, 1.0f);
            [imageView addSubview:label];
        } else {
            imageView.image = [UIImage imageNamed:@"NotFound"];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 300.f, 240.f, 30.f)];
            if (screenHeight < 500) {
                label.frame = CGRectMake(40.f, 228.f, 240.f, 30.f);
            }
            label.font = [UIFont systemFontOfSize:24.f];
            label.textAlignment = NSTextAlignmentLeft;
            label.text = @"没有找到与";
            label.textColor = RGB_COLOR(100, 100, 100, 1.0f);
            label.backgroundColor = [UIColor clearColor];
            [imageView addSubview:label];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 330.f, 240.f, 40.f)];
            if (screenHeight < 500) {
                label2.frame = CGRectMake(40.f, 258.f, 240.f, 32.f);
            }
            label2.font = [UIFont boldSystemFontOfSize:26.f];
            label2.textAlignment = NSTextAlignmentCenter;
            label2.text = [NSString stringWithFormat:@"“%@”", keySearchStr];
            label2.textColor = [UIColor whiteColor];
            label2.backgroundColor = [UIColor clearColor];
            [imageView addSubview:label2];
            
            UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 370.f, 240.f, 30.f)];
            if (screenHeight < 500) {
                label3.frame = CGRectMake(40.f, 288.f, 240.f, 30.f);
            }
            label3.font = [UIFont systemFontOfSize:24.f];
            label3.textAlignment = NSTextAlignmentRight;
            label3.text = @"相关的文章";
            label3.textColor = [UIColor whiteColor];
            label3.backgroundColor = [UIColor clearColor];
            [imageView addSubview:label3];
        }
    }
    
    [downloadButton removeFromSuperview];
    
    UIButton *downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake((320-itemDownloadButtonWidth)/2, scroll.frame.origin.y+scroll.frame.size.height+10.f, itemDownloadButtonWidth, itemDownloadButtonHeight)];
    downloadBtn.frame = CGRectMake(0, self.view.frame.size.height-itemDownloadButtonHeight, self.view.frame.size.width, itemDownloadButtonHeight);
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"Bottom-Navbar"] forState:UIControlStateNormal];
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"Bottom-Navbar"] forState:UIControlStateDisabled];
    
    [downloadBtn setImage:[UIImage imageNamed:@"BtnDownload"] forState:UIControlStateNormal];
    downloadBtn.tag = MagazineDownloadBtnTag;
    
//    NSDictionary *magazineDict = [magazineArray objectAtIndex:0];
    NSString *token = [magazineDict objectForKey:@"token"];
    NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, token]];
    NSArray *array = [self getAllImageList:dict];
    BOOL isLoaded = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
    if (isLoaded) {
        downloadBtn.enabled = NO;
    } else {
    }
    
    downloadBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadBtn];
    
    downloadButton = downloadBtn;
}

- (void)clickItem:(UIButton *)btn {
    NSInteger index = btn.tag - MagazineClickBtnTag;
    selectedIndex = index;
    
    NSMutableDictionary *magazineInfo = [NSMutableDictionary dictionaryWithDictionary:[magazineArray objectAtIndex:index]];
    NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, [magazineInfo objectForKey:@"token"]]];
    if (dict == nil) {
        [[PCLCommonController sharedInstance] showLoadingView:self.navigationController.view text:@"下载中..."];
        [magazineInfo setObject:@"1" forKey:@"load_first_image"];
        [NSThread detachNewThreadSelector:@selector(getArticleListThread:) toTarget:self withObject:magazineInfo];
    } else {
        magazineInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
        dispatch_async(kBgQueue, ^{
            [self getFirstArticleImage:magazineInfo];
        });
    }
    
    loadingDict = magazineInfo;
}

- (void)download:(UIButton *)btn {
    if (keySearchStr.length > 0) {
        if (searchResults.count == 0) {
            return;
        } else {
            NSDictionary *dict = [searchResults objectAtIndex:0];
            NSDictionary *tempDict = nil;
            NSMutableDictionary *magazineDict;
            for (int i = 0; i < magazineArray.count; i++) {
                tempDict = [magazineArray objectAtIndex:i];
                if ([[tempDict objectForKey:@"token"] isEqualToString:[dict objectForKey:@"magazine_token"]]) {
                    magazineDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
                    NSString *firstPageImageUrl = [[[dict objectForKey:@"pages"] objectAtIndex:0] objectForKey:@"image"];
                    [magazineDict setObject:firstPageImageUrl forKey:@"first_page"];
                    break;
                }
            }
            
            PCLMagazineListController *controller = [[PCLMagazineListController alloc] initWithMagazineInfo:magazineDict];
            controller.searchStr = keySearchStr;
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else {
        CGPoint offset = magazineListScroll.contentOffset;
        NSInteger index = offset.x / 320;
        NSDictionary *magazineDict = [magazineArray objectAtIndex:index];
        NSString *token = [magazineDict objectForKey:@"token"];
        NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, token]];
        NSArray *array = [self getAllImageList:dict];
        BOOL isLoaded = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
        if (isLoaded) {
            PCLMagazineListController *controller = [[PCLMagazineListController alloc] initWithMagazineInfo:[magazineArray objectAtIndex:index]];
            controller.searchStr = keySearchStr;
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"download@2x" ofType:@"gif"]];
            UIImage *image = [UIImage animatedImageWithAnimatedGIFData:data];
            [btn setImage:image forState:UIControlStateNormal];
            
            [loadingDict setObject:@"1" forKey:[NSString stringWithFormat:@"%d", index]];
            
            NSDictionary *listDict = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token", @"1", @"loadingImage", nil];
            NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, token]];
            if (nil == dict) {
                [NSThread detachNewThreadSelector:@selector(getArticleListThread:) toTarget:self withObject:listDict];
            } else {
                [self getArticleImages];
            }
        }
    }
}

- (void)setDownloadBtnState {
    CGPoint offset = magazineListScroll.contentOffset;
    NSInteger index = offset.x / 320;
    NSDictionary *magazineDict = [magazineArray objectAtIndex:index];
    NSString *token = [magazineDict objectForKey:@"token"];
    
    NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, token]];
    BOOL isLoading = NO;
    if (dict == nil) {
        UIButton *button = (UIButton *)[self.view viewWithTag:MagazineDownloadBtnTag];
//        [button setTitle:@"下载" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"BtnDownload"] forState:UIControlStateNormal];
        button.enabled = YES;
    } else {
        NSDictionary *magazineDict = [magazineArray objectAtIndex:index];
        NSString *token = [magazineDict objectForKey:@"token"];
        NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, token]];
        NSArray *array = [self getAllImageList:dict];
        BOOL isLoaded = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
        
        if (isLoaded) {
            UIButton *button = (UIButton *)[self.view viewWithTag:MagazineDownloadBtnTag];
//            [button setTitle:@"已下载" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"Read"] forState:UIControlStateNormal];
            button.enabled = YES;
        } else {
            isLoading = [[loadingDict objectForKey:[NSString stringWithFormat:@"%d", index]] integerValue];
            if (isLoading == 0) {
                UIButton *button = (UIButton *)[self.view viewWithTag:MagazineDownloadBtnTag];
//                [button setTitle:@"下载" forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"BtnDownload"] forState:UIControlStateNormal];
                button.enabled = YES;
            } else {
                UIButton *button = (UIButton *)[self.view viewWithTag:MagazineDownloadBtnTag];
//                [button setTitle:@"下载中..." forState:UIControlStateNormal];
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"download" withExtension:@"gif"];
                UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:url];
                [button setImage:image forState:UIControlStateNormal];
                button.enabled = NO;
            }
        }
    }
}

- (void)loadingCheck {
    NSArray *array = [self getArticleFirstImage:loadingDict];
    BOOL isLoaded = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
    if (isLoaded) {
        [[PCLCommonController sharedInstance] hideLoadingView:self.navigationController.view];
        [imageLoadingTimer invalidate];
        imageLoadingTimer = nil;
        
        PCLMagazineListController *controller = [[PCLMagazineListController alloc] initWithMagazineInfo:[magazineArray objectAtIndex:selectedIndex]];
        controller.searchStr = keySearchStr;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (NSArray *)getAllImageList:(NSDictionary *)dict {
    NSMutableArray *array = [NSMutableArray array];
    NSArray *articles = [dict objectForKey:@"articles"];
    NSString *thumbnail = nil;
    NSArray *pages = nil;
    NSString *articleImgUrl = nil;
    NSInteger maxNumberOfArticle = articles.count;
    NSString *rowImage = nil;
    for (int i = 0; i < maxNumberOfArticle; i++) {
        NSDictionary *dict = [articles objectAtIndex:i];
        thumbnail = [dict objectForKey:@"mini_page"];
        pages = [dict objectForKey:@"pages"];
        rowImage = [dict objectForKey:@"row_image"];
        if ([thumbnail isKindOfClass:[NSString class]] && thumbnail.length > 0) {
            thumbnail = [NSString stringWithFormat:@"%@%@", HostUrl, thumbnail];
            [array addObject:thumbnail];
        }
        if ([rowImage isKindOfClass:[NSString class]] && rowImage.length > 0) {
            rowImage = [NSString stringWithFormat:@"%@%@", HostUrl, rowImage];
            [array addObject:rowImage];
        }
        
        for (NSDictionary *articleDic in pages) {
            articleImgUrl = [articleDic objectForKey:@"image"];
            if ([articleImgUrl isKindOfClass:[NSString class]] && articleImgUrl.length > 0) {
                articleImgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, articleImgUrl];
                [array addObject:articleImgUrl];
            }
        }
        
    }
    
    return array;
}

- (void)getMagazineList {
    for (NSDictionary *magazineDict in magazineArray) {
        NSString *token = [magazineDict objectForKey:@"token"];
        NSDictionary *listDict = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token", @"0", @"loadingImage", nil];
        [NSThread detachNewThreadSelector:@selector(getArticleListThread:) toTarget:self withObject:listDict];
    }
}

- (NSArray *)getArticleFirstImage:(NSDictionary *)dict {
    NSMutableArray *array = [NSMutableArray array];
    NSArray *articles = [dict objectForKey:@"articles"];
    NSString *thumbnail = nil;
    NSArray *pages = nil;
    NSString *articleImgUrl = nil;
    NSInteger maxNumberOfArticle = articles.count;
    for (int i = 0; i < maxNumberOfArticle; i++) {
        NSDictionary *dict = [articles objectAtIndex:i];
        thumbnail = [dict objectForKey:@"mini_page"];
        pages = [dict objectForKey:@"pages"];
        if ([thumbnail isKindOfClass:[NSString class]] && thumbnail.length > 0) {
            thumbnail = [NSString stringWithFormat:@"%@%@", HostUrl, thumbnail];
            [array addObject:thumbnail];
        }
        
        NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, [dict objectForKey:@"row_image"]];
        [array addObject:imgUrl];
        
        NSDictionary *articleDic = [pages objectAtIndex:0];
        articleImgUrl = [articleDic objectForKey:@"image"];
        if ([articleImgUrl isKindOfClass:[NSString class]] && articleImgUrl.length > 0) {
            articleImgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, articleImgUrl];
            [array addObject:articleImgUrl];
        }
    }
    
    return array;
}

- (void)getFirstArticleImage:(NSDictionary *)dict {
    NSArray *array = [self getArticleFirstImage:dict];
    BOOL isLoaded = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
    if (isLoaded) {
        dispatch_async(mainQueue, ^{
            PCLMagazineListController *controller = [[PCLMagazineListController alloc] initWithMagazineInfo:[magazineArray objectAtIndex:selectedIndex]];
            controller.searchStr = keySearchStr;
            [self.navigationController pushViewController:controller animated:YES];
        });
    } else {
        dispatch_async(mainQueue, ^{
            [[PCLCommonController sharedInstance] showLoadingView:self.navigationController.view text:@"加载中..."];
        });
        [[PCLImageLoader sharedInstance] getMagazineArticlesImage:array];
        dispatch_async(mainQueue, ^{
            imageLoadingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(loadingCheck) userInfo:nil repeats:YES];
        });
    }
}

#pragma mark - network request
- (void)getListThread {
    @autoreleasepool {
        NSArray *array = [[PCLDataRequest sharedInstance] getMagazineList];
        if (nil != array) {
            [[PCLCacheManager sharedInstance] saveArray:array withKey:MagazineListKey];
            magazineArray = [NSArray arrayWithArray:array];
            [self getMagazineList];
            [self performSelectorOnMainThread:@selector(reloadList) withObject:nil waitUntilDone:YES];
        }
    }
}

- (void)getArticleListThread:(NSDictionary *)dict {
    @autoreleasepool {
        NSString *token = [dict objectForKey:@"token"];
        if (nil != token) {
            NSDictionary *tempDict = [[PCLDataRequest sharedInstance] getMagazineArticles:token];
            if (nil != tempDict) {
                [[PCLCacheManager sharedInstance] saveDict:tempDict withKey:[NSString stringWithFormat:MagazineInfoKey, token]];
                if ([[dict objectForKey:@"loadingImage"] boolValue]) {
                    [self getArticleImages];
                }
            }
        }
    }
}

- (void)getArticleImages {

    CGPoint offset = magazineListScroll.contentOffset;
    NSInteger index = offset.x / 320;
    
    NSDictionary *magazineDict = [magazineArray objectAtIndex:index];
    NSString *token = [magazineDict objectForKey:@"token"];
    NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, token]];
    NSArray *array = [self getAllImageList:dict];
    BOOL isLoaded = [[PCLImageLoader sharedInstance] getMagazineArticlesImage:array];
    
    dispatch_async(mainQueue, ^{
        if (isLoaded) {
            UIButton *button = (UIButton *)[self.view viewWithTag:MagazineDownloadBtnTag];
//            [button setTitle:@"已下载" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"Read"] forState:UIControlStateNormal];
            button.enabled = YES;
        } else {
            
        }
    });
}

#pragma mark - UITableView delegate and dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 135.f;
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = searchResults.count;
    NSLog(@"count: %d", count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCell];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.tag = cellImageTag;
        imgView.frame = CGRectMake(0, 0, 320, 130);
        [cell.contentView addSubview:imgView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dict = [searchResults objectAtIndex:indexPath.row];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, [dict objectForKey:@"row_image"]];
    NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:cellImageTag];
    if (nil != data) {
        imgView.image = [UIImage imageWithData:data];
    } else {
        [[PCLImageLoader sharedInstance] getImageWithIndexPath:indexPath withUrl:imgUrl];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *article = [searchResults objectAtIndex:indexPath.row];
    NSString *magazineToken = [article objectForKey:@"magazine_token"];
    NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, magazineToken]];
    NSInteger index = [[article objectForKey:@"index"] integerValue];
    
    PCLMagazineScanView *controller = [[PCLMagazineScanView alloc] initWithMagazineInfo:dict];
    controller.selectedPage = index;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - filter method
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSLog(@"searchText: %@, scope: %@", searchText, scope);
    keySearchStr = searchText;
    
    [searchResults removeAllObjects];
    for (NSDictionary *item in magazineListArray) {
        NSString *title = [item objectForKey:@"title"];
        if (NSNotFound != [title rangeOfString:searchText options:NSCaseInsensitiveSearch].location) {
            [searchResults addObject:item];
        }
    }
    
    if (searchResults.count > 0) {
        resultsTable.hidden = NO;
    } else {
        resultsTable.hidden = YES;
    }
//    [resultsTable reloadData];
    [self reloadResultView];
}

#pragma mark - UISearchDisplayController delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    NSLog(@"controller.searchResultsTableView: %@", controller.searchResultsTableView);
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"will hide");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"will unload");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"did show");
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
//    [searchResults addObjectsFromArray:allItems];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"will end search");
    [self resignSearchState];
}


#pragma mark - UISearchBar delegate 
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"searchText: %@", searchText);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarSearchButtonClicked");
//    if (searchResults.count > 0) {
//        NSDictionary *dict = [searchResults objectAtIndex:0];
//        NSMutableDictionary *magazineDict = nil;
//        NSDictionary *tempDict = nil;
//        for (int i = 0; i < magazineArray.count; i++) {
//            tempDict = [magazineArray objectAtIndex:i];
//            if ([[tempDict objectForKey:@"token"] isEqualToString:[dict objectForKey:@"magazine_token"]]) {
//                magazineDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
//                NSString *firstPageImageUrl = [[[dict objectForKey:@"pages"] objectAtIndex:0] objectForKey:@"image"];
//                [magazineDict setObject:firstPageImageUrl forKey:@"first_page"];
//                break;
//            }
//        }
//
//        PCLMagazineSearchResultController *controller = [[PCLMagazineSearchResultController alloc] initWithInfo:magazineDict];
//        controller.keySearchStr = searchBar.text;
//        [self.navigationController pushViewController:controller animated:YES];
//    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self reloadList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    NSInteger index = offset.x / 320;
    [self.navigationController setNavigationTitle:[[magazineArray objectAtIndex:index] objectForKey:@"title"]];
    [self setDownloadBtnState];
}

#pragma mark Handle keyboard UI change
- (void)keyboardDidShow:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = (keyboardRect.size.width>keyboardRect.size.height)?keyboardRect.size.height:keyboardRect.size.width;
    resultsTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardHeight);
}

- (void)keyboardWillHide:(NSNotification*)notification{
    resultsTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

@end
