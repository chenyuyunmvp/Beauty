//
//  PCLCacheManager.h
//  PCLady
//
//  Created by  Michael on 11/11/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ImageCacheDir   @"imageCache"
#define DataCacheDir    @"dataCache"

@interface PCLCacheManager : NSObject

+ (PCLCacheManager *)sharedInstance;
- (void)saveImage:(NSData *)imgData url:(NSString *)imgUrl;
- (NSData *)loadImageData:(NSString *)imgUrl;
- (void)saveArray:(NSArray *)array withKey:(NSString *)key;
- (NSArray *)LoadArrayWithKey:(NSString *)key;
- (void)saveDict:(NSDictionary *)dict withKey:(NSString *)key;
- (NSDictionary *)LoadDictWithKey:(NSString *)key;

- (void)clearCache;
@end
