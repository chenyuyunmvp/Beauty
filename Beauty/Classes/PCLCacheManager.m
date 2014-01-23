//
//  PCLCacheManager.m
//  PCLady
//
//  Created by  Michael on 11/11/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLCacheManager.h"

@implementation PCLCacheManager

static PCLCacheManager *sharedInstance = nil;

+ (PCLCacheManager *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[PCLCacheManager alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)saveImage:(NSData *)imgData url:(NSString *)imgUrl {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentDIR = [paths objectAtIndex:0];
	NSString *cacheDIR = [documentDIR stringByAppendingFormat:@"/%@/",ImageCacheDir];
	BOOL isDir=YES;
	if (![fileManager fileExistsAtPath:cacheDIR isDirectory:&isDir]) {
		[fileManager createDirectoryAtPath:cacheDIR withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	NSString *imgFileName = [cacheDIR stringByAppendingFormat:@"%d",[imgUrl hash]];
	if ([fileManager fileExistsAtPath:imgFileName]) {
		[fileManager removeItemAtPath:imgFileName error:NULL];
	}
	[fileManager createFileAtPath:imgFileName contents:nil attributes:nil];
    
    [imgData writeToFile:imgFileName atomically:YES];
}

- (NSData *)loadImageData:(NSString *)imgUrl {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentDIR = [paths objectAtIndex:0];
	NSString *cacheDIR = [documentDIR stringByAppendingFormat:@"/%@/",ImageCacheDir];
	NSString *imgFileName = [cacheDIR stringByAppendingFormat:@"%d",[imgUrl hash]];
    
    NSData *imgData = nil;
	if ([fileManager fileExistsAtPath:imgFileName]) {
        imgData = [NSData dataWithContentsOfFile:imgFileName];
	}
    
    return imgData;
}

- (void)saveArray:(NSArray *)array withKey:(NSString *)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentDIR = [paths objectAtIndex:0];
	NSString *cacheDIR = [documentDIR stringByAppendingFormat:@"/%@/",DataCacheDir];
	BOOL isDir=YES;
	if (![fileManager fileExistsAtPath:cacheDIR isDirectory:&isDir]) {
		[fileManager createDirectoryAtPath:cacheDIR withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	NSString *dataFileName = [cacheDIR stringByAppendingFormat:@"%d",[key hash]];
	if ([fileManager fileExistsAtPath:dataFileName]) {
		[fileManager removeItemAtPath:dataFileName error:NULL];
	}
	[fileManager createFileAtPath:dataFileName contents:nil attributes:nil];
    
    [array writeToFile:dataFileName atomically:YES];
}

- (NSArray *)LoadArrayWithKey:(NSString *)key {
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentDIR = [paths objectAtIndex:0];
	NSString *cacheDIR = [documentDIR stringByAppendingFormat:@"/%@/",DataCacheDir];
	NSString *dataFileName = [cacheDIR stringByAppendingFormat:@"%d",[key hash]];
    NSArray *array = [NSArray arrayWithContentsOfFile:dataFileName];
    return array;
}

- (void)saveDict:(NSDictionary *)dict withKey:(NSString *)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentDIR = [paths objectAtIndex:0];
	NSString *cacheDIR = [documentDIR stringByAppendingFormat:@"/%@/",DataCacheDir];
	BOOL isDir=YES;
	if (![fileManager fileExistsAtPath:cacheDIR isDirectory:&isDir]) {
		[fileManager createDirectoryAtPath:cacheDIR withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	NSString *dataFileName = [cacheDIR stringByAppendingFormat:@"%d",[key hash]];
	if ([fileManager fileExistsAtPath:dataFileName]) {
		[fileManager removeItemAtPath:dataFileName error:NULL];
	}
	[fileManager createFileAtPath:dataFileName contents:nil attributes:nil];
    
    [dict writeToFile:dataFileName atomically:YES];
}

- (NSDictionary *)LoadDictWithKey:(NSString *)key {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentDIR = [paths objectAtIndex:0];
	NSString *cacheDIR = [documentDIR stringByAppendingFormat:@"/%@/",DataCacheDir];
	NSString *dataFileName = [cacheDIR stringByAppendingFormat:@"%d",[key hash]];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:dataFileName];
    return dict;
}

- (void)clearCache {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentDIR = [paths objectAtIndex:0];
	NSString *cacheDIR = [documentDIR stringByAppendingFormat:@"/%@/",DataCacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:cacheDIR error:nil];
    cacheDIR = [documentDIR stringByAppendingFormat:@"/%@/",ImageCacheDir];
    [fileManager removeItemAtPath:cacheDIR error:nil];
}

@end
