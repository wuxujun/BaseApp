//
//  NSAttributedString+Additions.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-31.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "NSAttributedString+Additions.h"
#import "HMacros.h"

CGPoint CGPointFlipped(CGPoint point, CGRect bounds);
CGRect CGRectFlipped(CGRect rect, CGRect bounds);
NSRange NSRangeFromCFRange(CFRange range);
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin);
CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin);
BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range);
BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range);
CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment);
CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode);


CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment) {
	switch (alignment) {
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
            
		default: return kCTNaturalTextAlignment;
	}
}

CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode) {
	switch (lineBreakMode) {
		case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
		case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
		case UILineBreakModeClip: return kCTLineBreakByClipping;
		case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
		case UILineBreakModeTailTruncation: return kCTLineBreakByTruncatingTail;
		case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
		default: return 0;
	}
}

// Don't use this method for origins. Origins always depend on the height of the rect.
CGPoint CGPointFlipped(CGPoint point, CGRect bounds) {
	return CGPointMake(point.x, CGRectGetMaxY(bounds)-point.y);
}

CGRect CGRectFlipped(CGRect rect, CGRect bounds) {
	return CGRectMake(CGRectGetMinX(rect),
					  CGRectGetMaxY(bounds)-CGRectGetMaxY(rect),
					  CGRectGetWidth(rect),
					  CGRectGetHeight(rect));
}

NSRange NSRangeFromCFRange(CFRange range) {
	return NSMakeRange(range.location, range.length);
}

// Font Metrics:
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin) {
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	CGFloat height = ascent + descent /* + leading */;
	
	return CGRectMake(lineOrigin.x,
					  lineOrigin.y - descent,
					  width,
					  height);
}

CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin) {
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
	CGFloat height = ascent + descent /* + leading */;
	
	CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
	
	return CGRectMake(lineOrigin.x + xOffset,
					  lineOrigin.y - descent,
					  width,
					  height);
}

BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range) {
	NSRange lineRange = NSRangeFromCFRange(CTLineGetStringRange(line));
	NSRange intersectedRange = NSIntersectionRange(lineRange, range);
	return (intersectedRange.length > 0);
}

BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range) {
	NSRange runRange = NSRangeFromCFRange(CTRunGetStringRange(run));
	NSRange intersectedRange = NSIntersectionRange(runRange, range);
	return (intersectedRange.length > 0);
}

TT_FIX_CATEGORY_BUG(NSAttributedString)
@implementation NSAttributedString (Additions)

+(id)attributedStringWithString:(NSString *)aString
{
    return aString ? [[self alloc]initWithString:aString] : nil;
}

+(id)attributedStringWithAttributedString:(NSAttributedString *)aAttrString
{
    return aAttrString ? [[self alloc]initWithAttributedString:aAttrString]:nil;
}

-(CGSize)sizeConstrainedToSize:(CGSize)maxSize
{
    return [self sizeConstrainedTosize:maxSize fitRange:NULL];
}

-(CGSize)sizeConstrainedTosize:(CGSize)maxSize fitRange:(NSRange *)fitRange
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)CFBridgingRetain(self));
	CFRange fitCFRange = CFRangeMake(0,0);
	CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,maxSize,&fitCFRange);
	if (framesetter) CFRelease(framesetter);
	if (fitRange) *fitRange = NSMakeRange(fitCFRange.location, fitCFRange.length);
	return CGSizeMake( floorf(sz.width+1) , floorf(sz.height+1) );
}
@end


TT_FIX_CATEGORY_BUG(NSMutableAttributedString)
@implementation NSMutableAttributedString(Additions)

-(void)setFont:(UIFont *)aFont
{
    [self setFontName:aFont.fontName size:aFont.pointSize lineHeight:aFont.lineHeight];
}

-(void)setFont:(UIFont *)aFont range:(NSRange)aRange
{
    [self setFontName:aFont.fontName size:aFont.pointSize range:aRange lineHeight:aFont.lineHeight];
}

-(void)setFontName:(NSString *)aFontName size:(CGFloat)aSize lineHeight:(CGFloat)aLineHeight
{
    [self setFontName:aFontName size:aSize range:NSMakeRange(0, [self length]) lineHeight:aLineHeight];
}

