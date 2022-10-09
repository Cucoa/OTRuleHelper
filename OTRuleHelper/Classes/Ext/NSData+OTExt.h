//
//  NSData+OTExt.h
//  CardioKit
//
//  Created by Borsam on 2019/2/20.
//  Copyright © 2019 Covin.Li. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (EXT)

///字节翻转
- (NSData *)ot_flipBytes;
///字节组翻转
- (NSData *)ot_flipBytesOfSize:(ushort)size;
///生成一个指定字节填充且固定长度数据
+ (NSData *)ot_dataWithLength:(NSUInteger)length useByte:(Byte)byte;
///在指定位置填充指定字节到指定长度
- (NSData *)ot_fillByte:(Byte)byte toMaxLength:(NSUInteger)length atOffset:(NSUInteger)offset;

///BCC验证
- (BOOL)ot_verifyUseBCC;
///BCC计算
+ (NSData *)ot_dataUseBCCToData:(NSData *)data;

///LRC验证
- (BOOL)ot_verifyUseLRC;
///LRC计算
+ (NSData *)ot_dataUseLRCToData:(NSData *)data;

///取模验证
- (BOOL)ot_verifyUseMod;
///取模计算
+ (NSData *)ot_dataUseModToData:(NSData *)data;

@end




