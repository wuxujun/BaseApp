//
//  HTextView.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-31.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "HTextView.h"
#import "NSAttributedString+Additions.h"

@implementation HTextView
@synthesize draw=_draw;
@synthesize fontSize=_fontSize;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    self.fontSize=14;
    _draw=YES;
    
    [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self setTextColor:[UIColor clearColor]];
    [self setFont:[UIFont fontWithName:@"Menlo" size:_fontSize]];
    [self setText:self.text];
    [self setDataDetectorTypes:0];
}

-(void)setText:(NSString *)aText
{
    aText=[aText stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
    [super setText:aText];
    [self resetAttributedText];
}

-(NSMutableAttributedString*)setColor:(UIColor *)aColor words:(NSArray *)aWords inText:(NSMutableAttributedString *)mutableAttributedString
{
    NSUInteger count=0,length=[mutableAttributedString length];
    NSRange range=NSMakeRange(0, length);
    for (NSString *op in aWords) {
        count=0,length=[mutableAttributedString length];
        range=NSMakeRange(0, length);
        while (range.location!=NSNotFound) {
            range=[[mutableAttributedString string]rangeOfString:op options:0 range:range];
            if(range.location!=NSNotFound){
                [mutableAttributedString setTextColor:aColor range:NSMakeRange(range.location, [op length])];
                range=NSMakeRange(range.location+range.length, length-(range.location+range.length));
                count++;
            }
        }
    }
    return mutableAttributedString;
}

-(void)highlightingText:(NSMutableAttributedString *)mutableAttributedString
{

}

-(void)resetAttributedText
{
    NSMutableAttributedString   *mutableAttributedString=[NSMutableAttributedString attributedStringWithString:self.text];
    [mutableAttributedString setTextColor:[UIColor blackColor]];
    [mutableAttributedString setFont:self.font];
    
    [self highlightingText:mutableAttributedString];
    self.attributedText=mutableAttributedString;
    [self setTextAlignment:UITextAlignmentLeft];
    
}

-(NSAttributedString*)attributedText
{
    if(!_attributedText)
    {
        [self resetAttributedText];
    }
    return [_attributedText copy];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    _attributedText=[attributedText mutableCopy];
    [self setNeedsDisplay];
}

-(void)resetTextFrame
{
    if(textFrame){
        CFRelease(textFrame);
        textFrame=NULL;
    }
}

-(void)setNeedsDisplay
{
    [self resetTextFrame];
    [super setNeedsDisplay];
}

-(void)drawRect:(CGRect)aRect
{
    if(!_draw){
        return;
    }
    short int cfontsize=self.font.lineHeight;
    CGRect r=self.bounds;
    r.origin.y=self.contentOffset.y;
    [[UIColor clearColor] setFill];
    if (_attributedText) {
        CGContextRef    ctx=UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, r.size.height+6.5), 1.0f, -1.0f));
        NSMutableAttributedString   *attrStrWithLinks=[self.attributedText mutableCopy];
        
        if (textFrame==NULL) {
            NSArray *paragraphs=[self.text componentsSeparatedByString:@"\n"];
            CGSize constraint=CGSizeMake(self.bounds.size.width-8, 999999);
            NSInteger paragraphNo=0;
            CGFloat offset=0;
            NSInteger   fromlocation=0;
            int linesheight=0;
            for (NSString *paragraph in paragraphs) {
                NSString   *_paragraph=[paragraph stringByReplacingOccurrencesOfString:@"\t" withString:@"        "];
                CGSize paragraphSize=[_paragraph sizeWithFont:self.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                offset+=paragraphSize.height;
                
                if (paragraphSize.height==0) {
                    offset+=self.font.lineHeight;
                }
                
                if (offset>self.contentOffset.y) {
                    int linescount=paragraphSize.height/cfontsize;
                    if (linescount>1) {
                        int visible=(int)offset%(int)self.contentOffset.y;
                        linesheight=(paragraphSize.height/cfontsize)-visible/cfontsize;
                        if (visible%cfontsize==0) {
                            linesheight++;
                        }
                        linesheight--;
                        if (linesheight<0) {
                            linesheight=0;
                        }
                    }
                    break;
                }
                fromlocation+=[paragraph length]+1;
                paragraphNo++;
            }
            int delta=(int)self.contentOffset.y%cfontsize+linesheight*cfontsize;
            if (self.contentOffset.y<0) {
                delta=self.contentOffset.y;
            }
            
            CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString((CFAttributedStringRef)CFBridgingRetain(attrStrWithLinks));
            
            drawingRect=CGRectMake(0, -r.origin.y, self.bounds.size.width-8, r.size.height+delta);
            CGMutablePathRef path=CGPathCreateMutable();
            CGPathAddRect(path, NULL, drawingRect);
            
            textFrame=CTFramesetterCreateFrame(framesetter, CFRangeMake(fromlocation, 0), path, NULL);
            CFArrayRef lines=CTFrameGetLines(textFrame);
            CFIndex lineCount=CFArrayGetCount(lines);
            CGPoint lineOrigins[lineCount];
            CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), lineOrigins);
            for (CFIndex lineIndex=0; lineIndex<lineCount; lineIndex++) {
                CTLineRef line=CFArrayGetValueAtIndex(lines, lineIndex);
                CFRange _r=CTLineGetStringRange(line);
                
                NSString *string=[[attrStrWithLinks string]substringWithRange:NSMakeRange(_r.location+_r.length-1, 1)];
                BOOL drawnew=NO;
                
                if ([string isEqualToString:@"/"]||[string isEqualToString:@":"]) {
                    
                }
                
                CGContextSetTextPosition(ctx, lineOrigins[lineIndex].x, lineOrigins[lineIndex].y-r.origin.y);
                if (drawnew) {
                    
                }else{
                    CTLineDraw(line, ctx);
                }
            }
            CGPathRelease(path);
            CFRelease(framesetter);
        }
        CGContextRestoreGState(ctx);
    }
    [super drawRect:aRect];
}
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
@end
