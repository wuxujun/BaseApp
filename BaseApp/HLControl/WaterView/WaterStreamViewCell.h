//
//  WaterStreamViewCell.h
//  BaseApp
//
//  Created by xujun wu on 12-12-7.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface WaterStreamViewCell : UITableViewCell

@property (nonatomic,copy)NSString      *reuseIdentifier;
@property (nonatomic,strong)NSDictionary        *picDict;

-(id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
