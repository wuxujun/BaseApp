//
//  User.h
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-22.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    GenderUnknow = 0,
    GenderMale,
    GenderFemale,
} Gender;

@interface User : NSObject
{
	long long    userId; //用户UID
	NSNumber		*userKey;
	NSString*   screenName; //微博昵称
    NSString*   name; //友好显示名称，如Bill Gates(此特性暂不支持)
	NSString*	province; //省份编码（参考省份编码表）
	NSString*	city; //城市编码（参考城市编码表）
	NSString*   location; //地址
	NSString*   description; //个人描述
	NSString*   url; //用户博客地址
	NSString*   profileImageUrl; //自定义图像
    UIImage*    avatarImage;//头像image
	NSString*	profileLargeImageUrl; //大图像地址
	NSString*	domain; //用户个性化URL
	Gender		gender; //性别,m--男，f--女,n--未知
	int    followersCount; //粉丝数
    int    friendsCount; //关注数
    int    statusesCount; //微博数
    int    favoritesCount; //收藏数
	time_t      createdAt; //创建时间
    BOOL        following; //是否已关注(此特性暂不支持)
    BOOL        verified; //加V标示，是否微博认证用户
	BOOL		allowAllActMsg; //?
	BOOL		geoEnabled; //?
}

@property (nonatomic, assign) long long  userId;
@property (nonatomic, strong) NSNumber*		userKey;
@property (nonatomic, strong) NSString* screenName;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* province;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSString* location;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* profileImageUrl;
@property (nonatomic, strong) NSString* profileLargeImageUrl;
@property (nonatomic, strong) NSString* domain;
@property (nonatomic, assign) Gender gender;
@property (nonatomic, assign) int  followersCount;
@property (nonatomic, assign) int  friendsCount;
@property (nonatomic, assign) int  statusesCount;
@property (nonatomic, assign) int  favoritesCount;
@property (nonatomic, assign) time_t	createdAt;
@property (nonatomic, assign) BOOL      following;
@property (nonatomic, assign) BOOL		verified;
@property (nonatomic, assign) BOOL		allowAllActMsg;
@property (nonatomic, assign) BOOL		geoEnabled;
@property (nonatomic, strong) UIImage*    avatarImage;

- (User*)initWithJsonDictionary:(NSDictionary*)dic;
- (void)updateWithJSonDictionary:(NSDictionary*)dic;
+ (User*)userWithJsonDictionary:(NSDictionary*)dic;

@end
