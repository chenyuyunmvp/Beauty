//
//  PCLImageLoader.h
//  PCLady
//
//  Created by  Michael on 11/5/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IndexImageLoadDoneNotification          @"IndexImageLoadDone"
#define IndexPathImageLoadDoneNotification      @"IndexPathImageLoadDone"

@interface PCLImageLoader : NSObject {
    NSMutableDictionary *loadingImageDict;
}

+ (PCLImageLoader *)sharedInstance;

- (void)getImage:(UIImageView *)imgView withUrl:(NSString *)imgUrl;
- (void)getBtnImage:(UIButton *)btn withUrl:(NSString *)imgUrl;
- (void)getImageWithIndexPath:(NSIndexPath *)indexPath withUrl:(NSString *)imgUrl;
- (BOOL)getMagazineArticlesImage:(NSArray *)array;
- (BOOL)isAllImagesLoaded:(NSArray *)array;

@end
