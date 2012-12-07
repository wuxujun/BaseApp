//
//  LoadingMoreFooterView.h
//  SAnalysis
//
//  Created by xujun wu on 12-11-1.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingMoreFooterView : UIView

@property(nonatomic, readwrite) BOOL showActivityIndicator;
@property(nonatomic, readwrite, getter = isRefreshing) BOOL refreshing;
@property(nonatomic, readwrite) BOOL enabled;   // in case that no more items to load
@property(nonatomic, readwrite) UITextAlignment textAlignment;

@end