-(void)setFontName:(NSString *)aFontName size:(CGFloat)aSize range:(NSRange)aRange lineHeight:(CGFloat)aLineHeight
{
    CGAffineTransform   textTransform=CGAffineTransformMakeScale(1, 1);
    CTFontRef   font=CTFontCreateWithName((CFStringRef)CFBridgingRetain(aFontName), aSize, &textTransform);
    if (!font) {
        return;
    }
    
#define num 10
    CGFloat    HeadIndent=8.0;
    CGFloat    FirstLineHeadIndent=8.0f;
    CGFloat spacing=0.0;
    CGFloat topSpacing=0.0f;
    CGFloat lineSpacing=0.0f;
    CGFloat tabInterval=67.4;
    CGFloat firstTabStop = 8.0; // width of your indent
    
    CTTextTabRef tabArray[] = { CTTextTabCreate(0, firstTabStop, NULL) };
    
    CFArrayRef tabStops = CFArrayCreate( kCFAllocatorDefault, (const void**) tabArray, 1, &kCFTypeArrayCallBacks );
    CFRelease(tabArray[0]);
    
    
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    CTParagraphStyleSetting settings[num] =
    {
        { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
        //        { kCTParagraphStyleSpecifierTailIndent,  sizeof(CGFloat), &Tail},
        { kCTParagraphStyleSpecifierDefaultTabInterval,  sizeof(CGFloat), &tabInterval},
        { kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops},
        { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &spacing },
        // space
        { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &topSpacing },
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
        // position
        { kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &FirstLineHeadIndent },
        { kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &HeadIndent},
        // height
        { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(aLineHeight), &aLineHeight },
        { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(aLineHeight), &aLineHeight }
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, num);
    
    
    
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    
                                    (id)CFBridgingRelease(font), (id)kCTFontAttributeName,
                                    
                                    [UIColor blackColor].CGColor, (id)kCTForegroundColorAttributeName,
                                    
                                    paragraphStyle, (id)kCTParagraphStyleAttributeName,
                                    
                                    nil];
    
    [self addAttributes:attributesDict range:aRange];
    
    CFRelease(font);
}

-(void)setfontFamily:(NSString *)aFontFamily size:(CGFloat)aSize bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)aRange
{
 	CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
	NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:symTrait] forKey:(NSString*)kCTFontSymbolicTrait];
    
	NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
						  aFontFamily,kCTFontFamilyNameAttribute,
						  trait,kCTFontTraitsAttribute,nil];
	
	CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)CFBridgingRetain(attr));
	if (!desc) return;
	CTFontRef font = CTFontCreateWithFontDescriptor(desc, aSize, NULL);
	CFRelease(desc);
	if (!font) return;
    
	[self removeAttribute:(NSString*)kCTFontAttributeName range:aRange]; // Work around for Apple leak
	[self addAttribute:(NSString*)kCTFontAttributeName value:(id)CFBridgingRelease(font) range:aRange];
	CFRelease(font);
}

- (void)setTextColor:(UIColor*)aColor {
	[self setTextColor:aColor range:NSMakeRange(0,[self length])];
}

-(void)setTextColor:(UIColor *)aColor range:(NSRange)aRange
{
	// kCTForegroundColorAttributeName
	[self removeAttribute:(NSString*)kCTForegroundColorAttributeName range:aRange]; // Work around for Apple leak
	[self addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)aColor.CGColor range:aRange];
}

- (void)setTextIsUnderlined:(BOOL)underlined {
	[self setTextIsUnderlined:underlined range:NSMakeRange(0,[self length])];
}

-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)aRange
{
	int32_t style = underlined ? (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid) : kCTUnderlineStyleNone;
	[self setTextUnderlineStyle:style range:aRange];
}
- (void)setTextUnderlineStyle:(int32_t)style range:(NSRange)aRange {
	[self removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:aRange]; // Work around for Apple leak
	[self addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:aRange];
}

-(void)setTextBold:(BOOL)isBold range:(NSRange)aRange
{
	NSUInteger startPoint = aRange.location;
	NSRange effectiveRange;
	do {
		// Get font at startPoint
		CTFontRef currentFont = (CTFontRef)CFBridgingRetain([self attribute:(NSString*)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange]);
		// The range for which this font is effective
		NSRange fontRange = NSIntersectionRange(aRange, effectiveRange);
		// Create bold/unbold font variant for this font and apply
		CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(currentFont, 0.0, NULL, (bold?kCTFontBoldTrait:0), kCTFontBoldTrait);
		if (newFont) {
			[self removeAttribute:(NSString*)kCTFontAttributeName range:fontRange]; // Work around for Apple leak
			[self addAttribute:(NSString*)kCTFontAttributeName value:(id)CFBridgingRelease(newFont) range:fontRange];
			CFRelease(newFont);
		}
		// If the fontRange was not covering the whole range, continue with next run
		startPoint = NSMaxRange(effectiveRange);
	} while(startPoint<NSMaxRange(aRange));
}

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode
{
	[self setTextAlignment:alignment lineBreakMode:lineBreakMode range:NSMakeRange(0,[self length])];
}

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)aRange
{
	// kCTParagraphStyleAttributeName > kCTParagraphStyleSpecifierAlignment
    
	CTParagraphStyleSetting paraStyles[2] = {
		{.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
        
		{.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode},
	};
    
	CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 2);
	[self removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:aRange]; // Work around for Apple leak
	[self addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(id)CFBridgingRelease(aStyle) range:aRange];
	CFRelease(aStyle);
}


@end