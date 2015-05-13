//
//  CoreDataManager.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 12/06/04.
//  Copyright (c) 2012年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOCoreDataManager.h"

#define COREDATA_SQLITE_FILE @"CoreData.sqlite"

@interface MEOCoreDataManager ()
{
    NSManagedObjectModel *managedObjectModel_;
    NSManagedObjectContext *managedObjectContext_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

-(void)setup;
-(BOOL)makeManagedObjectContext;
-(BOOL)makeManagedObjectModel;
-(BOOL)makePersistentStoreCoordinator;

-(NSString*)applicationDocumentsDirectory;

@end

@implementation MEOCoreDataManager

+(MEOCoreDataManager*)defaultCoreDataManager
{
    static MEOCoreDataManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[MEOCoreDataManager alloc] init];
    });
    return singleton;
}

-(id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

-(void)dealloc
{
    managedObjectContext_ = nil;
    managedObjectModel_  = nil;
    persistentStoreCoordinator_  = nil;
}

-(void)setup
{
    [self makeManagedObjectModel];
    [self makePersistentStoreCoordinator];
    [self makeManagedObjectContext];
}

-(BOOL)makeManagedObjectModel
{
    if (!managedObjectModel_) 
    {
        managedObjectModel_ = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return YES;
}

-(BOOL)makePersistentStoreCoordinator
{
    BOOL result = YES;
    
    if (!persistentStoreCoordinator_) 
    {
        if (!managedObjectModel_) 
        {
            [self makeManagedObjectModel];
        }
        
        persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel_];
        NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:COREDATA_SQLITE_FILE];
        NSError *error = nil;
        [persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:[NSURL fileURLWithPath:path]
                                                        options:nil
                                                          error:&error];
        if (error) {
            NSLog(@"persistentStoreCoordinator: Error %@, %@", error, [error userInfo]);
            result = NO;
        }
    }
    
    return result;
}

-(BOOL)makeManagedObjectContext
{
    BOOL result = YES;
    if ( !managedObjectContext_) 
    {
        if (!persistentStoreCoordinator_) 
        {
            result = [self makePersistentStoreCoordinator];
        }
        if (result) 
        {
            managedObjectContext_ = [[NSManagedObjectContext alloc] init];
            [managedObjectContext_ setPersistentStoreCoordinator:persistentStoreCoordinator_];
        }        
    }
    
    return result;
}

-(BOOL)hasEntity:(NSString*)entityName
{
    BOOL exist = NO;
    NSArray *entities = [managedObjectModel_ entities];
    for (NSEntityDescription *entity in entities) {
        if ([[entity name] isEqualToString:entityName]) {
            exist = true;
            break;
        }
    }
    return exist;
}

- (NSManagedObject*)newManagedObject:(NSString*)name
{
    if ([self hasEntity:name] == NO) {
        NSLog(@"%s, Entity %@ is not found.", __func__, name);
        return nil;
    }
    
    NSManagedObject *newManagedObject = nil;
    @try {
        newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:name
                                                         inManagedObjectContext:managedObjectContext_];
    }
    @catch (NSException *exception) {
        NSLog(@"%s, %@", __func__, exception.description);
    }
    @finally {
    }
    return newManagedObject;
}

- (NSMutableArray*)data:(NSString*)name predicate:(NSPredicate*)predicate
{
    return [self data:name predicate:predicate sortDescriptors:nil];
}

- (NSMutableArray*)data:(NSString*)name
              predicate:(NSPredicate*)predicate
        sortDescriptors:(NSArray*)sortDescriptors

{
    if( !managedObjectContext_ ){
        return nil;
    }
    
    if ([self hasEntity:name] == NO) {
        NSLog(@"%s, Entity %@ is not found.", __func__, name);
        return nil;
    }
    
    //フェッチリクエスト
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:managedObjectContext_];
    [request setEntity:entity];
    [request setFetchBatchSize:20];
    
    //フィルター
    if (predicate) {
        [request setPredicate:predicate];
    }
    
    if (sortDescriptors) {
        [request setSortDescriptors:sortDescriptors];
    }
    
    //取得する
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext_ executeFetchRequest:request error:&error] mutableCopy];
    return mutableFetchResults;
}

