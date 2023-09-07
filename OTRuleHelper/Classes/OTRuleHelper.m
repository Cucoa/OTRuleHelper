//
//  OTRuleHelper.m
//  OTAnySocketor
//
//  Created by Any on 2022/5/20.
//

#import "OTRuleHelper.h"
#import "NSData+OTExt.h"
#import "NSData+OTConvert.h"

NSString const *OTRuleKeyItemName      = @"v_key";//字符串
NSString const *OTRuleKeyItemSize      = @"v_size";//整型/字符串
NSString const *OTRuleKeyItemType      = @"v_type";//整型
NSString const *OTRuleKeyItemSizeFix   = @"v_size_fix";//整型，在OTRuleValueTypeArrayFix类型使用,表示元素长度
NSString const *OTRuleKeyItemEndian    = @"v_endian";//布尔型,NO-大端 YES-小端
NSString const *OTRuleKeyItemSubRules  = @"v_sub_rules";//数组， OTRuleValueTypeArray数据为列表类型
NSString const *OTRuleKeyItemBytesFlip = @"v_flip";//布尔型

static NSDateFormatter *otrule_df;

@implementation OTRuleHelper

#pragma mark -
+ (NSMutableDictionary *)dictionaryForData:(NSData *)data withRules:(NSArray *)rules littleEndian:(BOOL)endian{
    NSMutableDictionary *response = [@{} mutableCopy];
    NSInteger offset = 0;
    for (NSDictionary *element in rules) {
        if (offset >= data.length) break;
        
        id value = nil;
        NSString *key = element[OTRuleKeyItemName];
        OTRuleValueType type = [element[OTRuleKeyItemType] integerValue];
        BOOL isLittle = endian;
        if ([element.allKeys containsObject:OTRuleKeyItemEndian]) {
            isLittle = [element[OTRuleKeyItemEndian] boolValue];;
        }
        NSInteger size = 0;
        id size_obj = element[OTRuleKeyItemSize];
        if ([size_obj isKindOfClass:[NSNumber class]]) {
            size = [size_obj integerValue];
        }else if([size_obj isKindOfClass:[NSString class]]){
            size = [response[size_obj] integerValue];
        }
        if (type == OTRuleValueTypeArrayFix) {
            NSInteger size_fix = [element[OTRuleKeyItemSizeFix] integerValue];
            size = size*size_fix;
        }
        
        if (offset + size > data.length) break;
        
        NSArray *sub_rules = element[OTRuleKeyItemSubRules];
        NSData *content = [data subdataWithRange:(NSRange){offset,size}];
        value = [OTRuleHelper objectConvertFromData:content
                                                key:key
                                               type:type
                                               size:size
                                             endian:isLittle
                                              rules:sub_rules];
        
        [response setObject:value?value:@"" forKey:key];
        offset += size;
    }
    return response;
}

+ (NSMutableDictionary *)dictionaryForData:(NSData *)data withRules:(NSArray *)rules{
    return [OTRuleHelper dictionaryForData:data withRules:rules littleEndian:NO];
}

+ (NSMutableArray *)arrayForData:(NSData *)data withRules:(NSArray *)rules littleEndian:(BOOL)endian{
    if (rules.count < 1) return nil;
    NSMutableArray *list = [@[] mutableCopy];
    NSInteger offset = 0;
    while (offset < data.length) {
        id response = [@{} mutableCopy];
        for (NSDictionary *element in rules) {
            id value = nil;
            NSString *key = element[OTRuleKeyItemName];
            OTRuleValueType type = [element[OTRuleKeyItemType] integerValue];
            BOOL isLittle = endian;
            if ([element.allKeys containsObject:OTRuleKeyItemEndian]) {
                isLittle = [element[OTRuleKeyItemEndian] boolValue];;
            }
            NSInteger size = 0;
            id size_obj = element[OTRuleKeyItemSize];
            if ([size_obj isKindOfClass:[NSNumber class]]) {
                size = [size_obj integerValue];
            }else if([size_obj isKindOfClass:[NSString class]]){
                size = [response[size_obj] integerValue];
            }
            if (type == OTRuleValueTypeArrayFix) {
                NSInteger size_fix = [element[OTRuleKeyItemSizeFix] integerValue];
                size = size*size_fix;
            }
            NSArray *sub_rules = element[OTRuleKeyItemSubRules];
            NSData *content = [data subdataWithRange:(NSRange){offset,size}];
            value = [OTRuleHelper objectConvertFromData:content
                                                        key:key
                                                       type:type
                                                       size:size
                                                     endian:isLittle
                                                      rules:sub_rules];
            
            if (key) {
                [response setObject:value?value:@"" forKey:key];
            }else{
                response = value?value:@"";
            }
            offset += size;
            if (offset>= data.length) break;
        }
        [list addObject:response];
    }
    return list;
}

