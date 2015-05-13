//
//  MEOKeyChain.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/11/07.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOKeyChain.h"

@interface MEOKeyChain ()

+(NSString*)secAttrService;
+(NSMutableDictionary*)queryDictionaryWithKey:(NSString *)key;

@end

@implementation MEOKeyChain

+(BOOL)isFirstBoot
{
    BOOL firstBoot = NO;
    NSString *kBootedAlready = @"kBootedAlready_MEOKeyChain";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:kBootedAlready] == NO) {
        [userDefaults setBool:YES forKey:kBootedAlready];
        firstBoot = YES;
    }else{
        firstBoot = NO;
    }
    return firstBoot;
}


+(NSString*)secAttrService
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+(NSMutableDictionary*)queryDictionaryWithKey:(NSString *)key
{
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            (__bridge id)kSecClassGenericPassword, kSecClass,
//                                            (__bridge id)kSecAttrAccessibleAlways, kSecAttrAccessible,                                            
                                            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, kSecAttrAccessible,
                                            [MEOKeyChain secAttrService], kSecAttrService,
                                            nil];
    if (key && key.length > 0) {
        [queryDictionary setValue:key forKey:(__bridge id)kSecAttrAccount];
    }
    return queryDictionary;
}

+(BOOL)setData:(NSData*)data forKey:(NSString*)key
{
    NSMutableDictionary *queryDictionary = [MEOKeyChain queryDictionaryWithKey:key];
    
    if (!data) {
        return [self deleteForKey:key];
    }
    
    NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
    [updateDictionary setObject:data
                         forKey:(__bridge id)kSecValueData];
    
    OSStatus status;
    BOOL exists = ([self dataForKey:key] != nil);
    
    if (exists) {
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary);
    } else {
        [queryDictionary addEntriesFromDictionary:updateDictionary];
        status = SecItemAdd((__bridge CFDictionaryRef)queryDictionary, NULL);
    }
    
    if (status != errSecSuccess) {
        NSLog(@"Unable to %@ credential with key \"%@\" (Error %li)",
              (exists ? @"update" : @"add"), key, (long int)status);
    }
    
    return (status == errSecSuccess);
}

+(BOOL)setString:(NSString*)string forKey:(NSString*)key
{
    NSData *data = nil;
    if (string) {
        data = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [MEOKeyChain setData:data forKey:key];
}

+(BOOL)deleteForKey:(NSString*)key
{
    NSMutableDictionary *queryDictionary = [MEOKeyChain queryDictionaryWithKey:key];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
    if (status != errSecSuccess) {
       NSLog(@"%s, Unable to delete credential with key \"%@\" (Error %li)",
             __func__, key, (long int)status);
    }
    return (status == errSecSuccess);
}

+(BOOL)clearIfFirstBoot;
{
    BOOL result = false;
    if ([MEOKeyChain isFirstBoot]) {
        result = [MEOKeyChain clear];
    }
    return result;
}

+(BOOL)clear
{
    return [MEOKeyChain deleteForKey:nil];
}

+(NSData*)dataForKey:(NSString*)key
{
    NSMutableDictionary *queryDictionary = [MEOKeyChain queryDictionaryWithKey:key];
    [queryDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [queryDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    CFDataRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&result);
    
    if (status != errSecSuccess) {
        NSLog(@"Unable to fetch credential with key \"%@\" (Error %li)",
              key, (long int)status);
        return nil;
    }
    
    NSData *data = (__bridge_transfer NSData *)result;
    
    return data;
}

+(NSString*)stringForKey:(NSString*)key
{
    NSData *data = [MEOKeyChain dataForKey:key];
    NSString *str = nil;
    if (data) {
        str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return str;
}



@end
