//
//  NSData+OTExt.m
//  CardioKit
//
//  Created by Borsam on 2019/2/20.
//  Copyright © 2019 Covin.Li. All rights reserved.
//

#import "NSData+OTExt.h"

@implementation NSData (EXT)

- (NSData *)ot_flipBytes{
    NSMutableData *data = [NSMutableData dataWithData:self];
    NSInteger size = self.length;
    NSInteger mid = size/2;
    for (NSInteger i = 0; i < mid ; i++) {
        unichar from_vlu=0, to_vlu=0;
        NSRange from_range = (NSRange){i,1};
        NSRange to_range = (NSRange){size - i - 1,1};
        [self getBytes:&from_vlu range:from_range];
        [self getBytes:&to_vlu range:to_range];
        [data replaceBytesInRange:from_range withBytes:&to_vlu length:1];
        [data replaceBytesInRange:to_range withBytes:&from_vlu length:1];
    }
    return data;
}
- (NSData *)ot_flipBytesOfSize:(ushort)size{
    if (size <= 1) {
        return self.ot_flipBytes;
    }
    
    NSInteger max = self.length - self.length%size;
    NSMutableData *data = [NSMutableData data];
    for (NSUInteger i = 0; i < max; i+= max) {
        NSData *tmp = [self subdataWithRange:(NSRange){i,size}];
        [data appendData:[tmp ot_flipBytes]];
    }
    return data;
}


+ (NSData *)ot_fillByte:(Byte)byte toMaxLength:(NSUInteger)length{
    NSMutableData *data = [NSMutableData dataWithLength:length];
    if (byte != 0x00) {
        for (int i = 0; i < data.length; i++) {
            [data replaceBytesInRange:(NSRange){i,1} withBytes:&byte];
        }
    }
    return data;
}

- (NSData *)ot_fillByte:(Byte)byte toMaxLength:(NSUInteger)length atOffset:(NSUInteger)offset{
    if (length < self.length) {
        return [self subdataWithRange:(NSRange){0,length}];
    }
    NSMutableData *data = [NSMutableData dataWithData:self];
    NSData *fillData = [NSData ot_dataWithLength:(length - self.length) useByte:byte];
    [data replaceBytesInRange:(NSRange){offset,0} withBytes:fillData.bytes length:fillData.length];
    return data;
}


#pragma mark - 校验
- (BOOL)ot_verifyUseBCC{
    ushort code = 0;
    for (int i = 0; i < self.length - 1; i++) {
        short vlu = 0;
        [self getBytes:&vlu range:(NSRange){i,1}];
        code = code^vlu;
    }
    ushort bcc = 0;
    [self getBytes:&bcc range:(NSRange){self.length - 1,1}];
    return bcc == code;
}

+ (NSData *)ot_dataUseBCCToData:(NSData *)data{
    UInt8 code = 0;
    for (int i = 0; i < data.length; i++) {
        int vlu = 0;
        [data getBytes:&vlu range:(NSRange){i,1}];
        code = code^vlu;
    }
    return [NSData dataWithBytes:(Byte[]){code&0xff} length:1];
}


- (BOOL)ot_verifyUseLRC{
    NSUInteger length = self.length;
    
    NSData *data = [NSData ot_dataUseLRCToData:[self subdataWithRange:(NSRange){0,length - 1}]];
    UInt8 code = 0;
    [data getBytes:&code length:1];
    UInt8 lrc = 0;
    [self getBytes:&lrc range:(NSRange){length - 1,1}];
    
    return lrc == code;
}

+ (NSData *)ot_dataUseLRCToData:(NSData *)data{
    UInt8 code = 0;
    for (int i = 0; i < data.length; i++) {
        UInt8 vlu = 0;
        [data getBytes:&vlu range:(NSRange){i,1}];
        code = (code+vlu)%256;
    }
    return [NSData dataWithBytes:(Byte[]){(256 - code)&0xff} length:1];
}

///取模验证
- (BOOL)ot_verifyUseMod{
    NSUInteger length = self.length;
    
    NSData *data = [NSData ot_dataUseModToData:[self subdataWithRange:(NSRange){0,length - 1}]];
    UInt8 code = 0;
    [data getBytes:&code length:1];
    UInt8 lrc = 0;
    [self getBytes:&lrc range:(NSRange){length - 1,1}];
    
    return lrc == code;
}

+ (NSData *)ot_dataUseModToData:(NSData *)data{
    UInt8 code = 0;
    for (int i = 0; i < data.length; i++) {
        UInt8 vlu = 0;
        [data getBytes:&vlu range:(NSRange){i,1}];
        code = (code+vlu)%256;
    }
    return [NSData dataWithBytes:(Byte[]){code&0xff} length:1];
}

///取模取反验证
- (BOOL)ot_verifyUseModIV{
    NSUInteger length = self.length;
    
    NSData *data = [NSData ot_dataUseModIVToData:[self subdataWithRange:(NSRange){0,length - 1}]];
    UInt8 code = 0;
    [data getBytes:&code length:1];
    UInt8 lrc = 0;
    [self getBytes:&lrc range:(NSRange){length - 1,1}];
    
    return lrc == code;
}
///取模取反计算
+ (NSData *)ot_dataUseModIVToData:(NSData *)data{
    UInt8 code = 0;
    for (int i = 0; i < data.length; i++) {
        UInt8 vlu = 0;
        [data getBytes:&vlu range:(NSRange){i,1}];
        code = (code+vlu)%256;
    }
    code = 256 - code;
    return [NSData dataWithBytes:(Byte[]){code&0xff} length:1];
}
@end

