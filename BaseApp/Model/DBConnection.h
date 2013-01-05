//
//  DBConnection.h
//  CRecord
//
//  Created by 吴旭俊 on 12-9-25.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "HLMessage.h"

#define SQLITE_DATABASE_NAME "dd.sqlite"

@interface DBConnection : NSObject{

}
+(void)initialize;

+(NSString*)getDBPath;
+(void)insertImage:(NSData*)buf forURL:(NSString*)url;
+(NSData*)getImageData:(NSString*)url;

+(void)insertMenus:(NSMutableArray*)datas;
+(void)insertMenu:(HLMessage*)message;
+(NSMutableArray*)getAllMenus;

+(NSMutableArray*)getMenusGroup;
+(NSMutableArray*)getMenus:(NSString*)supId;

+(NSData*)getJsonData:(NSString*)url pdate:(NSString*)pdate flag:(BOOL)aFlag;
+(void)insertJsonData:(NSString*)url pdate:(NSString*)pdate json:(NSData*)json filter:(NSData*)filter;
+(void)deleteJsonData;
+(int)getJsonDataRecords;
@end
