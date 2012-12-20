//
//  BoxRequest.h
//  WBMuster
//
//  Created by xujun wu on 12-11-9.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BOX_APP_KEY             @"amqd9wtcfos3hykertti0fgi5nkdd40p"
#define BOX_GET_TICKET           @"https://www.box.com/api/1.0/rest"
#define BOX_API_AUTH            @"https://www.box.com/api/1.0/auth"
#define BOX_API_DOMAIN          @"https://api.box.com/2.0"

#define BOX_USER_INFO_REQUEST_TYPE       @"BOXRequestType"
#define BOX_USER_STORE_AUTH_TOKEN        @"BOXAuthToken"
#define BOX_USER_STORE_AUTH_TICKET       @"BOXAuthTicket"

#define BOX_USER_LOGIN                   @"BOXUserLogin"
#define BOX_USER_ID                      @"BOXUserID"
#define BOX_USER_ACCESS_ID               @"BOXAccessID"
#define BOX_USER_SPACE_AMOUNT            @"NetbankQuota"
#define BOX_USER_SPACE_USED              @"NetbankAvailable"
#define BOX_USER_MAX_UPLOAD_SIZE         @"BOXUserMaxUploadSize"

#define BOX_USER_INIT                    @"BOXUserInit"


#define BOXRequestFailed                 @"RequestFailed"

#define BOXRequestTicketFinished         @"BOXRequestTicketFinished"  

#define BOXRequestDataFinished           @"RequestDataFinished"

typedef enum{
    BOXGetTicket=0,
    BOXGetAuthToken,
    BoxGetAllFiles,
} BOXRequestType;

@class ASINetworkQueue;

@protocol BoxRequestDelegate <NSObject>


@optional
-(void)didGetTicket:(NSString*)aTicket;
-(void)didGetUserInfo;


-(void)didGetDataFalied:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;
-(void)didGetDataFinished:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;

@end

@interface BoxRequest : NSObject<NSXMLParserDelegate>{
    ASINetworkQueue         *requestQueue;
    __unsafe_unretained id<BoxRequestDelegate>      delegate;
    
    NSMutableString            *currentProperty;
}
@property (nonatomic,strong)NSMutableString                *currentProperty;

@property (nonatomic,strong)ASINetworkQueue         *requestQueue;
@property (nonatomic,assign)id<BoxRequestDelegate>  delegate;

-(id)initWithDelegate:(id<BoxRequestDelegate>)aDelegate;
-(BOOL)isRunning;
-(void)start;
-(void)pause;
-(void)resume;
-(void)cancel;

-(void)getTicket;

-(NSURL*)getOAuthCodeUrl:(NSString*)ticket;
-(void)getAuthToken;

-(void)getAllFiles;


-(void)getData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;


@end
