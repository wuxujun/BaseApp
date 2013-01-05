//
//  Comment.h
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-22.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Status.h"

@interface Comment : NSObject {
	long		commentId; // 评论ID
	NSNumber*		commentKey;
	NSString*		text; //评论内容
	time_t			createdAt; //评论时间
	NSString*		source; //评论来源
	NSString*		sourceUrl;
	BOOL			favorited; //是否收藏
	BOOL			truncated; //是否被截断
	User*			user; //评论人信息
	Status*			status; //评论的微博
	Comment*		replyComment; //评论来源
}

@property (nonatomic, assign) long		commentId; // 评论ID
@property (nonatomic, strong) NSNumber*		commentKey;
@property (nonatomic, readonly) NSString*         timestamp;
@property (nonatomic, strong) NSString*		text; //评论内容
@property (nonatomic, assign) time_t			createdAt; //评论时间
@property (nonatomic, strong) NSString*		source; //评论来源
@property (nonatomic, strong) NSString*		sourceUrl; //评论来源
@property (nonatomic, assign) BOOL			favorited; //是否收藏
@property (nonatomic, assign) BOOL			truncated; //是否被截断
@property (nonatomic, strong) User*			user; //评论人信息
@property (nonatomic, strong) Status*			status; //评论的微博
@property (nonatomic, strong) Comment*		replyComment; //评论来源


- (Comment*)initWithJsonDictionary:(NSDictionary*)dic;

+ (Comment*)commentWithJsonDictionary:(NSDictionary*)dic;

@end
