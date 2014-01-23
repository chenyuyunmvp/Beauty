//
//  PCLMagazineScanView.m
//  PCLady
//
//  Created by  Michael on 10/26/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLMagazineScanView.h"
#import "Constants.h"
#import "PCLImageLoader.h"
#import "PCLDataRequest.h"
#import "PCLCacheManager.h"
#import "PCLNavigation.h"
#import "ShareSDK/ShareSDK.h"
#import "PCLCommonController.h"
#import "PCLShareView.h"

#define     PageSelectTag           1000
#define     PageSelectHeight        132
#define     contentScrollViewTag    2000
#define     descScrollViewTag       3000
#define     descLabelTag            3001
#define     descViewTag             3002
#define     imageScrollViewTag      4000
#define     refreshViewTag          5000

static const CGFloat captionLeftIndent = 18.f;
static const CGFloat captionTopIndent = 24.f;
static const CGFloat bottomOptionViewHeight = 50.f;


@interface PCLMagazineScanView ()

@end

@implementation PCLMagazineScanView
@synthesize isSearchResult;

@synthesize selectedPage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithMagazineInfo:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        magazineInfo = dict;
        articlesArray = [NSArray arrayWithArray:[dict objectForKey:@"articles"]];
        isPageShowing = NO;
        selectedPage = 0;
        imageLoadingDict = [[NSMutableDictionary alloc] init];
        pagingDict = [[NSMutableDictionary alloc] init];
        isSearchResult = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (onIOS7) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    } else {
        self.wantsFullScreenLayout = YES;
    }
    
	// Do any additional setup after loading the view.
    UIImageView *imgView = [[UIImageView alloc] init];
    UIImage *img = [UIImage imageNamed:@"bg.png"];
    imgView.image = img;
    imgView.frame = CGRectMake(0, 0, 320, screenHeight);
    [self.view addSubview:imgView];
    
    NSInteger numberOfPages = articlesArray.count;
    
    pageScroll = [[UIScrollView alloc] init];
    pageScroll.delegate = self;
    pageScroll.frame = CGRectMake(0, 0, 320, screenHeight);
    pageScroll.contentSize = CGSizeMake(320*numberOfPages, screenHeight);
    pageScroll.pagingEnabled = YES;
    pageScroll.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:pageScroll];
    
    UIScrollView *contentScroll = nil;
//    UITableView *contentScroll = nil;
    for (int j = 0; j < numberOfPages; j++) {
        NSDictionary *dict = [articlesArray objectAtIndex:j];
        NSArray *pagesArray = [dict objectForKey:@"pages"];
        NSInteger pagesNum = pagesArray.count;
        
        contentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(320*j, 0, 320, screenHeight)];
//        contentScroll = [[UITableView alloc] initWithFrame:CGRectMake(320*j, 0, 320, screenHeight)];
        contentScroll.delegate = self;
//        contentScroll.dataSource = self;
        contentScroll.pagingEnabled = YES;
        contentScroll.showsVerticalScrollIndicator = NO;
        contentScroll.contentSize = CGSizeMake(320, screenHeight*pagesNum);
        contentScroll.tag = contentScrollViewTag+j;
