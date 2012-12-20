//
//  LiveUserView.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-31.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "UIViewExtention.h"

@interface LiveUserView : UIViewExtention
{
    UIView                  *contentView;
    UILabel                 *nameLabel;
    UIImageView             *iconView;
    
}
@property (nonatomic,strong)NSString        *name;
@property (nonatomic,strong)NSString        *iconUrl;



@end
