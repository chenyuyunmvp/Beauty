//
//  PCLMagazineSearchResultController.m
//  Beauty
//
//  Created by  Michael on 1/18/14.
//  Copyright (c) 2014 Michael. All rights reserved.
//

#import "PCLMagazineSearchResultController.h"
#import "Constants.h"
#import "PCLImageLoader.h"
#import "PCLNavigation.h"
#import "PCLMagazineListController.h"
#import "PCLCacheManager.h"

static const CGFloat itemImageWidth = 294.f;
static const CGFloat itemGap = 14.f;
static const CGFloat itemBorderWidth = 5.f;
static const CGFloat itemTopIndent = 24.f;
static const CGFloat itemLeftIndent = 12.f;
static const CGFloat itemDownloadButtonHeight = 50.f;
static const CGFloat itemDownloadButtonWidth = 320.f;


@interface PCLMagazineSearchResultController ()

@end

@implementation PCLMagazineSearchResultController
@synthesize keySearchStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)dict {
    if (self = [super init]) {
        magazineInfoDict = dict;
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
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight-100.f)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.contentSize = CGSizeMake(320, scroll.frame.size.height);
    [self.view addSubview:scroll];
    
    int i = 0;
    UIImageView *imageBgView = [[UIImageView alloc] init];
    imageBgView.frame = CGRectMake(itemLeftIndent+i*(itemImageWidth+itemGap*2)-itemBorderWidth, itemTopIndent-itemBorderWidth, itemImageWidth+itemBorderWidth*2, scroll.frame.size.height-itemTopIndent*2);
    imageBgView.image = [UIImage imageNamed:@"Issue-Shadow-Height-Fixed-at-730px"];
    [scroll addSubview:imageBgView];
    
    NSDictionary *dict = magazineInfoDict;
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(itemLeftIndent+i*(itemImageWidth+itemGap*2), itemTopIndent, itemImageWidth, scroll.frame.size.height-itemTopIndent*2-itemBorderWidth*2);
    imageView.image = [UIImage imageNamed:@"bg"];
    [scroll addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:imageView.frame];
    [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:button];
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HostUrl, [dict objectForKey:@"first_page"]];
    [[PCLImageLoader sharedInstance] getImage:imageView withUrl:imgUrl];
    
    CGSize size = [keySearchStr sizeWithFont:[UIFont systemFontOfSize:24.f]];
    if (size.width < 30.f) {
        size.width = 30.f;
    }
    size.width += 10.f;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width-size.width-20.f, 345.f, size.width, 30.f)];
    label.font = [UIFont systemFontOfSize:24.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = keySearchStr;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = RGB_COLOR(254, 93, 93, 1.0f);
    [imageView addSubview:label];
    
    downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake((320-itemDownloadButtonWidth)/2, 110.f, itemDownloadButtonWidth, itemDownloadButtonHeight)];
    downloadBtn.frame = CGRectMake(0, self.view.frame.size.height-itemDownloadButtonHeight, self.view.frame.size.width, itemDownloadButtonHeight);
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"Bottom-Navbar"] forState:UIControlStateNormal];
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"Bottom-Navbar"] forState:UIControlStateDisabled];
    [downloadBtn setImage:[UIImage imageNamed:@"Read"] forState:UIControlStateNormal];
    
    downloadBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.navigationBarHidden = NO;

    [self.navigationController NavigateWithBackgroundImage:[UIImage imageNamed:@"Top-Navbar-BG"]];
    [self.navigationController setNavigationTitle:keySearchStr];
    
    [self performSelector:@selector(updateDownloadBtn) withObject:nil afterDelay:0];
}

- (void)updateDownloadBtn {
    downloadBtn.frame = CGRectMake(0, self.view.frame.size.height-itemDownloadButtonHeight, self.view.frame.size.width, itemDownloadButtonHeight);
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

- (void)clickItem:(UIButton *)btn {
    PCLMagazineListController *controller = [[PCLMagazineListController alloc] initWithMagazineInfo:magazineInfoDict];
    controller.searchStr = keySearchStr;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)download:(UIButton *)btn {
    PCLMagazineListController *controller = [[PCLMagazineListController alloc] initWithMagazineInfo:magazineInfoDict];
    controller.searchStr = keySearchStr;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