//        contentScroll.rowHeight = screenHeight;
        contentScroll.backgroundColor = [UIColor clearColor];
        [pageScroll addSubview:contentScroll];
        
        NSArray *array = [self getAllImageList:selectedPage];
        BOOL imageLoadingDone = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
        if (!imageLoadingDone) {
//            refreshView = [[ODRefreshControl alloc] initInScrollView:contentScroll];
//            refreshView.tag = refreshViewTag;
//            [refreshView addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
            contentScroll.contentSize = CGSizeMake(320, screenHeight+5);
        } else {
            contentScroll.contentSize = CGSizeMake(320, screenHeight*pagesNum);
        }
        
        for (int i = 0; i < pagesNum; i++) {
            NSDictionary *pageDict = [pagesArray objectAtIndex:i];
            NSString *pageType = @"img";
            if ([pageType isEqualToString:@"img"]) {
                NSString *imgUrl = [pageDict objectForKey:@"image"];
                imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, imgUrl];
                UIImageView *imgView = [[UIImageView alloc] init];
                imgView.tag = imageScrollViewTag+i;
                NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
                if (nil == data) {
//                    [[PCLImageLoader sharedInstance] getImage:imgView withUrl:imgUrl];
                } else {
                    imgView.image = [UIImage imageWithData:data];
                }
                imgView.frame = CGRectMake(0, screenHeight*i, 320, screenHeight);
                [contentScroll addSubview:imgView];
                
                NSString *descType = [pageDict objectForKey:@"desc_type"];
                descType = @"txt";
                if ([descType isEqualToString:@"txt"]) {
                    NSString *descString = [pageDict objectForKey:@"text"];
                    if ([descString isKindOfClass:[NSString class]] && descString.length > 0) {
                        CGSize maxSize = CGSizeMake(320-2*captionLeftIndent, INT16_MAX);
                        CGSize descSize = [descString sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:maxSize];
                        
                        UIScrollView *scroll = [[UIScrollView alloc] init];
                        scroll.delegate = self;
                        scroll.frame = CGRectMake(0, screenHeight*i, 320, screenHeight);
                        scroll.showsVerticalScrollIndicator = NO;
                        scroll.contentSize = CGSizeMake(320, descSize.height+screenHeight+captionTopIndent*2);
                        scroll.bounces = NO;
                        scroll.tag = descScrollViewTag+i;
                        [contentScroll addSubview:scroll];
                        
                        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, 320, descSize.height+captionTopIndent*2)];
                        view.backgroundColor = [UIColor whiteColor];
                        [scroll addSubview:view];
                        
                        UILabel *labelDesc = [[UILabel alloc] init];
                        labelDesc.frame = CGRectMake(captionLeftIndent, screenHeight, 320-captionLeftIndent*2, descSize.height+captionTopIndent*2);
                        labelDesc.text = descString;
                        labelDesc.font = [UIFont systemFontOfSize:16];
                        labelDesc.numberOfLines = 0;
                        [scroll addSubview:labelDesc];
                    }
                } else if ([descType isEqualToString:@"img"]) {
                    NSString *descImgUrl = [pageDict objectForKey:@"image"];
                    descImgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, descImgUrl];
                    NSData *data = [[PCLCacheManager sharedInstance] loadImageData:descImgUrl];
                    UIImage *descImage = nil;
                    if (data) {
                        descImage = [UIImage imageWithData:data];
                    }
                    
                    if (data) {
                        UIScrollView *scroll = [[UIScrollView alloc] init];
                        scroll.delegate = self;
                        scroll.frame = CGRectMake(0, screenHeight*i, 320, screenHeight);
                        scroll.showsVerticalScrollIndicator = NO;
                        scroll.contentSize = CGSizeMake(320, descImage.size.height);
                        scroll.bounces = NO;
                        scroll.tag = descScrollViewTag+i;
                        [contentScroll addSubview:scroll];
                        
                        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, 320, descImage.size.height)];
                        view.backgroundColor = [UIColor whiteColor];
                        [scroll addSubview:view];
                        
                        UIImageView *imageView = [[UIImageView alloc] init];
                        imageView.frame = CGRectMake(0, screenHeight, 320, descImage.size.height);
                        imageView.image = descImage;
                        [scroll addSubview:imageView];
                    }
                }
            } else if ([pageType isEqualToString:@"txt"]) {
                NSString *imgUrl = [pageDict objectForKey:@"image"];
                imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, imgUrl];
                UIImageView *imgView = [[UIImageView alloc] init];
                imgView.tag = imageScrollViewTag+i;
                NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
                if (nil == data) {
                    //                    [[PCLImageLoader sharedInstance] getImage:imgView withUrl:imgUrl];
                } else {
                    imgView.image = [UIImage imageWithData:data];
                }
                imgView.frame = CGRectMake(0, screenHeight*i, 320, screenHeight);
                [contentScroll addSubview:imgView];
                
                NSString *descType = [pageDict objectForKey:@"desc_type"];
                descType = @"txt";
                if ([descType isEqualToString:@"txt"]) {
                    NSString *descString = [pageDict objectForKey:@"text"];
                    if ([descString isKindOfClass:[NSString class]] && descString.length > 0) {
                        CGSize maxSize = CGSizeMake(320-2*captionLeftIndent, INT16_MAX);
                        CGSize descSize = [descString sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:maxSize];
                        
                        UIScrollView *scroll = [[UIScrollView alloc] init];
                        scroll.delegate = self;
                        scroll.frame = CGRectMake(0, screenHeight*i, 320, screenHeight);
                        scroll.showsVerticalScrollIndicator = NO;
                        scroll.contentSize = CGSizeMake(320, descSize.height+screenHeight+captionTopIndent*2);
                        scroll.bounces = NO;
                        scroll.tag = descScrollViewTag+i;
                        [contentScroll addSubview:scroll];
                        
                        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, 320, descSize.height+captionTopIndent*2)];
                        view.backgroundColor = [UIColor whiteColor];
                        [scroll addSubview:view];
                        
                        UILabel *labelDesc = [[UILabel alloc] init];
                        labelDesc.frame = CGRectMake(captionLeftIndent, screenHeight, 320-captionLeftIndent*2, descSize.height+captionTopIndent*2);
                        labelDesc.text = descString;
                        labelDesc.font = [UIFont systemFontOfSize:16];
                        labelDesc.numberOfLines = 0;
                        [scroll addSubview:labelDesc];
                    }
                } else if ([descType isEqualToString:@"img"]) {
                    NSString *descImgUrl = [pageDict objectForKey:@"image"];
                    descImgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, descImgUrl];
                    NSData *data = [[PCLCacheManager sharedInstance] loadImageData:descImgUrl];
                    UIImage *descImage = nil;
                    if (data) {
                        descImage = [UIImage imageWithData:data];
                    }
                    
                    if (data) {
                        UIScrollView *scroll = [[UIScrollView alloc] init];
                        scroll.delegate = self;
                        scroll.frame = CGRectMake(0, screenHeight*i, 320, screenHeight);
                        scroll.showsVerticalScrollIndicator = NO;
                        scroll.contentSize = CGSizeMake(320, descImage.size.height);
                        scroll.bounces = NO;
                        scroll.tag = descScrollViewTag+i;
                        [contentScroll addSubview:scroll];
                        
                        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, 320, descImage.size.height)];
                        view.backgroundColor = [UIColor whiteColor];
                        [scroll addSubview:view];
                        
                        UIImageView *imageView = [[UIImageView alloc] init];
                        imageView.frame = CGRectMake(0, screenHeight, 320, descImage.size.height);
                        imageView.image = descImage;
                        [scroll addSubview:imageView];
                    }
                }
            }
        }
    }
    
