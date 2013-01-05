//
//  DDataView.h
//  GrpCust
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLDataView.h"
#import "HLDataViewCell.h"
#import "DDataViewCell.h"
#import "HLMessage.h"
#import "DBConnection.h"

@interface DDataView : UIView<HLDataViewDelegate>{

    HLDataView          *gridView;
}
@property (nonatomic,strong)IBOutlet  HLDataView        *gridView;
@property (nonatomic,strong)HLMessage                     *message;

-(void)reloadData;

@end
