//
//  NSData+OTConvert.m
//  OTAnySocketor
//
//  Created by Any on 2022/5/25.
//

#import "NSData+OTConvert.h"

@implementation NSData (OT_Ecg)

- (NSArray *)ot_convertToEcgSamplesUseBigEndian:(BOOL)bigEndian bytePerDot:(UInt16)bytePerDot ad:(int)ad{
    NSMutableArray *samples = [@[] mutableCopy];
    for (int i = 0; i < self.length; i+=bytePerDot) {
        uint64_t vlu = 0;
        for (int n = 1; n <= bytePerDot; n++) {
            Byte byte = 0;
            [self getBytes:&byte range:(NSRange){i+n-1,1}];
            vlu += bigEndian ? (byte << (bytePerDot - n)*8) : (byte << ((n-1)*8));
        }
        [samples addObject:@(floor(100.0*vlu/ad)/100)];
    }
    return samples;
}

- (NSArray *)ot_convertToEcgGroupsUseBigEndian:(BOOL)bigEndian
                                 bytePerDot:(UInt16)bytePerDot
                                      leads:(int)leads
                                         ad:(int)ad{
    NSMutableArray<NSMutableArray *> *groups = [@[] mutableCopy];
    
    for (int i = 0; i < leads; i++) {
        [groups addObject:[@[] mutableCopy]];
    }
    
    for (int i = 0; i < self.length; i+=bytePerDot) {
        uint64_t vlu = 0;
        for (int n = 1; n <= bytePerDot; n++) {
            Byte byte = 0;
            [self getBytes:&byte range:(NSRange){i+n-1,1}];
            vlu += bigEndian ? (byte << (bytePerDot - n)*8) : (byte << ((n-1)*8));
        }
        [groups[(i/bytePerDot)%leads] addObject:@(floor(100.0*vlu/ad)/100)];
    }
    return groups;
}

- (NSArray *)ot_convertToEcgPointsUseBigEndian:(BOOL)bigEndian bytePerDot:(UInt16)bytePerDot leads:(int)leads ad:(int)ad hz:(int)hz offset:(uint32_t)offset{
    NSArray *samples = [self ot_convertToEcgSamplesUseBigEndian:bigEndian bytePerDot:bytePerDot ad:ad];
    NSMutableArray *points = [@[] mutableCopy];
    for (int i = 0; i < samples.count; i++) {
        int value = [samples[i] intValue];
        double s = 1.0*(i/leads+offset)/hz;
        double mv = 1.0*value/ad;
        [points addObject:[NSString stringWithFormat:@"{%.2f,%.2f}",s,mv]];
    }
    return points;
}


@end



@implementation NSData (OT_String)