//    pageSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, 320, PageSelectHeight)];
    pageSelectView = nil;
    pageSelectView.backgroundColor = RGB_COLOR(235, 235, 235, 0.7f);
    [self.view addSubview:pageSelectView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 5, 320.f, 32.f);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *articleOne = [articlesArray objectAtIndex:0];
    NSArray *pagesArray = [articleOne objectForKey:@"pages"];
    NSString *titleOne = [[pagesArray objectAtIndex:0] objectForKey:@"title"];
    if ([titleOne isKindOfClass:[NSString class]] && titleOne.length > 0) {
        titleLabel.text = titleOne;
    }
    titleLabel.font = [UIFont systemFontOfSize:18.f];
    [pageSelectView addSubview:titleLabel];
    
    page = [[UIScrollView alloc] init];
    page.delegate = self;
    page.frame = CGRectMake(0, 42.f, 320, 1000);
    page.contentSize = CGSizeMake(90*numberOfPages+10, 90.f);
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    testBtn.frame = CGRectMake(200, 10, 200, 30);
    [testBtn setTitle:@"test touch" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(testTouch:) forControlEvents:UIControlEventTouchUpInside];
    [page addSubview:testBtn];
    
    for (int i = 0; i < numberOfPages; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10+90*i, 10, 70, 70);
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        btn.titleLabel.textColor = [UIColor redColor];
        btn.tag = PageSelectTag+i;
        btn.clipsToBounds = YES;
        if (selectedPage == i) {
            btn.frame = CGRectMake(btn.frame.origin.x-5, btn.frame.origin.y-5, 80, 80);
        }
        
        btn.layer.cornerRadius = 20;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [[UIColor clearColor] CGColor];
        
        NSDictionary *articleInfo = [articlesArray objectAtIndex:i];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        NSString *btnImgUrl = [articleInfo objectForKey:@"mini_image"];
        btnImgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, btnImgUrl];
        NSData *btnData = [[PCLCacheManager sharedInstance] loadImageData:btnImgUrl];
        if (nil != btnData) {
            UIImage *image = [UIImage imageWithData:btnData];
            [btn setImage:image forState:UIControlStateNormal];
        } else {
            [[PCLImageLoader sharedInstance] getBtnImage:btn withUrl:btnImgUrl];
        }
        [btn addTarget:self action:@selector(selePage:) forControlEvents:UIControlEventTouchUpInside];
        [page addSubview:btn];
    }
    [pageSelectView addSubview:page];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [pageScroll addGestureRecognizer:tap];

    [self setPage:selectedPage animated:NO];
    [self addBackView];
    
    UIImage *logoImage = [UIImage imageNamed:@"Logo"];
    logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 30.f, logoImage.size.width, logoImage.size.height)];
    logoView.image = logoImage;
    logoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:logoView];
}

