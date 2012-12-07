//
//  HLDialog.h
//  UniCust
//
//  Created by 吴旭俊 on 11-5-13.
//  Copyright 2011 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HLDialog : UIView<UIWebViewDelegate> {
	
}

@end


@protocol HLDialogDelegate<NSObject>
@optional

-(void)didlogDidSucced:(HLDialog*)dialog;

-(void)dialogDidCancel:(HLDialog*)dialog;

-(void)dialog:(HLDialog*)dialog didFailWithError:(NSError*)error;
-(BOOL)dialog:(HLDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL*)url;

@end