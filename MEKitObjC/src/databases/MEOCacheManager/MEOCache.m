//
//  MEOCache.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/01/23.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOCache.h"

@interface MEOCache () < NSCoding >
{
    NSData *data_;
    NSString *uuid_;
    NSDate *createdAt_;
    NSDate *updatedAt_;
}
@end

@implementation MEOCache

@synthesize data = data_;
@synthesize uuid = uuid_;
@synthesize createdAt = createdAt_;
@synthesize updatedAt = updatedAt_;

-(id)init
{
    if (self = [super init]) {
        data_ = nil;
        uuid_ = [[NSUUID UUID] UUIDString];
        updatedAt_ = createdAt_ = [NSDate date];
    }
    return self;
}

-(id)initWithData:(NSData*)data
{
    if (self = [self init]) {
        data_ = data;
    }
    return self;
}

-(BOOL)writeToFile:(NSString*)path
{
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

+(MEOCache*)cacheWithFile:(NSString*)path
{
    MEOCache *cache = nil;
    id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (obj && [obj isKindOfClass:[MEOCache class]]) {
        cache = (MEOCache*)obj;
    }
    return cache;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:data_ forKey:@"data"];
    [encoder encodeObject:uuid_ forKey:@"uuid"];
    [encoder encodeObject:updatedAt_ forKey:@"updatedAt"];
    [encoder encodeObject:createdAt_ forKey:@"createdAt"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    data_ = [decoder decodeObjectForKey:@"data"];
    uuid_ = [decoder decodeObjectForKey:@"uuid"];
    updatedAt_ = [decoder decodeObjectForKey:@"updatedAt"];
    createdAt_ = [decoder decodeObjectForKey:@"createdAt"];
    return self;
}

-(UIImage*)image
{
    UIImage *img = nil;
    if (data_) {
        img = [UIImage imageWithData:data_];
    }
    return img;
}

-(void)setImage:(UIImage*)image
{
    data_ = UIImagePNGRepresentation(image);
}

-(NSString*)string
{
    NSString *str = nil;
    if (data_) {
        str = [MEOCache stringFromData:data_];
    }
    return str;
}

-(void)setString:(NSString*)string
{
    data_ = [MEOCache dataFromString:string];
}

+(NSString*)stringFromData:(NSData*)data
{
    return [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
}

+(NSData*)dataFromString:(NSString*)string
{
    return [string dataUsingEncoding:NSUnicodeStringEncoding];
}



-(BOOL)isEqual:(id)object
{
    BOOL equal = false;
    if (object) {
        MEOCache *temp = (MEOCache*)object;
        if (temp) {
            if (self.uuid && temp.uuid) {
                equal = [self.uuid isEqualToString:temp.uuid];
            }else{
                equal = [self.data isEqual:temp.data];
            }
        }
    }
    return equal;
}


@end