- (void)addBackView {
    
    bottomOptionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, bottomOptionViewHeight)];
    [self.view addSubview:bottomOptionView];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bottom-Navbar"]];
    bgImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, bottomOptionViewHeight);
    [bottomOptionView addSubview:bgImageView];
    
    UIButton *leftBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"Back"];
    [leftBackBtn setImage:backImage forState:UIControlStateNormal];
    leftBackBtn.frame = CGRectMake(14.f, (bottomOptionViewHeight-backImage.size.height)/2, backImage.size.width+10.f, backImage.size.height);
    [bottomOptionView addSubview:leftBackBtn];
    [leftBackBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightShareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *shareImage = [UIImage imageNamed:@"Share"];
    [rightShareBtn setImage:shareImage forState:UIControlStateNormal];
    rightShareBtn.frame = CGRectMake(self.view.frame.size.width-24.f-shareImage.size.width, (bottomOptionViewHeight-shareImage.size.height)/2, shareImage.size.width+10.f, shareImage.size.height);
    [rightShareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    if (NO == isSearchResult) {
        [bottomOptionView addSubview:rightShareBtn];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadList {
    NSInteger numberOfPages = articlesArray.count;
    UIScrollView *contentScroll = nil;
    contentScroll = (UIScrollView *)[self.view viewWithTag:contentScrollViewTag+selectedPage];
    contentScroll.userInteractionEnabled = YES;

    refreshView = (ODRefreshControl *)[contentScroll viewWithTag:refreshViewTag];
    [refreshView endRefreshing];
    [refreshView removeFromSuperview];

    NSDictionary *dict = [articlesArray objectAtIndex:selectedPage];
    NSArray *pagesArray = [dict objectForKey:@"pages"];
    NSInteger pagesNum = pagesArray.count;
    contentScroll.contentSize = CGSizeMake(320, screenHeight*pagesNum);
    
    for (int j = 0; j < numberOfPages; j++) {
        NSDictionary *dict = [articlesArray objectAtIndex:j];
        NSArray *pagesArray = [dict objectForKey:@"pages"];
        NSInteger pagesNum = pagesArray.count;
        
        contentScroll = (UIScrollView *)[pageScroll viewWithTag:contentScrollViewTag+j];
        for (int i = 0; i < pagesNum; i++) {
            NSDictionary *pageDict = [pagesArray objectAtIndex:i];
            NSString *pageType = @"img";
            if ([pageType isEqualToString:@"img"]) {
                NSString *imgUrl = [pageDict objectForKey:@"image"];
                imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, imgUrl];
                UIImageView *imgView = (UIImageView *)[contentScroll viewWithTag:imageScrollViewTag+i];
                NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
                if (nil == data) {
//                    [[PCLImageLoader sharedInstance] getImage:imgView withUrl:imgUrl];
                } else {
                    imgView.image = [UIImage imageWithData:data];
                }
                imgView.frame = CGRectMake(0, screenHeight*i, 320, screenHeight);
            } else if ([pageType isEqualToString:@"txt"]) {
                
            }
        }
    }
    
    for (int i = 0; i < numberOfPages; i++) {
        UIButton *btn = (UIButton *)[page viewWithTag:PageSelectTag+i];
        btn.frame = CGRectMake(10+90*i, 10, 70, 70);
        if (selectedPage == i) {
            btn.frame = CGRectMake(btn.frame.origin.x-5, btn.frame.origin.y-5, 80, 80);
        }
        
        NSDictionary *articleInfo = [articlesArray objectAtIndex:i];
        NSString *btnImgUrl = [articleInfo objectForKey:@"mini_image"];
        btnImgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, btnImgUrl];
        NSData *btnData = [[PCLCacheManager sharedInstance] loadImageData:btnImgUrl];
        if (nil != btnData) {
            UIImage *image = [UIImage imageWithData:btnData];
            [btn setImage:image forState:UIControlStateNormal];
        } else {
            [[PCLImageLoader sharedInstance] getBtnImage:btn withUrl:btnImgUrl];
        }
    }
}

- (void)testTouch:(UIButton *)button {
    NSLog(@"testTouch testTouch");
}

- (void)tap:(UIGestureRecognizer *)gesture {
    [UIView beginAnimations:nil context:nil];
    
    if (isPageShowing) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        pageSelectView.frame = CGRectMake(0, screenHeight, 320, PageSelectHeight);
        [self hideNav];
    } else {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        pageSelectView.frame = CGRectMake(0, screenHeight-PageSelectHeight, 320, PageSelectHeight);
        [self showNav];
    }
    
    [UIView commitAnimations];
    isPageShowing = !isPageShowing;
}

