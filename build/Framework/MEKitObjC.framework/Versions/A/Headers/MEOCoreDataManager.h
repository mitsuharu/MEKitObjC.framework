//
//  CoreDataManager.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 12/06/04.
//  Copyright (c) 2012年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MEOCoreDataManager : NSObject


+(BOOL)hasEntity:(NSString*)entityName;

+(NSManagedObject*)newManagedObject:(NSString*)name;

+(NSMutableArray*)data:(NSString*)name
             predicate:(NSPredicate*)predicate;
+(NSMutableArray*)data:(NSString*)name
             predicate:(NSPredicate*)predicate
       sortDescriptors:(NSArray*)sortDescriptors;

+(void)deleteManagedObject:(NSManagedObject*)object;
+(void)deleteEntity:(NSString*)entityName predicate:(NSPredicate*)predicate;
+(void)deleteAll;

+(BOOL)save;

// 以下は削除予定

+(MEOCoreDataManager*)defaultCoreDataManager;

-(BOOL)hasEntity:(NSString*)entityName;

-(NSManagedObject*)newManagedObject:(NSString*)name;

-(NSMutableArray*)data:(NSString*)name
             predicate:(NSPredicate*)predicate;
-(NSMutableArray*)data:(NSString*)name
             predicate:(NSPredicate*)predicate
       sortDescriptors:(NSArray*)sortDescriptors;

-(void)deleteManagedObject:(NSManagedObject*)object;
-(void)deleteEntity:(NSString*)entityName predicate:(NSPredicate*)predicate;
-(void)deleteAll;

-(BOOL)save;



@end
