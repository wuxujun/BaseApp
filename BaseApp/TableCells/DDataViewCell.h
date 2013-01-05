//
//  DDataViewCell.h
//  DataGrid
//  数据表格 列
//  Created by 吴旭俊 on 12-9-29.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLDataViewCell.h"

@interface DDataViewCell : HLDataViewCell{
    UILabel         *titleLabel;
    UIImageView     *backgroud;
    
    int rowIndex;
    int columnIndex;
    int maxRows;
    int maxColumns;
}
@property (nonatomic,strong)UILabel     *titleLabel;
@property (nonatomic,assign)int         rowIndex;
@property (nonatomic,assign)int         columnIndex;
@property (nonatomic,assign)int         maxRows;
@property (nonatomic,assign)int         maxColumns;

@end