+ (NSMutableArray *)arrayForData:(NSData *)data withRules:(NSArray *)rules{
    return [OTRuleHelper arrayForData:data withRules:rules littleEndian:NO];
}

+ (id)objectConvertFromData:(NSData *)data key:(NSString *)key type:(OTRuleValueType)type size:(NSInteger)size endian:(BOOL)isLittle rules:(NSArray *)rules
{
    id value = nil;
    switch (type) {
        case OTRuleValueTypeData:
        {
            //NSData
            value = data;
        }
            break;
        case OTRuleValueTypeInt8:
        {
            uint8_t vl = 0;
            [data getBytes:&vl length:1];
            value = @(vl);
        }
            break;
        case OTRuleValueTypeInt16:
        {
            //短整型
            uint16_t vl = 0;
            [data getBytes:&vl length:2];
            vl = isLittle ? CFSwapInt16HostToLittle(vl) : CFSwapInt16HostToBig(vl);
            value = @(vl);
        }
            break;
        case OTRuleValueTypeInt32:
        {
            //整型
            uint32_t vl = 0;
            [data getBytes:&vl length:4];
            vl = isLittle ? CFSwapInt32HostToLittle(vl) : CFSwapInt32HostToBig(vl);
            value = @(vl);
        }
            break;
        case OTRuleValueTypeInt64:
        {
            uint64_t vl = 0;
            [data getBytes:&vl length:8];
            vl = isLittle ? CFSwapInt64HostToLittle(vl) : CFSwapInt64HostToBig(vl);
            value = @(vl);
        }
            break;
        case OTRuleValueTypeStringUTF8:
        {
            //字符串
            value = [NSData ot_stringUTF8CovertFromData:data];
        }
            break;
        case OTRuleValueTypeStringHex:
        {
            value = [NSData ot_stringHexCovertFromData:data];
        }
            break;
        case OTRuleValueTypeStringHexUseEndian:
        {
            value = [NSData ot_stringHexCovertFromData:isLittle?[data ot_flipBytes]:data];
        }
            break;
        case OTRuleValueTypeDateTextHex:
        case OTRuleValueTypeDateTextDecimal:
        {
            NSMutableString *string = [@"" mutableCopy];
            if (data.length == 6) {
                [string appendString:@"20"];
            }
            for (int i = 0; i < data.length; i++) {
                ushort vlu = 0;
                [data getBytes:&vlu range:(NSRange){i,1}];
                if (type == OTRuleValueTypeDateTextHex) {
                    [string appendFormat:@"%02x",vlu];
                }else{
                    [string appendFormat:@"%02d",vlu];
                }
            }
            value = string;
        }
            break;
        case OTRuleValueTypeTimestampHex:
        case OTRuleValueTypeTimestampDecimal:
        {
            NSMutableString *string = [@"" mutableCopy];
            if (data.length == 6) {
                [string appendString:@"20"];
            }
            for (int i = 0; i < data.length; i++) {
                ushort vlu = 0;
                [data getBytes:&vlu range:(NSRange){i,1}];
                if (type == OTRuleValueTypeTimestampHex) {
                    [string appendFormat:@"%02x",vlu];
                }else{
                    [string appendFormat:@"%02d",vlu];
                }
            }
            NSDateFormatter *df = [self dateFormatter];
            [df setDateFormat:@"yyyyMMddHHmmss"];
            NSInteger timestamp = [[df dateFromString:string] timeIntervalSince1970];
            value = @(timestamp);
        }
            break;
        case OTRuleValueTypeArray:
        {
            value = [OTRuleHelper arrayForData:data withRules:rules];
        }
            break;
        case OTRuleValueTypeArrayFix:
        {
            value = [OTRuleHelper arrayForData:data withRules:rules];
        }
            break;
        case OTRuleValueTypeDictionary:
        {
            value = [OTRuleHelper dictionaryForData:data withRules:rules];
        }
            break;
        case OTRuleValueTypeJson:
        {
            value = [NSData ot_jsonConvertFromData:data];
        }
            break;
    }
    return value;
}


