//
// OWActivityViewController.h
// OWActivityViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "OWActivityView.h"
#import "OWActivities.h"

typedef void (^OWActivityViewControllerCompletionHandler)(OWActivity * activity, BOOL isCompletion);

@interface OWActivityViewController : UIViewController {
    UIView *_backgroundView;
    BOOL popoverAtIPad;
}

@property (strong, readonly, nonatomic) NSArray *activities;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) OWActivityView *activityView;
@property (weak, nonatomic) UIPopoverController *presentingPopoverController;
@property (weak, nonatomic) UIViewController *presentingController;
@property(nonatomic,copy) OWActivityViewControllerCompletionHandler completionHandler;

- (id)initWithViewController:(UIViewController *)viewController activities:(NSArray *)activities;
//- (id)initWithViewController:(UIViewController *)viewController
//                  activities:(NSArray *)activities
//               popoverAtIPad:(BOOL)popover;
- (void)presentFromRootViewController;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@end