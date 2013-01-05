//
//  PullRefreshViewController.m
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-22.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "PullRefreshViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PullRefreshViewController ()

@end

@implementation PullRefreshViewController
@synthesize textPull, textRelease, textLoading, refreshFooterView, refreshLabel, refreshArrow, refreshSpinner;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self!=nil) {
        // Custom initialization
        [self setupStrings];
    }
    return self;
}

-(id)init
{
    self=[super init];
    if (self!=nil) {
        [self setupStrings];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (void)setupStrings
{
    textPull    = @"上拉可以刷新...";
    textRelease = @"松开即可刷新...";
    textLoading =@"加载中...";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsOriginal;
    [self addPullToRefreshFooter];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addPullToRefreshFooter {
    refreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, REFRESH_FOOTER_HEIGHT)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    self.tableView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, REFRESH_FOOTER_HEIGHT - 40.0f, 320.0f, 20.0f)];
    lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lastUpdatedLabel.text = @"最后更新:今天10：30";
    lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
    lastUpdatedLabel.textColor = TEXT_COLOR;
    lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    lastUpdatedLabel.backgroundColor = [UIColor clearColor];
    lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, REFRESH_FOOTER_HEIGHT - 55.0f, 320.0f, 20.0f)];
    refreshLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    refreshLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    refreshLabel.textColor = TEXT_COLOR;
    refreshLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    refreshLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.textAlignment = UITextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueArrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_FOOTER_HEIGHT - 30) / 2),
                                    (floorf(REFRESH_FOOTER_HEIGHT - 55) / 2),
                                    30, 55);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_FOOTER_HEIGHT - 20) / 2), floorf((REFRESH_FOOTER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshFooterView addSubview:lastUpdatedLabel];
    [refreshFooterView addSubview:refreshLabel];
    [refreshFooterView addSubview:refreshArrow];
    [refreshFooterView addSubview:refreshSpinner];
    [self.tableView setTableFooterView:refreshFooterView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (contentOffsetY < 0)
            self.tableView.contentInset = UIEdgeInsetsOriginal;
        else if (contentOffsetY <= REFRESH_FOOTER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMiddle;
    } else if (isDragging && contentOffsetY > 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (contentOffsetY > REFRESH_FOOTER_HEIGHT) {
            // User is scrolling above the header
            refreshLabel.text = self.textRelease;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshLabel.text = self.textPull;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}


- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsFinal;
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self refresh];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (contentOffsetY >= REFRESH_FOOTER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}



- (void)stopLoading {
    isLoading = NO;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM月dd日 hh:mm"];
    lastUpdatedLabel.text = [formatter stringFromDate:[NSDate date]];
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.tableView.contentInset = UIEdgeInsetsOriginal;
    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI , 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

@end