- (void)setPage:(NSInteger)index animated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        pageScroll.contentOffset = CGPointMake(index*320, 0);
        CGFloat offsetY = ((index+1)*90-320) > 0 ? (index+1)*90-320 : 0;
        page.contentOffset = CGPointMake(offsetY, 0);
        [UIView commitAnimations];
    } else {
        pageScroll.contentOffset = CGPointMake(index*320, 0);
        CGFloat offsetY = ((index+1)*90-320) > 0 ? (index+1)*90-320 : 0;
        page.contentOffset = CGPointMake(offsetY, 0);
    }
    
    NSInteger numberOfPages = articlesArray.count;
    for (int i = 0; i < numberOfPages; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:PageSelectTag+i];
        btn.frame = CGRectMake(10+90*i, 10, 70, 70);
    }
    
    UIButton *button = (UIButton *)[self.view viewWithTag:PageSelectTag+index];
    button.frame = CGRectMake(5+90*index, 5, 80, 80);
    selectedPage = index;
}

- (void)selePage:(UIButton *)button {
    int index = button.tag - PageSelectTag;
    
    if (selectedPage == button.tag) {
        return;
    }
    
    [self setPage:index animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    logoView.frame = CGRectMake(10.f, 30.f, logoView.frame.size.width, logoView.frame.size.height);
    [self performSelector:@selector(hideNav) withObject:nil afterDelay:0.3f];
}

- (void)share {
    
    PCLShareView *shareView = [[PCLShareView alloc] initWithFrame:self.view.frame];
    shareView.labelTitle.text = @"分享文章";
    [self.view addSubview:shareView];
    return;
    
    NSString *imagePath = @"www.baidu.com";
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:CONTENT
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    ///////////////////////
    //以下信息为特定平台需要定义分享内容，如果不需要可省略下面的添加方法
    
    //定制微信好友信息
    [publishContent addWeixinSessionUnitWithType:INHERIT_VALUE
                                         content:INHERIT_VALUE
                                           title:@"Hello 微信好友!"
                                             url:INHERIT_VALUE
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    
    //自定义新浪微博分享菜单项
    id<ISSShareActionSheetItem> sinaItem = [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeSinaWeibo]
                                                                              icon:[ShareSDK getClientIconWithType:ShareTypeSinaWeibo]
                                                                      clickHandler:^{
                                                                          [ShareSDK clientShareContent:publishContent
                                                                                                  type:ShareTypeSinaWeibo
                                                                                         statusBarTips:YES
                                                                                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                                                                    
                                                                                                    if (state == SSPublishContentStateSuccess)
                                                                                                    {
                                                                                                        NSLog(@"分享成功");
                                                                                                    }
                                                                                                    else if (state == SSPublishContentStateFail)
                                                                                                    {
                                                                                                        NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                                                                                        [[PCLCommonController sharedInstance] showAlertMessage:@"请确认已安装新浪微博客户端."];
                                                                                                    }
                                                                                                }];
                                                                      }];
    
    id<ISSShareActionSheetItem> wxsItem = [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeWeixiSession]
                                                                             icon:[ShareSDK getClientIconWithType:ShareTypeWeixiSession]
                                                                     clickHandler:^{
                                                                         [ShareSDK clientShareContent:publishContent
                                                                                                 type:ShareTypeWeixiSession
                                                                                        statusBarTips:YES
                                                                                               result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                                                                   
                                                                                                   if (state == SSPublishContentStateSuccess)
                                                                                                   {
                                                                                                       NSLog(@"分享成功");
                                                                                                   }
                                                                                                   else if (state == SSPublishContentStateFail)
                                                                                                   {
                                                                                                       NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                                                                                       [[PCLCommonController sharedInstance] showAlertMessage:@"请确认已安装微信客户端."];
                                                                                                   }
                                                                                               }];
                                                                     }];
    
    
    //创建自定义分享列表
    NSArray *shareList = [ShareSDK customShareListWithType:
                          sinaItem,
                          wxsItem,
                          nil];
    
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"发表成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)hideNav {
    [UIView animateWithDuration:0.3f animations:^{
        bottomOptionView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, bottomOptionViewHeight);
    }];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)showNav {
    [UIView animateWithDuration:0.3f animations:^{
        bottomOptionView.frame = CGRectMake(0, self.view.frame.size.height-bottomOptionViewHeight, self.view.frame.size.width, bottomOptionViewHeight);
    }];

//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    if (UIGestureRecognizerStateBegan == pan.state) {
        pan.enabled = NO;
    }
}

