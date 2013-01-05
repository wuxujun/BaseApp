//
//  CoreDataManager.h
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Images.h"

@interface CoreDataManager : NSObject
{
    NSManagedObjectContext      *_managedObjContext;
    NSManagedObjectModel        *_managedObjModel;
    NSPersistentStoreCoordinator    *_persistentStoreCoordinator;
    
}
@property (nonatomic,strong,readonly)NSManagedObjectContext *managedObjContext;
@property (nonatomic,strong,readonly)NSManagedObjectModel   *managedObjModel;
@property (nonatomic,strong,readonly)NSPersistentStoreCoordinator   *persistentStoreCoordinator;

+(CoreDataManager*)getInstance;
-(void)insertImageToCD:(NSData*)aData url:(NSString*)aUrl;
-(Images*)readImageFromCD:(NSString*)aUrl;

-(void)cleanEntityRecords:(NSString*)entityName;

@end