+ (NSData *)ot_dataCovertFromStringUTF8:(NSString *)string{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)ot_dataCovertFromStringUTF8:(NSString *)string length:(NSUInteger)length{
    NSMutableData *data =  nil;
    
    NSInteger max = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    if (max > length) {
        //1???????????????????????????????????????(?????????????????????????????? max???????????????????????????????????????2????????????????????????)
        data = [NSMutableData dataWithLength:length];
        NSInteger offset = 0;
        NSRange range;
        for (int i = 0; i < string.length; i+=range.length) {
            range = [string rangeOfComposedCharacterSequenceAtIndex:i];
            NSString *c = [string substringWithRange:range];
            NSData *cd = [c dataUsingEncoding:NSUTF8StringEncoding];
            NSInteger len = cd.length;
            if (offset+len > length) {
                break;
            }
            [data replaceBytesInRange:(NSRange){offset,len} withBytes:cd.bytes];
            offset += cd.length;
            c  = nil;
            cd = nil;
        }
        
        //2?????????????????????????????????????????? ????????????????????????null
        //NSData *tmp = [string dataUsingEncoding:NSUTF8StringEncoding];
        //data = [[tmp subdataWithRange:(NSRange){0,ml}] mutableCopy];
    }else if(max < length){
        data = [NSMutableData dataWithLength:length];
        [data replaceBytesInRange:(NSRange){0,max} withBytes:[string dataUsingEncoding:NSUTF8StringEncoding].bytes];
    }else{
        data = [[string dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    return data;
}

+ (NSString *)ot_stringUTF8CovertFromData:(NSData *)data{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (!str) {
        str = [[NSString alloc]initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    }
    return str;
}

#pragma mark -
+ (NSData *)ot_dataCovertFromStringHex:(NSString *)hexString{
    return [NSData ot_dataCovertFromStringHex:hexString length:0];
}

+ (NSData *)ot_dataCovertFromStringHex:(NSString *)hexString length:(NSUInteger)length{
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (hexString.length%2 != 0) {
        NSLog(@"?????????????????????????????????");
        return nil;
    }
    
    {
        BOOL exist;
        NSString *str;
        //???????????????
        /*
        str = @"^[A-Fa-f0-9]+$";
        NSPredicate* prediicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
        exist = ![prediicate evaluateWithObject:hexString];
        */
        //???????????????
        str = @"0123456789ABCDEFabcdef";
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:str];
        exist = [hexString stringByTrimmingCharactersInSet:set].length > 0 ? YES : NO;
        
        if (exist) {
            NSLog(@"?????????????????????????????????");
            return nil;
        }
    }
    
    NSMutableData *data = [NSMutableData dataWithLength:length];
    for (NSInteger i = 0; i < hexString.length; i+=2) {
        NSString *cs = [hexString substringWithRange:(NSRange){i,2}];
        Byte byte = strtoul(cs.UTF8String, 0, 16);
        [data replaceBytesInRange:(NSRange){i/2,1} withBytes:&byte];
    }
    
    return data;
}

+ (NSString *)ot_stringHexCovertFromData:(NSData *)data{
    if (!data) {
        return nil;
    }
    NSMutableString *str = [@"" mutableCopy];
    for (int i = 0; i < data.length; i++) {
        ushort value = 0;
        [data getBytes:&value range:(NSRange){i,1}];
        [str appendFormat:@"%02x",value];
    }
    return str;
}

#pragma mark -

@end

@implementation NSData (OT_Int)

+ (NSData *)ot_dataCovertFromUInt:(UInt64)a{
    NSString *hexStr = [NSString stringWithFormat:@"%llx",a];
    return [NSData ot_dataCovertFromStringHex:hexStr];
}

+ (NSData *)ot_dataCovertFromUInt:(UInt64)a length:(NSUInteger)length{
    Byte byte[length];
    for (NSInteger i = 0;i < MIN(4, length); i++) {
        byte[length-i-1] = (a >> (i*8)) & 0xff;
    }
    return [NSData dataWithBytes:byte length:length];
}

+ (UInt64)ot_uint64CovertFromData:(NSData *)data{
    if (data.length > 8) {
        NSLog(@"NSData????????????,?????????????????????????????????");
        return 0;
    }
    
    UInt64 a = 0;
    for (NSInteger i = 0; i < data.length; i++) {
        Byte byte = 0;
        [data getBytes:&byte range:(NSRange){i,1}];
        a += (byte << (data.length - i - 1)*8);
    }
    return a;
}

@end

@implementation NSData (OT_Date)

+ (NSDateFormatter *)ot_dateFormatter{
    static NSDateFormatter *_cvtDF;
    if (!_cvtDF) {
        _cvtDF = [[NSDateFormatter alloc] init];
    }
    return _cvtDF;
}

+ (NSData *)ot_dataCovertAs7BytesFromTimeStamp:(NSInteger)timeStamp{
    NSDateFormatter *df = [self ot_dateFormatter];
    [df setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp]];
    NSMutableData *data = [NSMutableData dataWithLength:7];
    
    for (int i = 0; i < dateString.length; i+= 2) {
        int byte = [[dateString substringWithRange:(NSRange){i,2}] intValue];
        [data replaceBytesInRange:(NSRange){i/2,1} withBytes:&byte length:1];
    }
    return data;
}

+ (NSInteger)ot_timestampFrom7BytesData:(NSData *)data{
    NSMutableString *dateString = [@"00000000000000" mutableCopy];
    
    for (int i = 0; i < data.length; i++) {
        int byte = 0;
        [data getBytes:&byte range:(NSRange){i,1}];
        if (byte < 100) {
            [dateString replaceCharactersInRange:(NSRange){i*2,2} withString:[NSString stringWithFormat:@"%02d",byte]];
        }
    }
    
    NSDateFormatter *df = [self ot_dateFormatter];
    [df setDateFormat:@"yyyyMMddHHmmss"];
    return [[df dateFromString:dateString] timeIntervalSince1970];
}

+ (NSData *)ot_dataCovertAs6BytesFromTimeStamp:(NSInteger)timeStamp{
    NSDateFormatter *df = [self ot_dateFormatter];
    [df setDateFormat:@"yyMMddHHmmss"];
    NSString *dateString = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp]];
    NSMutableData *data = [NSMutableData dataWithLength:6];
    
    for (int i = 0; i < dateString.length; i+= 2) {
        int byte = [[dateString substringWithRange:(NSRange){i,2}] intValue];
        [data replaceBytesInRange:(NSRange){i/2,1} withBytes:&byte length:1];
    }
    return data;
}

+ (NSInteger)ot_timestampFrom6BytesData:(NSData *)data{
    NSMutableString *dateString = [@"000000000000" mutableCopy];
    for (int i = 0; i < data.length; i++) {
        int byte = 0;
        [data getBytes:&byte range:(NSRange){i,1}];
        if (byte < 100) {
            [dateString replaceCharactersInRange:(NSRange){i*2,2} withString:[NSString stringWithFormat:@"%02d",byte]];
        }
    }
    
    NSDateFormatter *df = [self ot_dateFormatter];
    [df setDateFormat:@"yyMMddHHmmss"];
    return [[df dateFromString:dateString] timeIntervalSince1970];
}

@end