// 隐藏 Navigation 和 目录列表
- (void)hideActionsView {
    [self hideNav];
    [UIView beginAnimations:nil context:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    pageSelectView.frame = CGRectMake(0, screenHeight, 320, PageSelectHeight);
    [UIView commitAnimations];
    
    isPageShowing = NO;
}

- (NSArray *)getAllImageList:(NSInteger)selectedIndex {
    NSMutableArray *array = [NSMutableArray array];
    NSString *thumbnail = nil;
    NSArray *pages = nil;
    NSString *articleImgUrl = nil;
//    for (int i = 0; i < articlesArray.count; i++) {
        NSDictionary *dict = [articlesArray objectAtIndex:selectedIndex];
        thumbnail = [dict objectForKey:@"mini_page"];
        pages = [dict objectForKey:@"pages"];
        if ([thumbnail isKindOfClass:[NSString class]] && thumbnail.length > 0) {
            thumbnail = [NSString stringWithFormat:@"%@%@", HostUrl, thumbnail];
            [array addObject:thumbnail];
        }
        for (NSDictionary *articleDic in pages) {
            articleImgUrl = [articleDic objectForKey:@"image"];
            if ([articleImgUrl isKindOfClass:[NSString class]] && articleImgUrl.length > 0) {
                articleImgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, articleImgUrl];
                [array addObject:articleImgUrl];
            }
        }
//    }
    
    return array;
}

- (void)getArticleImages {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PCLCommonController sharedInstance] showLoadingView:self.view text:@"下载中..."];
    });
    
    NSArray *array = [self getAllImageList:selectedPage];
    BOOL imageLoadingDone = [[PCLImageLoader sharedInstance] getMagazineArticlesImage:array];
    if (!imageLoadingDone) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageLoadingTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(getArticleImages) userInfo:nil repeats:NO];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PCLCommonController sharedInstance] hideLoadingView:self.view];
            [self reloadList];
        });
        
        [imageLoadingTimer invalidate];
        imageLoadingTimer = nil;
    }
}

