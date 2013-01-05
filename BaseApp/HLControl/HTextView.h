//
//  HTextView.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-31.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface HTextView : UITextView
{
    NSMutableAttributedString           *_attributedText;
    CTFrameRef                          textFrame;
    
    CGRect                              drawingRect;
}
@property (nonatomic,copy)NSAttributedString    *attributedText;
@property (nonatomic)BOOL                       draw;
@property short int                             fontSize;

-(void)resetAttributedText;
-(NSMutableAttributedString*)setColor:(UIColor*)aColor words:(NSArray*)aWords inText:(NSMutableAttributedString*)mutableAttributedString;

-(void)highlightingText:(NSMutableAttributedString*)mutableAttributedString;
@end
