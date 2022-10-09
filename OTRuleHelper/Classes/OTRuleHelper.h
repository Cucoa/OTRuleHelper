//
//  OTRuleHelper.h
//  OTAnySocketor
//
//  Created by Any on 2022/5/20.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,OTRuleValueType){
    OTRuleValueTypeData  = 0,// 二进制
    
    OTRuleValueTypeInt8  = 1,
    OTRuleValueTypeInt16 = 2,
    OTRuleValueTypeInt32 = 3,
    OTRuleValueTypeInt64 = 4,
    
    OTRuleValueTypeStringUTF8 = 10,
    OTRuleValueTypeStringHex  = 11,
    OTRuleValueTypeStringHexUseEndian = 12,
    
    OTRuleValueTypeDateTextHex = 20,//将日期字符串以十六进制存储，例：日期字符串20220101080000 转化成 data<20220101080000>
    OTRuleValueTypeDateTextDecimal = 21,//将日期字符串以十进制存储，例：日期字符串20221030183032 转化成 data<14160A1D120A20>
    OTRuleValueTypeTimestampHex = 22,//将时间戳以十六进制存储，时间戳先转成日期字符串20220101080000，再转化成 data<20220101080000>
    OTRuleValueTypeTimestampDecimal = 23,//将时间戳以十进制存储，时间戳先转成日期字符串20221030183032，再转化成 data<20220101080000>
    
    OTRuleValueTypeArray = 100,//所有元素长度不等
    OTRuleValueTypeArrayFix = 101,//所有元素长度相等
    OTRuleValueTypeDictionary = 200,//
};

extern NSString const *OTRuleKeyItemName;//元素名称
extern NSString const *OTRuleKeyItemSize;//元素内容大小
extern NSString const *OTRuleKeyItemType;//元素内容类型
extern NSString const *OTRuleKeyItemSizeFix;//在OTRuleValueTypeArrayFix类型使用,表示元素长度
extern NSString const *OTRuleKeyItemEndian; //字节序,默认不填是大端处理
extern NSString const *OTRuleKeyItemSubItems;//OTRuleValueTypeArray、OTRuleValueTypeDictionary数据为列表类型
//extern NSString const *OTRuleKeyItemBytesFlip;//字节翻转(暂时弃用)

///透传协议规则转换器
@interface OTRuleHelper : NSObject

#pragma mark -
///将data通过制定规则解析成字典(默认大端)
+ (NSMutableDictionary *)dictionaryForData:(NSData *)data withRules:(NSArray *)rules;
///将data通过制定规则解析成字典
+ (NSMutableDictionary *)dictionaryForData:(NSData *)data withRules:(NSArray *)rules littleEndian:(BOOL)endian;
///将data通过制定规则解析成数组（默认大端）
+ (NSMutableArray *)arrayForData:(NSData *)data withRules:(NSArray *)rules;
///将data通过制定规则解析成数组
+ (NSMutableArray *)arrayForData:(NSData *)data withRules:(NSArray *)rules littleEndian:(BOOL)endian;

#pragma mark -
///将字典通过制定规则打包成data（默认大端）
+ (NSMutableData *)dataForDictionary:(NSDictionary *)dictionary withRules:(NSArray *)rules;
///将字典通过制定规则打包成data
+ (NSMutableData *)dataForDictionary:(NSDictionary *)dictionary withRules:(NSArray *)rules littleEndian:(BOOL)endian;
///将数组通过制定规则打包成data（默认大端）
+ (NSMutableData *)dataForArray:(NSArray *)array withRules:(NSArray *)rules;
///将数组通过制定规则打包成data
+ (NSMutableData *)dataForArray:(NSArray *)array withRules:(NSArray *)rules littleEndian:(BOOL)endian;

#pragma mark -
///统计规则外层字节数（内部不确定用变量N代替）
+ (NSString *)totalBytesForRules:(NSArray *)rules;
@end

NS_ASSUME_NONNULL_END
