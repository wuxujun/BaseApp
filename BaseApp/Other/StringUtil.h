//
//  StringUtil.h
//  TwitterFon
//
//  Created by kaz on 7/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (NSStringUtils)
- (NSString*)encodeAsURIComponent;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;
+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)base64encode:(NSString*)str;

//根据文本，计算高度
+(float)calcTextBoundsHeight:(NSString*)str toSize:(CGSize)size fontSize:(float)fSize; 


-(NSString*)md5;
-(NSString*)urlEncode;
@end


