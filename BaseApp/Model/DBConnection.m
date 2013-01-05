//
//  DBConnection.m
//  CRecord
//
//  Created by 吴旭俊 on 12-9-25.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "DBConnection.h"
#import "StringUtil.h"

@implementation DBConnection

+(void)initialize
{
    NSString   *dbPath=[self getDBPath];
    BOOL success;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    success=[fileManager fileExistsAtPath:dbPath];
    if (success) {
        return;
    }
    NSString *dataPathFromApp=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@SQLITE_DATABASE_NAME];
    
//    NSLog(@"DBConnection initialized resourcePath:%@",dataPathFromApp);
    [fileManager copyItemAtPath:dataPathFromApp toPath:dbPath error:nil];
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return;
    }
    [database executeUpdate:@"create table images('url' TEXT PRIMARY KEY,'image' BLOB,'updated_at' DATETIME)"];
    [database executeUpdate:@"create table menu('id' INTEGER PRIMARY KEY,'supid' INTEGER,'title' TEXT,'image' TEXT,'data_url' TEXT,'state' INTEGER,'updated_at' DATETIME)"];
    [database executeUpdate:@"create table data_json('picktime' TEXT,'url' TEXT,'json' BLOB,'filter' BLOB ,'updated_at' DATETIME,PRIMARY KEY('picktime','url'))"];
    [database executeUpdate:@"create table favorite('id' INTEGER,'type' INTEGER,'title' TEXT,'url' TEXT,'updated_at' DATETIME,PRIMARY KEY('url'))"];
    
    [database close];
}

+(NSString*)getDBPath
{
    NSString *documentsDirectory=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString   *dbPath=[documentsDirectory stringByAppendingPathComponent:@SQLITE_DATABASE_NAME];
    return dbPath;
}

+(void)insertImage:(NSData *)buf forURL:(NSString *)url
{
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return;
    }
    [database beginTransaction];
    [database executeUpdate:@"REPLACE INTO images VALUES(?, ?, DATETIME('now'))",url,buf];
    [database commit];
    [database close];
}

+(NSData*)getImageData:(NSString *)url
{
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return nil;
    }
    FMResultSet *rs=[database executeQuery:@"SELECT image FROM images WHERE url=?",url];
    NSData *result=nil;
    if ([rs next]) {
        result=[rs dataForColumn:@"image"];
    }
    [rs close];
    [database close];
    return  result;
}

+(void)insertMenu:(HLMessage *)message
{
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return;
    }
    [database beginTransaction];
    NSString  *str=[NSString stringWithFormat:@"REPLACE INTO menu VALUES(%d, %d,'%@','','%@',0, DATETIME('now'))",message.mId,message.supId,message.title,message.dataUrl];
    [database executeUpdate:str];
    [database commit];
    [database close];
}
#pragma mark 多条菜单记录
+(void)insertMenus:(NSMutableArray*)datas
{
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return;
    }
    
    [database beginTransaction];
    for (int i=0; i<[datas count]; i++) {
        HLMessage *msg=(HLMessage*)[datas objectAtIndex:i];
        
        [database executeUpdate:[NSString stringWithFormat:@"REPLACE INTO menu VALUES(%d, %d,'%@','','%@',0, DATETIME('now'))",msg.mId,msg.supId,msg.title,msg.dataUrl]];
    }
    [database commit];
    [database close];
}

+(NSMutableArray*)getAllMenus
{
    NSMutableArray *datas=[NSMutableArray array];
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return nil;
    }
    HLMessage *msg;
    FMResultSet *rs=[database executeQuery:@"SELECT * FROM menu"];
    while ([rs next]) {
        msg=[[HLMessage alloc]init];
        msg.mId=[rs intForColumn:@"id"];
        msg.supId=[rs intForColumn:@"supid"];
        msg.title=[rs stringForColumn:@"title"];
        msg.imageUrl=[rs stringForColumn:@"image"];
        msg.dataUrl=[rs stringForColumn:@"data_url"];
        [datas addObject:msg];
    }
    [rs close];
    [database close];
    return datas;
}

+(NSMutableArray*)getMenusGroup
{
    NSMutableArray *datas=[NSMutableArray array];
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return nil;
    }
    HLMessage *msg;
    FMResultSet *rs=[database executeQuery:@"SELECT * FROM menu where supid=6"];
    while ([rs next]) {
        msg=[[HLMessage alloc]init];
        msg.mId=[rs intForColumn:@"id"];
        msg.supId=[rs intForColumn:@"supid"];
        msg.title=[rs stringForColumn:@"title"];
        msg.imageUrl=[rs stringForColumn:@"image"];
        msg.dataUrl=[rs stringForColumn:@"data_url"];
        [datas addObject:msg];
    }
    [rs close];
    [database close];
    return datas;
}

+(NSMutableArray*)getMenus:(NSString*)supId
{
    NSMutableArray *datas=[NSMutableArray array];
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return nil;
    }
    HLMessage *msg;
    FMResultSet *rs=[database executeQuery:@"SELECT * FROM menu where supid=? order by id asc",supId];
    while ([rs next]) {
        msg=[[HLMessage alloc]init];
        msg.mId=[rs intForColumn:@"id"];
        msg.supId=[rs intForColumn:@"supid"];
        msg.title=[rs stringForColumn:@"title"];
        msg.imageUrl=[rs stringForColumn:@"image"];
        msg.dataUrl=[rs stringForColumn:@"data_url"];
        [datas addObject:msg];
    }
    [rs close];
    [database close];
    return datas;
}

+(NSData*)getJsonData:(NSString *)url pdate:(NSString *)pdate flag:(BOOL)aFlag
{
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return nil;
    }
    FMResultSet *rs=[database executeQuery:@"SELECT json,filter FROM data_json WHERE url=? and picktime=?" ,[url md5],pdate];
    NSData *result=nil;
    if ([rs next]) {
        if (aFlag) {
            result=[rs dataForColumn:@"json"];
        }else{
            result=[rs dataForColumn:@"filter"];
        }
    }
    [rs close];
    [database close];
    return  result;

}

+(void)insertJsonData:(NSString *)url pdate:(NSString *)pdate json:(NSData *)json filter:(NSData *)filter
{
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return;
    }
    [database beginTransaction];
    [database executeUpdate:@"REPLACE INTO data_json(picktime,url,json,filter,updated_at) values(?,?,?,?,DATETIME('now'))",pdate,[url md5],json,filter];
    [database commit];
    [database close];
}

+(void)deleteJsonData
{
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return;
    }
    [database beginTransaction];
    [database executeUpdate:@"DELETE FROM data_json"];
    [database commit];
    [database close];
}
+(int)getJsonDataRecords
{
    FMDatabase *database=[FMDatabase databaseWithPath:[self getDBPath]];
    if (![database open]) {
        NSLog(@"Could not open %@",[self getDBPath]);
        return nil;
    }
    FMResultSet *rs=[database executeQuery:@"SELECT json,filter FROM data_json "];
    int result=[rs columnCount];
    [rs close];
    [database close];
    return  result;
}

@end
