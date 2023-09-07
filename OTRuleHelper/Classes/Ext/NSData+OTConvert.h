//
//  NSData+OTConvert.h
//  OTAnySocketor
//
//  Created by Any on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (OT_Ecg)

/**
 将二进制数据转换为采样数组（未分组）
 */
- (NSArray *)ot_convertToEcgSamplesUseBigEndian:(BOOL)bigEndian
                                     bytePerDot:(UInt16)bytePerDot
                                             ad:(int)ad;

+ (NSData *)ot_convertFromEcgSamples:(NSArray *)samples
                            bigEdian:(BOOL)bigEndian
                          bytePerDot:(UInt16)bytePerDot
                                  ad:(int)ad;

/**
 将二进制数据转换为采样数组（按通道分组）
 */
- (NSArray *)ot_convertToEcgGroupsUseBigEndian:(BOOL)bigEndian
                                 bytePerDot:(UInt16)bytePerDot
                                         leads:(int)leads
                                            ad:(int)ad;

+ (NSData *)ot_convertFromEcgGroups:(NSArray *)groups
                           bigEdian:(BOOL)bigEndian
                         bytePerDot:(UInt16)bytePerDot
                              leads:(int)leads
                                 ad:(int)ad;

/**
 将二进制数据转换为心电坐标（s,mv）
 */
- (NSArray *)ot_convertToEcgPointsUseBigEndian:(BOOL)bigEndian
                                    bytePerDot:(UInt16)bytePerDot
                                         leads:(int)leads
                                            ad:(int)ad
                                            hz:(int)hz
                                        offset:(uint32_t)offset;



@end


@interface NSData (OT_String)

/**
 UTF8字符串转换成NSData

 @param string 目标字符串
 @return data
 */
+ (NSData *)ot_dataCovertFromStringUTF8:(NSString *)string;

/**
 UTF8字符串转换成指定长度的NSData（不足补0）

 @param string 目标字符串
 @param length 限定字节数
 @return data
 */
+ (NSData *)ot_dataCovertFromStringUTF8:(NSString *)string length:(NSUInteger)length;
/**
 将NSData转换成UTF8字符串

 @param data 目标字符串
 @return string
 */
+ (NSString *)ot_stringUTF8CovertFromData:(NSData *)data;

/**
 将16进制字符串转换成NSData

 @param hexString 目标字符串
 @return data
 */
+ (NSData *)ot_dataCovertFromStringHex:(NSString *)hexString;

/**
 将16进制字符串转换成指定长度的NSData（不足补0）

 @param hexString 目标字符串
 @param length 限定字节数
 @return data
 */
+ (NSData *)ot_dataCovertFromStringHex:(NSString *)hexString length:(NSUInteger)length;
/**
 16进制字符串转换成NSData

 @param data 二进制数据
 @return string
 */
+ (NSString *)ot_stringHexCovertFromData:(NSData *)data;

+ (NSData *)ot_dataConvertFromJson:(id)object;
+ (id)ot_jsonConvertFromData:(NSData *)data;

@end

@interface NSData (OT_Int)
/*
 整数数的长度 最大为4字节
 */

/**
 长整型转换NSData

 @param a 有符号短整型
 @return 数据对象
 */
+ (NSData *)ot_dataCovertFromUInt:(UInt64)a;

/**
 长整型转换限定长度的NSData

 @param a 有符号短整型
 @param length 限定字节数
 @return 数据对象
 */
+ (NSData *)ot_dataCovertFromUInt:(UInt64)a length:(NSUInteger)length;

/**
 NSData转换为有符号短整型
 注意NSData的字节数不超过8个
 @param data 数据对象
 @return 有符号整型
 */
+ (UInt64)ot_uint64CovertFromData:(NSData *)data;

@end

@interface NSData (OT_Date)

/**
 将时间戳转换成7bytes二进制数据

 @param timeStamp 时间戳
 @return data
 */
+(NSData *)ot_dataCovertAs7BytesFromTimeStamp:(NSInteger)timeStamp;

/**
 将7bytes二进制数据转换成时间戳

 @param data 二进制数据
 @return 时间戳
 */
+(NSInteger)ot_timestampFrom7BytesData:(NSData *)data;

/**
 将时间戳转换成6bytes二进制数据

 @param timeStamp 时间戳
 @return data
 */
+(NSData *)ot_dataCovertAs6BytesFromTimeStamp:(NSInteger)timeStamp;

/**
 将6bytes二进制数据转换成时间戳

 @param data 二进制数据
 @return 时间戳
 */
+(NSInteger)ot_timestampFrom6BytesData:(NSData *)data;

@end


NS_ASSUME_NONNULL_END