#pragma mark -
+ (NSMutableData *)dataForDictionary:(NSDictionary *)dict withRules:(NSArray *)rules littleEndian:(BOOL)endian{
    NSMutableData *data = [NSMutableData data];
    for (NSDictionary *element in rules) {
        NSString *key = element[OTRuleKeyItemName];
        OTRuleValueType type = [element[OTRuleKeyItemType] integerValue];
        BOOL isLittle = endian;
        if ([element.allKeys containsObject:OTRuleKeyItemEndian]) {
            isLittle = [element[OTRuleKeyItemEndian] boolValue];;
        }
        NSInteger size = 0;
        id size_vk = element[OTRuleKeyItemSize];
        if ([size_vk isKindOfClass:[NSNumber class]]) {
            size = [size_vk integerValue];
        }else if([size_vk isKindOfClass:[NSString class]]){
            size = [dict[size_vk] integerValue];
        }
        if (type == OTRuleValueTypeArrayFix) {
            NSInteger size_fix = [element[OTRuleKeyItemSizeFix] integerValue];
            size = size*size_fix;
        }
        id item_obj = dict[key];//
        NSArray *sub_rules = element[OTRuleKeyItemSubRules];
        
        NSMutableData *item_data = [NSMutableData dataWithLength:size];
        NSData *tmp_data = [OTRuleHelper dataConvertFromObject:item_obj
                                                               key:key
                                                              type:type
                                                              size:size
                                                            endian:isLittle
                                                             rules:sub_rules];
        [item_data replaceBytesInRange:(NSRange){0,tmp_data.length} withBytes:tmp_data.bytes length:tmp_data.length];
        [data appendData:item_data];
        
    }
    return data;
}

+ (NSMutableData *)dataForDictionary:(NSDictionary *)dictionary withRules:(NSArray *)rules{
    return [OTRuleHelper dataForDictionary:dictionary withRules:rules littleEndian:NO];
}

+ (NSMutableData *)dataForArray:(NSArray *)array withRules:(NSArray *)rules littleEndian:(BOOL)endian{
    NSMutableData *data = [NSMutableData data];
    for (id item_obj in array) {
        NSMutableData *item_data = [NSMutableData data];
        for (NSDictionary *element in rules) {
            NSString *key = element[OTRuleKeyItemName];
            OTRuleValueType type = [element[OTRuleKeyItemType] integerValue];
            BOOL isLittle = endian;
            if ([element.allKeys containsObject:OTRuleKeyItemEndian]) {
                isLittle = [element[OTRuleKeyItemEndian] boolValue];;
            }
            NSInteger size = 0;
            id size_vk = element[OTRuleKeyItemSize];
            if ([size_vk isKindOfClass:[NSNumber class]]) {
                size = [size_vk integerValue];
            }else if([size_vk isKindOfClass:[NSString class]]){
                size = [item_obj[size_vk] integerValue];
            }
            if (type == OTRuleValueTypeArrayFix) {
                NSInteger size_fix = [element[OTRuleKeyItemSizeFix] integerValue];
                size = size*size_fix;
            }
            id value = nil;
            if ([item_obj isKindOfClass:[NSDictionary class]]) {
                value = item_obj[key];
            }else{
                value = item_obj;
            }
            NSArray *sub_rules = element[OTRuleKeyItemSubRules];
            
            [item_data appendData:[NSMutableData dataWithLength:size]];
            NSData *tmp_data = [OTRuleHelper dataConvertFromObject:value
                                                                   key:key
                                                                  type:type
                                                                  size:size
                                                                endian:isLittle
                                                                 rules:sub_rules];
            [item_data replaceBytesInRange:(NSRange){item_data.length - size,tmp_data.length} withBytes:tmp_data.bytes length:tmp_data.length];
        }
        [data appendData:item_data];
    }
    return data;
}

+ (NSMutableData *)dataForArray:(NSArray *)array withRules:(NSArray *)rules{
    return [OTRuleHelper dataForArray:array withRules:rules littleEndian:NO];
}

