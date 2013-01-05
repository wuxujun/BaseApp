//
//  PullRefreshViewController.h
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-22.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>

#define REFRESH_FOOTER_HEIGHT   70.0f

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]

#define startOffset             (scrollView.contentSize.height - scrollView.frame.size.height)
#define contentOffsetY          (scrollView.contentOffset.y + REFRESH_FOOTER_HEIGHT - startOffset)

#define UIEdgeInsetsOriginal    UIEdgeInsetsMake( 0, 0,-REFRESH_FOOTER_HEIGHT, 0)
#define UIEdgeInsetsFinal       UIEdgeInsetsMake( 0, 0,0, 0)
#define UIEdgeInsetsMiddle      UIEdgeInsetsMake(0, 0, -(scrollView.contentOffset.y - startOffset), 0)


@interface PullRefreshViewController : UITableViewController
{
    UIView *refreshFooterView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;

    UILabel *lastUpdatedLabel;
    UILabel *statusLabel;
}

@property (nonatomic, retain) UIView *refreshFooterView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;

- (void)setupStrings;
- (void)addPullToRefreshFooter;
//- (void)startLoading;
- (void)stopLoading;
- (void)refresh;

@end
