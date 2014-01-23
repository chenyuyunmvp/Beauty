//
//  PCLDataRequest.h
//  PCLady
//
//  Created by  Michael on 11/12/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCLDataRequest : NSObject

+ (PCLDataRequest *)sharedInstance;
- (id)getMagazineList;
- (id)getMagazineArticles:(NSString *)token;

@end
