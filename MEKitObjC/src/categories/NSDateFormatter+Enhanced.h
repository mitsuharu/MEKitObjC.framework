//
//  NSDateFormatter+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2017/04/14.
//  Copyright © 2017年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Enhanced)

/**
 カレンダー，ロケーションとタイムゾーンを事前に設定したNSDateFormatterを返す
 */
+ (NSDateFormatter*)meo_dateFormatter;

@end
