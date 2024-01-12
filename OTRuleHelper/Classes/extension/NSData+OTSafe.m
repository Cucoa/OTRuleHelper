//
//  NSData+OTSafe.m
//  CardioWorkstation
//
//  Created by Borsam on 2020/9/28.
//  Copyright © 2020 Borsam. All rights reserved.
//

#import "NSData+OTSafe.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (OTSafe)

- (NSData *)ot_md5{
    //32位小写
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];;
}

- (NSString *)ot_lowercaseHexString{
    NSMutableString *string = [@"" mutableCopy];
    for (NSInteger i = 0; i < self.length; i++) {
        int vlu = 0;
        [self getBytes:&vlu range:(NSRange){i,1}];
        [string appendFormat:@"%02x",vlu];
    }
    return string;
}

- (NSString *)ot_uppercaseHexString{
    NSMutableString *string = [@"" mutableCopy];
    for (NSInteger i = 0; i < self.length; i++) {
        int vlu = 0;
        [self getBytes:&vlu range:(NSRange){i,1}];
        [string appendFormat:@"%02X",vlu];
    }
    return string;
}


#pragma mark -
- (NSData *)ot_aesEncodeForKey:(NSString *)key{
    
    NSData *keyPtr = [[key dataUsingEncoding:NSUTF8StringEncoding] ot_md5];//保证是16字节,
   
    NSUInteger dataLength = [self length];

    size_t bufferSize = dataLength + kCCBlockSizeAES128;

    void *buffer = malloc(bufferSize);

    size_t numBytesEncrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(
                                          kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr.bytes,
                                          kCCKeySizeAES128,//必须是16、24、32
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    NSData *result;
    if(cryptStatus == kCCSuccess)
    {
         return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return result;
}

- (NSData *)ot_aesDecodeForKey:(NSString *)key{
    NSData *keyPtr = [[key dataUsingEncoding:NSUTF8StringEncoding] ot_md5];

    NSUInteger dataLength = [self length];

    size_t bufferSize = dataLength + kCCBlockSizeAES128;

    void *buffer = malloc(bufferSize);

    size_t numBytesDecrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(
                                          kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr.bytes,
                                          kCCKeySizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);

    NSData *result;
    if(cryptStatus == kCCSuccess)
    {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return result;
}


#pragma mark -
+ (NSString *)ot_aesEncrypt:(NSString *)sourceStr useKey:(NSString *)key keySize:(size_t)key_size{
    if (!sourceStr) {
        return nil;
    }
    
    key_size = 8*MAX(2, MIN(4, key_size/8));//只能是16，24，32
    char keyPtr[key_size + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
     
    NSData *source_data = [sourceStr dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger source_size = [source_data length];
    
    size_t buffersize = source_size + kCCBlockSizeAES128;//如果是CBC下默认16个0字节，ECB不偏移
    void *buffer = malloc(buffersize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(
                                          kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          key_size,
                                          NULL,
                                          [source_data bytes],
                                          source_size,
                                          buffer,
                                          buffersize,
                                          &numBytesEncrypted
                                          );
     
    NSString *encodeStr = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
        //对加密后的二进制数据进行base64转码
        encodeStr = [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    free(buffer);
    return encodeStr;
}
 
+ (NSString *)ot_aesDecrypt:(NSString *)secretStr  useKey:(NSString *)key keySize:(size_t)key_size{
    if (!secretStr) {
        return nil;
    }
    
    key_size = 8*MAX(2, MIN(4, key_size/8));//只能是16，24，32
    char keyPtr[key_size + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    //先对加密的字符串进行base64解码
    NSData *secret_data = [[NSData alloc] initWithBase64EncodedString:secretStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger secret_size = [secret_data length];
     
     
    size_t buffer_size = secret_size + kCCBlockSizeAES128;
    void *buffer = malloc(buffer_size);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(
                                          kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          key_size,
                                          NULL,
                                          [secret_data bytes],
                                          secret_size,
                                          buffer,
                                          buffer_size,
                                          &numBytesDecrypted
                                          );
    NSString *decodeStr = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *decryptData = [NSData dataWithBytes:buffer length:numBytesDecrypted];
        decodeStr = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return decodeStr;
}
@end
