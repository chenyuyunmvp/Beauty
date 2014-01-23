//
//  PCLDataRequest.m
//  PCLady
//
//  Created by  Michael on 11/12/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLDataRequest.h"
#import "CJSONDeserializer.h"
#import "Constants.h"

@implementation PCLDataRequest

static PCLDataRequest *sharedInstance = nil;

+ (PCLDataRequest *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[PCLDataRequest alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (id)getMagazineList {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:getMagazineListUrl]];
    id returnObj = [[CJSONDeserializer deserializer] deserialize:data error:nil];
    return returnObj;
}

- (id)getMagazineArticles:(NSString *)token {
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", getMagazineListUrl, token];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestUrl]];
    id returnObj = [[CJSONDeserializer deserializer] deserialize:data error:nil];
    return returnObj;
}

@end
