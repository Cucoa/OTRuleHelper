//
//  NSData+OTSafe.h
//  CardioWorkstation
//
//  Created by Borsam on 2020/9/28.
//  Copyright © 2020 Borsam. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (OTSafe)

- (NSData *)ot_md5;
- (NSString *)ot_lowercaseHexString;
- (NSString *)ot_uppercaseHexString;

#pragma mark - 128位 key以md5加密，data1<->AES<->data2

- (NSData *)ot_aesEncodeForKey:(NSString *)key;
- (NSData *)ot_aesDecodeForKey:(NSString *)key;

#pragma mark - key以0填充，Str1<->data1<->AES<->data2<->Base64<->Str2

/// aes加密（ECB模式，PKCS7Padding）
/// @param sourceStr 目标字符串
/// @param key 密钥
/// @param key_size 密钥字节长度16，24，32）
+ (NSString *)ot_aesEncrypt:(NSString *)sourceStr useKey:(NSString *)key keySize:(size_t)key_size;

/// aes解密（ECB模式，PKCS7Padding）
/// @param secretStr 目标字符串
/// @param key 密钥
/// @param key_size 密钥字节长度（16，24，32）
+ (NSString *)ot_aesDecrypt:(NSString *)secretStr useKey:(NSString *)key keySize:(size_t)key_size;

@end
