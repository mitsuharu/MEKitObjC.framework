//
//  MyMemory.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 12/09/06.
//
//

#import <Foundation/Foundation.h>

@interface MEOMemory : NSObject

// free     空きメモリ
// active   使用中メモリ
// inactive 非使用中メモリ
// wire     固定中メモリ
// sesure   確保中メモリ（ = 使用中 + 非使用中 + 固定中 ）
// other    その他メモリ（ = 全 - 空き - 確保中 ）
// total    全メモリ

-(NSString*)description;

-(double)free;
-(double)active;
-(double)inactive;
-(double)wire;
-(double)sesure;
-(double)other;
-(double)total;

@property (readonly) NSString *description;
@property (readonly, getter = free) double free;
@property (readonly, getter = active) double active;
@property (readonly, getter = inactive) double inactive;
@property (readonly, getter = wire) double wire;
@property (readonly, getter = sesure) double sesure;
@property (readonly, getter = other) double other;
@property (readonly, getter = total) double total;

@end
