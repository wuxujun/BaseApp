//
//  HLQuickLook.h
//  PDF Word 文件读取
//
//  Created by 吴旭俊 on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface HLQuickLook : NSObject<QLPreviewControllerDelegate,QLPreviewControllerDataSource> {
    
    NSArray *paths;
}
@property (nonatomic,strong)NSArray *paths;

@end
