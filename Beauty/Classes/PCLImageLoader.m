//
//  PCLImageLoader.m
//  PCLady
//
//  Created by  Michael on 11/5/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLImageLoader.h"
#import "PCLCacheManager.h"
#import "Constants.h"

@implementation PCLImageLoader

static PCLImageLoader *sharedInstance = nil;

+ (PCLImageLoader *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        loadingImageDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSData *)getImageWithUrl:(NSString *)url {
    @autoreleasepool {
        BOOL isLoading = [[loadingImageDict objectForKey:url] boolValue];
        while (isLoading) {
            sleep(1);
            isLoading = [[loadingImageDict objectForKey:url] boolValue];
        }
        
        [loadingImageDict setObject:@"1" forKey:url];
        NSData *data = [[PCLCacheManager sharedInstance] loadImageData:url];
        if (nil == data) {
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            [[PCLCacheManager sharedInstance] saveImage:data url:url];
        }
        [loadingImageDict removeObjectForKey:url];
        
        return data;
    }
}

- (void)getImage:(UIImageView *)imgView withUrl:(NSString *)imgUrl {
    NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
    if (nil == data) {
        dispatch_async(kBgQueue, ^{
            NSData *data = [self getImageWithUrl:imgUrl];
            dispatch_sync(mainQueue, ^{
                imgView.image = [UIImage imageWithData:data];
            });
        });
    } else {
        imgView.image = [UIImage imageWithData:data];
    }
}

- (void)getBtnImage:(UIButton *)btn withUrl:(NSString *)imgUrl {
    NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
    if (nil == data) {
        dispatch_async(kBgQueue, ^{
            NSData *data = [self getImageWithUrl:imgUrl];
            dispatch_sync(mainQueue, ^{
                UIImage *image = [UIImage imageWithData:data];
                [btn setImage:image forState:UIControlStateNormal];
            });
        });
    } else {
        UIImage *image = [UIImage imageWithData:data];
        [btn setImage:image forState:UIControlStateNormal];
    }
}

- (void)getImageWithIndexPath:(NSIndexPath *)indexPath withUrl:(NSString *)imgUrl {
    NSData *data = [[PCLCacheManager sharedInstance] loadImageData:imgUrl];
    if (data.length == 0) {
        dispatch_async(kBgQueue, ^{
            NSData *data = [self getImageWithUrl:imgUrl];
            dispatch_sync(mainQueue, ^{
                NSArray *tepArray = [NSArray arrayWithObjects:indexPath, data, nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:IndexPathImageLoadDoneNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:tepArray, @"info", nil]];
            });
        });
    } else {
        NSArray *tepArray = [NSArray arrayWithObjects:indexPath, data, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:IndexPathImageLoadDoneNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:tepArray, @"info", nil]];
    }
}

- (BOOL)getMagazineArticlesImage:(NSArray *)array {
    NSMutableArray *imagesArray = [[NSMutableArray alloc] initWithArray:array];
    BOOL result = YES;
    for (NSString *url in imagesArray) {
        NSData *data = [[PCLCacheManager sharedInstance] loadImageData:url];
        if (nil == data) {
            result = NO;
            dispatch_async(kBgQueue, ^{
                [self getImageWithUrl:url];
            });
        }
    }
    return result;
}

- (BOOL)isAllImagesLoaded:(NSArray *)array {
    NSMutableArray *imagesArray = [[NSMutableArray alloc] initWithArray:array];
    BOOL result = YES;
    if (array.count == 0) {
        result = NO;
    }
    for (NSString *url in imagesArray) {
        NSData *data = [[PCLCacheManager sharedInstance] loadImageData:url];
        if (nil == data) {
            result = NO;
        }
    }
    return result;
}

@end
