//
//  Constants.h
//  PCLady
//
//  Created by  Michael on 10/16/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

CGFloat screenHeight;

#define onIOS7                ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f)

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define mainQueue dispatch_get_main_queue()

// http://magma.earra.co/api/issues
#define HostUrl                 @"http://magma.earra.co/"
#define getMagazineListUrl      @"http://magma.earra.co/api/issues/"


#define         MagazineInfoKey         @"magazineInfo:%@"
#define         MagazineListKey         @"magazineList"