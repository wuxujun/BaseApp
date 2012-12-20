//
//  HMacros.h
//  BaseApp
//
//  Created by xujun wu on 12-11-21.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#define TT_FIX_CATEGORY_BUG(name) @interface TT_FIX_CATEGORY_BUG_##name @end \
@implementation TT_FIX_CATEGORY_BUG_##name @end
