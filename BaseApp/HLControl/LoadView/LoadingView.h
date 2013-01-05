//
//  LoadingView.h
//  UniCust
//
//  Created by 吴旭俊 on 11-5-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIView {
	UIActivityIndicatorView		*_activity;
	BOOL						_hidden;
	NSString					*_title;
	NSString					*_message;
	float						radius;
}

@property (copy,nonatomic)NSString	*title;
@property (copy,nonatomic)NSString	*message;
@property (assign,nonatomic)float	radius;

- (id) initWithTitle:(NSString*)title message:(NSString*)message;
- (id) initWithTitle:(NSString*)title;

- (void) startAnimating;
- (void) stopAnimating;


@end
