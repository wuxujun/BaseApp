//
//  NSAttributedString+Additions.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-31.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString(Additions)

+(id)attributedStringWithString:(NSString*)aString;
+(id)attributedStringWithAttributedString:(NSAttributedString*)aAttrString;
-(CGSize)sizeConstrainedToSize:(CGSize)maxSize;
-(CGSize)sizeConstrainedTosize:(CGSize)maxSize fitRange:(NSRange*)fitRange;

@end


@interface NSMutableAttributedString (Additions)

-(void)setFont:(UIFont*)aFont;
-(void)setFont:(UIFont *)aFont range:(NSRange)aRange;
-(void)setFontName:(NSString*)aFontName size:(CGFloat)aSize lineHeight:(CGFloat)aLineHeight;
-(void)setFontName:(NSString *)aFontName size:(CGFloat)aSize range:(NSRange)aRange lineHeight:(CGFloat)aLineHeight;
-(void)setfontFamily:(NSString*)aFontFamily size:(CGFloat)aSize bold:(BOOL)isBold  italic:(BOOL)isItalic range:(NSRange)aRange;

-(void)setTextColor:(UIColor*)aColor;
-(void)setTextColor:(UIColor *)aColor range:(NSRange)aRange;
-(void)setTextIsUnderlined:(BOOL)underlined;
-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)aRange;
-(void)setTextUnderlineStyle:(int32_t)style range:(NSRange)aRange;

-(void)setTextBold:(BOOL)isBold range:(NSRange)aRange;
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode;
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)aRange;


@end