-(void)deleteManagedObject:(NSManagedObject*)object
{
    if (object && managedObjectContext_) {
        [managedObjectContext_ deleteObject:object];
    }
}

-(void)deleteEntity:(NSString*)entityName predicate:(NSPredicate*)predicate
{
    if ([self hasEntity:entityName] == NO) {
        NSLog(@"%s, Entity %@ is not found.", __func__, entityName);
        return;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName
                                   inManagedObjectContext:managedObjectContext_]];
    if (predicate) {
        [request setPredicate:predicate];
    }
    NSArray *deletedObjects = [managedObjectContext_ executeFetchRequest:request
                                                                   error:NULL];
    request = nil;
    for (NSManagedObject *object in deletedObjects) {
        [managedObjectContext_ deleteObject:object];
    }
    
    if ([managedObjectContext_ hasChanges]) {
        [managedObjectContext_ save:nil];
    }
}

-(void)deleteAll
{
    NSArray *entities = [managedObjectModel_ entities];
    for (NSEntityDescription *entity in entities) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:[entity name]
                                       inManagedObjectContext:managedObjectContext_]];
        
        NSArray *deletedObjects = [managedObjectContext_ executeFetchRequest:request
                                                                       error:NULL];
        
        request = nil;
        
        for (NSManagedObject *object in deletedObjects) {
            [managedObjectContext_ deleteObject:object];
        }
    }
    
    if ([managedObjectContext_ hasChanges]) {
        [managedObjectContext_ save:nil];
    }
}

-(NSString*)applicationDocumentsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *privateDocs = [libraryDirectory stringByAppendingPathComponent:@"PrivateDocuments"];
    
    BOOL exists = [fileManager fileExistsAtPath:privateDocs];
    if (!exists)
    {
        exists = [fileManager createDirectoryAtPath:privateDocs 
                        withIntermediateDirectories:YES 
                                         attributes:nil 
                                              error:NULL];
    }
    
    return privateDocs;
}

-(BOOL)save
{
    BOOL err = NO;
    if (managedObjectContext_ && [managedObjectContext_ hasChanges])
    {
        err = [managedObjectContext_ save:nil];
    }
    return err;
}

+(BOOL)hasEntity:(NSString*)entityName
{
    MEOCoreDataManager *cdm = [MEOCoreDataManager defaultCoreDataManager];
    return [cdm hasEntity:entityName];
}

+(NSManagedObject*)newManagedObject:(NSString*)name{
    MEOCoreDataManager *cdm = [MEOCoreDataManager defaultCoreDataManager];
    return [cdm newManagedObject:name];
}

+(NSMutableArray*)data:(NSString*)name
             predicate:(NSPredicate*)predicate{
    MEOCoreDataManager *cdm = [MEOCoreDataManager defaultCoreDataManager];
    return [cdm data:name
           predicate:predicate];
}

+(NSMutableArray*)data:(NSString*)name
             predicate:(NSPredicate*)predicate
       sortDescriptors:(NSArray*)sortDescriptors{
    MEOCoreDataManager *cdm = [MEOCoreDataManager defaultCoreDataManager];
    return [cdm data:name
           predicate:predicate
     sortDescriptors:sortDescriptors];
}

+(void)deleteManagedObject:(NSManagedObject*)object{
    MEOCoreDataManager *cdm = [MEOCoreDataManager defaultCoreDataManager];
    [cdm deleteManagedObject:object];
}

+(void)deleteEntity:(NSString*)entityName predicate:(NSPredicate*)predicate{
    MEOCoreDataManager *cdm = [MEOCoreDataManager defaultCoreDataManager];
    [cdm deleteEntity:entityName predicate:predicate];
}

+(void)deleteAll{
    MEOCoreDataManager *cdm = [MEOCoreDataManager defaultCoreDataManager];
    [cdm deleteAll];
}

+(BOOL)save{
    MEOCoreDataManager *cdm = [MEOCoreDataManager defaultCoreDataManager];
    return [cdm save];
}


@end
