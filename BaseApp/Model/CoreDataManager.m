//
//  CoreDataManager.m
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>

static CoreDataManager      *instance;
@implementation CoreDataManager
@synthesize managedObjContext=_managedObjContext;
@synthesize managedObjModel=_managedObjModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

-(id)init
{
    self=[super init];
    if (self) {
        NSManagedObjectContext *context=self.managedObjContext;
        if (context==nil) {
            NSLog(@"createManagedObjContext error");
        }
    }
    return self;
}

+(CoreDataManager*)getInstance
{
    @synchronized(self){
        if(instance==nil){
            instance=[[CoreDataManager alloc]init];
        }
    }
    return instance;
}

-(void)insertImageToCD:(NSData *)aData url:(NSString *)aUrl
{
    if ([self readImageFromCD:aUrl]!=nil) {
        return;
    }
    Images   *image=(Images*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:_managedObjContext];
    image.createDate=[NSDate date];
    image.url=aUrl;
    image.data=aData;
    
    NSError *error;
    if (![_managedObjContext save:&error]) {
        NSLog(@"%@",[error debugDescription]);
    }
}

-(Images*)readImageFromCD:(NSString *)aUrl
{
    NSFetchRequest *fetch=[[NSFetchRequest alloc]init];

    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Images" inManagedObjectContext:_managedObjContext];
    NSPredicate *pred=[NSPredicate predicateWithFormat:@"url==%@",aUrl];
    [fetch setPredicate:pred];
    [fetch setEntity:entity];
    NSError *error=nil;
    NSMutableArray *resultArray=[[_managedObjContext executeFetchRequest:fetch error:&error]mutableCopy];
    if (resultArray==nil||[resultArray count]==0) {
        return nil;
    }
    Images *image=[resultArray objectAtIndex:0];
    return image;
}

-(void)cleanEntityRecords:(NSString *)entityName
{
    NSFetchRequest *fetch=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjContext];
    [fetch setEntity:entity];
    
    NSError *error=nil;
    NSMutableArray *resultArray=[[_managedObjContext executeFetchRequest:fetch error:&error] mutableCopy];
    if (resultArray==nil||[resultArray count]==0) {
        return;
    }
    for (NSManagedObject *obj in resultArray) {
        [_managedObjContext deleteObject:obj];
    }
    if (![_managedObjContext save:&error]) {
        NSLog(@"cleanEntityRecords %@",[error description]);
    }
}

-(NSString*)applicationDocumentsDirectory
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath=([paths count]>0)?[paths objectAtIndex:0]:nil;
    return basePath;
}

-(NSManagedObjectContext*)managedObjContext
{
    if (_managedObjContext) {
        return _managedObjContext;
    }
    NSPersistentStoreCoordinator *coordinator=[self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"%@",[error description]);
        return nil;
    }
    _managedObjContext=[[NSManagedObjectContext alloc]init];
    [_managedObjContext setPersistentStoreCoordinator:coordinator];
    return _managedObjContext;
}

-(NSManagedObjectModel*)managedObjModel
{
    if (_managedObjModel) {
        return _managedObjModel;
    }
    
    _managedObjModel=[NSManagedObjectModel mergedModelFromBundles:nil];
    NSLog(@"%@",[_managedObjModel description]);
    return _managedObjModel;
}

-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom=[self managedObjModel];
    if (!mom) {
        NSLog(@"%@:%@ No Model to generate a store from ",[self class],NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSURL *storeUrl=[NSURL fileURLWithPath:[[self applicationDocumentsDirectory]stringByAppendingPathComponent:@"ImageCacheCoreData.sqlite"]];
    
    NSError *error;
    NSPersistentStoreCoordinator *coordinator=[[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"NSPersistentStoreCoordinator error%@",[error description]);
        return nil;
    }
    _persistentStoreCoordinator=coordinator;
    return _persistentStoreCoordinator;
}

@end
