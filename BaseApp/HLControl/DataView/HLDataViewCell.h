//
//  HLDataViewCell.h
//  GrpCust
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLDataViewCellInfoProtocol.h"

@protocol HLDataViewCellDelegate;

@interface HLDataViewCell : UIView<HLDataViewCellInfoProtocol>{
    NSUInteger      xPosition,yPosition;
    NSString        *identifier;
    
    BOOL            isHeader; //是否头列信息
    NSUInteger      isOrder;  //是否排序
    
    BOOL            selected;
    BOOL            highlighted;
    
    id<HLDataViewCellDelegate>      delegate;
}

@property (nonatomic,assign)id<HLDataViewCellDelegate>   delegate;
@property (nonatomic,copy)NSString  *identifier;
@property (nonatomic,assign)BOOL     selected;
@property (nonatomic,assign)BOOL     highlighted;

@property (nonatomic,assign)BOOL            isHeader; //是否头列信息
@property (nonatomic,assign)NSUInteger      isOrder;  //是否排序

-(id)initWithReuseIdentifier:(NSString*)identifier;
-(void)prepareForReuse;


@end


@protocol HLDataViewCellDelegate
-(void)dataViewCellWasTouched:(HLDataViewCell*)dataViewCell;
@end
