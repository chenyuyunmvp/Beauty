//
// OWActivityView.h
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

#import "OWActivityView.h"
#import "OWActivityViewController.h"
#import "Constants.h"

@implementation OWActivityView

- (id)initWithFrame:(CGRect)frame activities:(NSArray *)activities
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _activities = activities;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 417)];
            if (onIOS7) {
                _backgroundImageView.backgroundColor = [UIColor colorWithRed:249.f/255.f
                                                                       green:249.f/255.f
                                                                        blue:249.f/255.f
                                                                       alpha:1.f];
            } else {
                _backgroundImageView.image = [UIImage imageNamed:@"OWActivityViewController.bundle/Background"];
            }
            _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_backgroundImageView];
        }
    
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 39, frame.size.width, self.frame.size.height - 104)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scrollView];

        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 84, frame.size.width, 10)];
        [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (onIOS7) {
            [_cancelButton setTitleColor:[UIColor colorWithRed:0.f/255.f
                                                         green:125.f/255.f
                                                          blue:255.f/255.f
                                                         alpha:1.f]
                                forState:UIControlStateNormal];
            [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:23.f]];
        } else {
            [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"OWActivityViewController.bundle/Button"] stretchableImageWithLeftCapWidth:22 topCapHeight:47] forState:UIControlStateNormal];
            [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_cancelButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] forState:UIControlStateNormal];
            [_cancelButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
            [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
        }
        _cancelButton.frame = CGRectMake(22, 352, 276, 47);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return self;
}

- (UIView *)viewForActivity:(OWActivity *)activity index:(NSInteger)index x:(NSInteger)x y:(NSInteger)y
{
    UIView * view = [_scrollView viewWithTag:index+1];
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(x, y, 80, 80)];
        view.tag = index+1;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 0, 59, 59);
        button.tag = index;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:activity.image forState:UIControlStateNormal];
        button.accessibilityLabel = activity.title;
        [view addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 61, 80, 30)];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        if (onIOS7) {
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
        } else {
            label.textColor = [UIColor whiteColor];
            label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
            label.shadowOffset = CGSizeMake(0, 1);
            label.font = [UIFont boldSystemFontOfSize:12];
        }
        label.text = activity.title;
        label.numberOfLines = 0;
        [label setNumberOfLines:0];
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.origin.x = round((view.frame.size.width - frame.size.width) / 2.0f);
        label.frame = frame;
        [view addSubview:label];
        [_scrollView addSubview:view];
    } else {
        CGRect frame = view.frame;
        frame.origin = CGPointMake(x, y);
        [view setFrame:frame];
    }
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSInteger activityCount = [_activities count];
    NSInteger maxAtRow, maxAtPage, rowSpacing, colSpacing;
    CGFloat cancelBtnBottomSpacing,pageBottomSpacing;
    UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ||
        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) != YES &&
         [[UIDevice currentDevice] orientation] != UIDeviceOrientationPortraitUpsideDown)) {
        maxAtRow = 3;
        maxAtPage = 9;
        rowSpacing = 20;
        activityCount = activityCount>=maxAtRow?maxAtRow:activityCount;
        colSpacing = (self.frame.size.width - 80*activityCount)/(activityCount+1);
        cancelBtnBottomSpacing = _cancelButton.frame.size.height+16;
        pageBottomSpacing = 84;
    } else {
        maxAtRow = 4;
        maxAtPage = 8;
        rowSpacing = 10;
        activityCount = activityCount>=maxAtRow?maxAtRow:activityCount;
        colSpacing = (self.frame.size.width - 80*activityCount)/(activityCount+1);
//        if (IPhone5) {
//            colSpacing = 50;
//        } else {
//            colSpacing = 32;
//        }        
        cancelBtnBottomSpacing = _cancelButton.frame.size.height+10;
        pageBottomSpacing = cancelBtnBottomSpacing+10;
    }
    
    // layout the activities
    NSInteger index = 0;
    NSInteger row = -1;
    NSInteger page = -1;
    for (OWActivity *activity in _activities) {
        NSInteger col;
        
        col = index%maxAtRow;
        if (index % maxAtRow == 0) row++;
        if (index % maxAtPage == 0) {
            row = 0;
            page++;
        }
        
        UIView *view = [self viewForActivity:activity
                                       index:index
                                           x:(colSpacing + col*80 + col*colSpacing) + page * self.frame.size.width
                                           y:row*80 + row*rowSpacing];
        index++;
    }
    _scrollView.contentSize = CGSizeMake((page +1) * self.frame.size.width, _scrollView.frame.size.height);
    _scrollView.pagingEnabled = YES;

    // layout the page control
    _pageControl.numberOfPages = page + 1;
    CGRect pageFrame = _pageControl.frame;
    pageFrame.origin.y  = self.frame.size.height- pageBottomSpacing;
    _pageControl.frame = pageFrame;
    if (_pageControl.numberOfPages <= 1) {
        _pageControl.hidden = YES;
        _scrollView.scrollEnabled = NO;
    }
    
    // layout the cancel button
    CGRect frame = _cancelButton.frame;
    frame.origin.y = self.frame.size.height - cancelBtnBottomSpacing;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2.0f;
    _cancelButton.frame = frame;
}

#pragma mark -
#pragma mark Button action

- (void)cancelButtonPressed
{
    [_activityViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonPressed:(UIButton *)button
{
    OWActivity *activity = [_activities objectAtIndex:button.tag];
    activity.activityViewController = _activityViewController;
    if (activity.actionBlock) {
        activity.actionBlock(activity, _activityViewController);
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

#pragma mark -

- (void)pageControlValueChanged:(UIPageControl *)pageControl
{
    CGFloat pageWidth = _scrollView.contentSize.width /_pageControl.numberOfPages;
    CGFloat x = _pageControl.currentPage * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.frame.size.height) animated:YES];
}

@end
