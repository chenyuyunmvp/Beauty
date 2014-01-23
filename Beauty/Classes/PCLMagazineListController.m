//
//  PCLMagazineListController.m
//  PCLady
//
//  Created by  Michael on 10/27/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLMagazineListController.h"
#import "PCLMagazineScanView.h"
#import "PCLImageLoader.h"
#import "PCLDataRequest.h"
#import "PCLCacheManager.h"
#import "Constants.h"
#import "PCLNavigation.h"
#import "ShareSDK/ShareSDK.h"
#import "OWActivityViewController.h"
#import "PCLCommonController.h"
#import "PCLShareView.h"

#define         cellImageTag            1000
#define         cellDescTag             1001
static const CGFloat bottomOptionViewHeight = 50.f;


@interface PCLMagazineListController ()

@end

@implementation PCLMagazineListController
@synthesize searchStr;

- (void)dealloc {
    [imageLoadingTimer invalidate];
    imageLoadingTimer = nil;
}

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
        imageLoadingDone = YES;
        searchStr = @"";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IndexImageLoadDone:) name:IndexPathImageLoadDoneNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (onIOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
	// Do any additional setup after loading the view.
    pageTable = [[UITableView alloc] init];
    pageTable.frame = self.view.frame;
    pageTable.delegate = self;
    pageTable.dataSource = self;
    [self.view addSubview:pageTable];
    
    NSDictionary *dict = [[PCLCacheManager sharedInstance] LoadDictWithKey:[NSString stringWithFormat:MagazineInfoKey, [magazineInfo objectForKey:@"token"]]];
    if (dict == nil) {
        [[PCLCommonController sharedInstance] showLoadingView:self.view text:@"下载中..."];
        [NSThread detachNewThreadSelector:@selector(getArticleListThread) toTarget:self withObject:nil];
    } else {
        magazineInfo = dict;
        dispatch_async(kBgQueue, ^{
            [self getArticleImages];
        });
    }
    
    bottomOptionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-bottomOptionViewHeight, self.view.frame.size.width, bottomOptionViewHeight)];
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
    if (searchStr.length == 0) {
//        [bottomOptionView addSubview:rightShareBtn];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.f, 0, self.view.frame.size.width-70.f, bottomOptionViewHeight)];
    titleLabel.font = [UIFont systemFontOfSize:16.f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = searchStr.length > 0 ? searchStr : [magazineInfo objectForKey:@"title"];
    [bottomOptionView addSubview:titleLabel];
    
    UIImage *logoImage = [UIImage imageNamed:@"Logo"];
    logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 30.f, logoImage.size.width, logoImage.size.height)];
    logoView.image = logoImage;
    logoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:logoView];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)getArticleImages {
    NSArray *array = [self getArticleFirstImage:magazineInfo];
    BOOL isLoaded = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
    if (isLoaded) {
        
    } else {
        dispatch_async(mainQueue, ^{
            [[PCLCommonController sharedInstance] showLoadingView:self.view text:@"加载中..."];
        });
        [[PCLImageLoader sharedInstance] getMagazineArticlesImage:array];
        dispatch_async(mainQueue, ^{
            imageLoadingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(loadingCheck) userInfo:nil repeats:YES];
        });
    }
}

- (void)loadingCheck {
    NSArray *array = [self getArticleFirstImage:magazineInfo];
    BOOL isLoaded = [[PCLImageLoader sharedInstance] isAllImagesLoaded:array];
    if (isLoaded) {
        [[PCLCommonController sharedInstance] hideLoadingView:self.view];
        [imageLoadingTimer invalidate];
        imageLoadingTimer = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(updateUIFrame) withObject:nil afterDelay:0.f];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationController setNavigationTitle:@"目录"];
}

- (void)share {
    
    PCLShareView *shareView = [[PCLShareView alloc] initWithFrame:self.view.frame];
    shareView.labelTitle.text = @"分享杂志";
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
}

- (void)updateUIFrame {
    if (onIOS7) {
        CGRect rect = CGRectMake(0, 0.f, self.view.frame.size.width, self.view.frame.size.height-bottomOptionViewHeight);
        pageTable.frame = rect;
    } else {
        CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-bottomOptionViewHeight);
        pageTable.frame = rect;
    }
    
    bottomOptionView.frame = CGRectMake(0, self.view.frame.size.height-bottomOptionViewHeight, self.view.frame.size.width, bottomOptionViewHeight);
    logoView.frame = CGRectMake(10.f, 20.f, logoView.frame.size.width, logoView.frame.size.height);
}

- (void)reloadTableData {
    [pageTable reloadData];
}

- (void)IndexImageLoadDone:(NSNotification *)notifier {
    NSArray *info = [[notifier userInfo] objectForKey:@"info"];
    NSIndexPath *indexPath = [info objectAtIndex:0];
    [pageTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - network request
- (void)getArticleListThread {
    
    @autoreleasepool {
        NSString *token = [magazineInfo objectForKey:@"token"];
        if (nil != token) {
            NSDictionary *dict = [[PCLDataRequest sharedInstance] getMagazineArticles:token];
            if (nil != dict) {
                [[PCLCacheManager sharedInstance] saveDict:dict withKey:[NSString stringWithFormat:MagazineInfoKey, token]];
                magazineInfo = [NSDictionary dictionaryWithDictionary:dict];
                [self getArticleImages];
            }
            [self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:NO];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PCLCommonController sharedInstance] hideLoadingView:self.view];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = [magazineInfo objectForKey:@"articles"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor whiteColor];
    NSInteger number = array.count;
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 135.f;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCell = @"cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCell];
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.tag = cellImageTag;
        imgView.frame = CGRectMake(0, 0, 320, 130);
        [cell.contentView addSubview:imgView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dict = [[magazineInfo objectForKey:@"articles"] objectAtIndex:indexPath.row];
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:cellImageTag];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, [dict objectForKey:@"row_image"]];
    NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
    if (nil != data) {
        imgView.image = [UIImage imageWithData:data];
    } else {
        [[PCLImageLoader sharedInstance] getImageWithIndexPath:indexPath withUrl:imgUrl];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (imageLoadingDone) {
        PCLMagazineScanView *controller = [[PCLMagazineScanView alloc] initWithMagazineInfo:magazineInfo];
        controller.selectedPage = indexPath.row;
        controller.isSearchResult = searchStr.length > 0 ? YES : NO;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