+ (NSData *)dataConvertFromObject:(id)object key:key type:(OTRuleValueType)type size:(NSInteger)size endian:(BOOL)isLittle rules:(NSArray *)rules
{
    NSData *data = nil;
    switch (type) {
        case OTRuleValueTypeData:
        {
            data = object;
        }
            break;
        case OTRuleValueTypeInt8:
        {
            uint8_t vl = [object intValue];
            data = [[NSData alloc] initWithBytes:(Byte[]){vl&0xff} length:1];
        }
            break;
        case OTRuleValueTypeInt16:
        {
            //短整型
            uint16_t vl = [object intValue];
            vl = isLittle ? CFSwapInt16LittleToHost(vl) : CFSwapInt16BigToHost(vl);
            data = [[NSData alloc] initWithBytes:&vl length:2];
        }
            break;
        case OTRuleValueTypeInt32:
        {
            //整型
            uint32_t vl = [object intValue];
            vl = isLittle ? CFSwapInt32LittleToHost(vl) : CFSwapInt32BigToHost(vl);
            data = [[NSData alloc] initWithBytes:&vl length:4];
        }
            break;
        case OTRuleValueTypeInt64:
        {
            uint64_t vl = [object longValue];
            vl = isLittle ? CFSwapInt64LittleToHost(vl) : CFSwapInt64BigToHost(vl);
            data = [[NSData alloc] initWithBytes:&vl length:8];
        }
            break;
        case OTRuleValueTypeStringUTF8:
        {
            //字符串
            data = [NSData ot_dataCovertFromStringUTF8:object];
        }
            break;
        case OTRuleValueTypeStringHex:
        {
            data = [NSData ot_dataCovertFromStringHex:object];
        }
            break;
        case OTRuleValueTypeStringHexUseEndian:
        {
            data = [NSData ot_dataCovertFromStringHex:object];
            if (isLittle) {
                data = [data ot_flipBytes];
            }
        }
            break;
        case OTRuleValueTypeDateTextHex:
        case OTRuleValueTypeDateTextDecimal:
        {
            NSMutableString *hex = [@"" mutableCopy];
            NSString *string = object?object:@"";
            for (int i = 0; i < string.length; i+=2) {
                int vlu = [[string substringWithRange:(NSRange){i,2}] intValue];
                if (type == OTRuleValueTypeDateTextHex) {
                    [hex appendFormat:@"%02d",vlu];
                }else{
                    [hex appendFormat:@"%02x",vlu];
                }
            }
            data = [NSData ot_dataCovertFromStringHex:hex length:size];
        }
            break;
        case OTRuleValueTypeTimestampHex:
        case OTRuleValueTypeTimestampDecimal:
        {
            NSDateFormatter *df = [self dateFormatter];
            [df setDateFormat:@"yyyyMMddHHmmss"];
            NSString *string = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:[object integerValue]]];
            if (size == 6) {
                string = [string substringFromIndex:2];
            }
            NSMutableString *hex = [@"" mutableCopy];
            for (int i = 0; i < string.length; i+=2) {
                int vlu = [[string substringWithRange:(NSRange){i,2}] intValue];
                if (type == OTRuleValueTypeTimestampHex) {
                    [hex appendFormat:@"%02d",vlu];
                }else{
                    [hex appendFormat:@"%02x",vlu];
                }
            }
            data = [NSData ot_dataCovertFromStringHex:hex length:size];
        }
            break;
        case OTRuleValueTypeArray:
        case OTRuleValueTypeArrayFix:
        {
            data = [OTRuleHelper dataForArray:object withRules:rules];
        }
            break;
        case OTRuleValueTypeDictionary:
        {
            data = [OTRuleHelper dataForDictionary:object withRules:rules];
        }
            break;
        case OTRuleValueTypeJson:
        {
            data = [NSData ot_dataConvertFromJson:object];
        }
            break;
    }
    if (data.length > size) {
        data = [data subdataWithRange:(NSRange){0,size}];
    }
    return data;
}

#pragma mark -
+ (NSString *)totalBytesForRules:(NSArray *)rules{
    NSInteger let = 0;
    NSMutableString *var = [@"" mutableCopy];
    int cont = 0;
    for (NSDictionary *obj in rules) {
        id size = obj[OTRuleKeyItemSize];
        if ([size intValue] > 0) {
            let += [size intValue];
        }else{
            [var appendFormat:@"+N%@",@(cont)];
            cont+=1;
        }
    }
    if (var.length < 1) {
        return [NSString stringWithFormat:@"%@",@(let)];
    }
    return [NSString stringWithFormat:@"%@+%@",@(let),var];
}

#pragma mark -
+ (NSDateFormatter *)dateFormatter{
    if (!otrule_df) {
        otrule_df = [[NSDateFormatter alloc] init];
    }
    return otrule_df;
}
@end