#pragma mark - UITableView delegate and dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *dict = [articlesArray objectAtIndex:tableView.tag-contentScrollViewTag];
    NSArray *pagesArray = [dict objectForKey:@"pages"];
    NSInteger pagesNum = pagesArray.count;
    return pagesNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCell];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.tag = imageScrollViewTag;
        imgView.frame = CGRectMake(0, 0, 320, screenHeight);
        [cell.contentView addSubview:imgView];

        UIScrollView *scroll = [[UIScrollView alloc] init];
        scroll.delegate = self;
        scroll.frame = CGRectMake(0, 0, 320, screenHeight);
        scroll.showsVerticalScrollIndicator = NO;
        scroll.bounces = NO;
        scroll.tag = descScrollViewTag;
        [cell.contentView addSubview:scroll];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor whiteColor];
        view.tag = descViewTag;
        [scroll addSubview:view];
        
        UILabel *labelDesc = [[UILabel alloc] init];
        labelDesc.font = [UIFont systemFontOfSize:16];
        labelDesc.numberOfLines = 0;
        labelDesc.tag = descLabelTag;
        [scroll addSubview:labelDesc];
    }

    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:imageScrollViewTag];
    UIScrollView *scroll = (UIScrollView *)[cell.contentView viewWithTag:descScrollViewTag];
    scroll.userInteractionEnabled = YES;
    UIView *view = (UIView *)[cell.contentView viewWithTag:descViewTag];
    UILabel *labelDesc = (UILabel *)[cell.contentView viewWithTag:descLabelTag];
    
    NSDictionary *article = [articlesArray objectAtIndex:tableView.tag-contentScrollViewTag];
    NSArray *pagesArray = [article objectForKey:@"pages"];
    NSDictionary *pageDict = [pagesArray objectAtIndex:indexPath.row];
    NSString *pageType = @"img";
    if ([pageType isEqualToString:@"img"]) {
        NSString *imgUrl = [pageDict objectForKey:@"image"];
        imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, imgUrl];
        NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
        if (nil == data) {
        } else {
            imgView.image = [UIImage imageWithData:data];
        }
        
        NSString *descType = [pageDict objectForKey:@"desc_type"];
        descType = @"txt";
        if ([descType isEqualToString:@"txt"]) {
            NSString *descString = [pageDict objectForKey:@"text"];
            if ([descString isKindOfClass:[NSString class]] && descString.length > 0) {
                CGSize maxSize = CGSizeMake(320-2*captionLeftIndent, INT16_MAX);
                CGSize descSize = [descString sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:maxSize];
                
                scroll.contentSize = CGSizeMake(320, descSize.height+screenHeight+captionTopIndent*2);
                view.frame = CGRectMake(0, screenHeight, 320, descSize.height+captionTopIndent*2);
                labelDesc.frame = CGRectMake(captionLeftIndent, screenHeight, 320-captionLeftIndent*2, descSize.height+captionTopIndent*2);
                labelDesc.text = descString;
            }
        }
    }
    
    return cell;
}

#pragma mark ODRefreshControl delegate
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self getArticleImages];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (page != scrollView) {
        [self hideActionsView]; // 滑动时候隐藏上下的内容
    }
    
    if (scrollView.tag >= contentScrollViewTag && scrollView.tag < descScrollViewTag) {
        CGFloat threshold;
        threshold = scrollView.frame.size.height - 500;
        if (scrollView.contentOffset.y > threshold) {
            if (!looseLoadMore) {
                looseLoadMore = YES;
            }
        } else {
            if (looseLoadMore) {
                looseLoadMore = NO;
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.tag >= contentScrollViewTag && scrollView.tag < descScrollViewTag) {
        NSArray *array = [self getAllImageList:selectedPage];
        BOOL imageLoadingDone = [[PCLImageLoader sharedInstance] getMagazineArticlesImage:array];
        if (!imageLoadingDone) {
            if (looseLoadMore) {
                [self getArticleImages];
                looseLoadMore = NO;
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == pageScroll) {
        NSInteger pageIndex = pageScroll.contentOffset.x / 320;
        [self setPage:pageIndex animated:YES];
        
        dispatch_async(kBgQueue, ^{
            NSDictionary *article = [articlesArray objectAtIndex:pageIndex];
            NSArray *pages = [article objectForKey:@"pages"];;
            NSDictionary *articleDic = [pages lastObject];
            NSString *articleImageUrl = [articleDic objectForKey:@"image"];
            if ([articleImageUrl isKindOfClass:[NSString class]] && articleImageUrl.length > 0) {
                articleImageUrl = [NSString stringWithFormat:@"%@%@", HostUrl, articleImageUrl];
            }
            NSData *data = [[PCLCacheManager sharedInstance] loadImageData:articleImageUrl];
            if (nil == data) {
//                [self getArticleImages];
//                dispatch_async(mainQueue, ^{
//                    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(getArticleImages) object:nil];
//                    [self performSelector:@selector(getArticleImages) withObject:nil afterDelay:1.f];
//                });
            }
        });
    } else if (scrollView.tag >= contentScrollViewTag && scrollView.tag < descScrollViewTag) {
        if (scrollView.contentOffset.y >= screenHeight) {
            logoView.hidden = YES;
        } else {
            logoView.hidden = NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
