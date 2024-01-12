//
//  OTViewController.m
//  OTRuleHelper
//
//  Created by Any on 10/09/2022.
//  Copyright (c) 2022 Any. All rights reserved.
//

#import "OTViewController.h"
#import <OTRuleHelper/OTRuleHelper.h>

@interface OTViewController ()

@end

@implementation OTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self dictSample1];
    [self dictSample2];
    [self dictSample3];
    
    [self arraySample1];
    [self arraySample2];
}

#pragma mark - 字典<->data互转
///TODO: 字典仅含基础类型（OTRuleValueType < 100）
- (void)dictSample1{
    NSArray *rules = @[
        @{
            OTRuleKeyItemName : @"uid",
            OTRuleKeyItemSize : @(4),
            OTRuleKeyItemType : @(OTRuleValueTypeInt32),
        },
        @{
            OTRuleKeyItemName : @"token",
            OTRuleKeyItemSize : @(16),
            OTRuleKeyItemType : @(OTRuleValueTypeStringUTF8),
        },
        @{
            OTRuleKeyItemName : @"code",
            OTRuleKeyItemSize : @(3),
            OTRuleKeyItemType : @(OTRuleValueTypeStringHex),
        },
    ];
    NSDictionary *dict = @{
        @"uid":@(1025),
        @"token":@"A8C864D4C95464E8",
        @"code":@"AD0612",
    };
    NSData *data = [OTRuleHelper dataForDictionary:dict withRules:rules];
    NSDictionary *result = [OTRuleHelper dictionaryForData:data withRules:rules];
    NSLog(@"~~>Data:%@",data);
    NSLog(@"~~>Dict:%@",result);
}

///TODO: 字典内嵌数组（元素等长）
- (void)dictSample2{
    NSArray *rules = @[
        @{
            OTRuleKeyItemName : @"uid",
            OTRuleKeyItemSize : @(4),
            OTRuleKeyItemType : @(OTRuleValueTypeInt32),
        },
        @{
            OTRuleKeyItemName : @"list",
            OTRuleKeyItemSize : @(3),//数组个数，
            OTRuleKeyItemType : @(OTRuleValueTypeArrayFix),//内部元素体等长，
            OTRuleKeyItemSizeFix : @(10),//元素体长度
            OTRuleKeyItemSubRules : @[
                @{
                    OTRuleKeyItemName : @"name",
                    OTRuleKeyItemSize : @(8),
                    OTRuleKeyItemType : @(OTRuleValueTypeStringUTF8),
                },
                @{
                    OTRuleKeyItemName : @"age",
                    OTRuleKeyItemSize : @(2),
                    OTRuleKeyItemType : @(OTRuleValueTypeInt8),
                },
            ],
        }
    ];
    
    NSDictionary *dict = @{
        @"uid": @(1001),
        @"list":@[
            @{@"name":@"Rore",@"age":@(10)},
            @{@"name":@"Tom",@"age":@(20)},
            @{@"name":@"Cady",@"age":@(30)},
        ],
    };
    
    NSData *data = [OTRuleHelper dataForDictionary:dict withRules:rules];
    NSDictionary *result = [OTRuleHelper dictionaryForData:data withRules:rules];
    NSLog(@"~~>Data:%@",data);
    NSLog(@"~~>Dict:%@",result);
}

///TODO: 字典内嵌数组（元素不等长）
- (void)dictSample3{
    //元素不等长数组
    NSArray *rules = @[
        @{
            OTRuleKeyItemName : @"uid",
            OTRuleKeyItemSize : @(4),
            OTRuleKeyItemType : @(OTRuleValueTypeInt32),
        },
        @{
            OTRuleKeyItemName : @"list_bytes",
            OTRuleKeyItemSize : @(2),
            OTRuleKeyItemType : @(OTRuleValueTypeInt16),
        },
        @{
            OTRuleKeyItemName : @"list",
            OTRuleKeyItemSize : @"list_bytes",
            OTRuleKeyItemType : @(OTRuleValueTypeArray),
            OTRuleKeyItemSubRules : @[
                @{
                    OTRuleKeyItemName : @"name_bytes",
                    OTRuleKeyItemSize : @(2),
                    OTRuleKeyItemType : @(OTRuleValueTypeInt16),
                },
                @{
                    OTRuleKeyItemName : @"name",
                    OTRuleKeyItemSize : @"name_bytes",
                    OTRuleKeyItemType : @(OTRuleValueTypeStringUTF8),
                },
                @{
                    OTRuleKeyItemName : @"age",
                    OTRuleKeyItemSize : @(2),
                    OTRuleKeyItemType : @(OTRuleValueTypeInt8),
                },
            ],
        }
    ];
    
    NSDictionary *dict = @{
        @"uid":@(1002),
        @"list_bytes":@((2+4+2)+(2+3+2)+(2+5+2)),
        @"list":@[
            @{@"name":@"Rore",@"name_bytes":@(4),@"age":@(10)},
            @{@"name":@"Tom",@"name_bytes":@(3),@"age":@(20)},
            @{@"name":@"Candy",@"name_bytes":@(5),@"age":@(30)},
        ],
    };
    
    NSData *data = [OTRuleHelper dataForDictionary:dict withRules:rules];
    NSDictionary *result = [OTRuleHelper dictionaryForData:data withRules:rules];
    NSLog(@"~~>Data:%@",data);
    NSLog(@"~~>Dict:%@",result);
}

#pragma mark - 数组<->data互转
///TODO: 数组（元素为基础类型）
- (void)arraySample1{
    NSArray *rules = @[
        @{
            //若为基础类型，OTRuleKeyItemName可以不设置
            //OTRuleKeyItemName : @"name",
            OTRuleKeyItemSize : @(2),
            OTRuleKeyItemType : @(OTRuleValueTypeInt16),
        },
    ];
    
    NSArray *array = @[@3,@1,@2,@4,@5];
    NSData *data = [OTRuleHelper dataForArray:array withRules:rules];
    NSArray *result = [OTRuleHelper arrayForData:data withRules:rules];
    
    NSLog(@"~~>Data:%@",data);
    NSLog(@"~~>Array:%@",result);
    
}


///TODO: 数组（元素为字典）
- (void)arraySample2{
    NSArray *rules = @[
        @{
            OTRuleKeyItemName : @"name_bytes",
            OTRuleKeyItemSize : @(2),
            OTRuleKeyItemType : @(OTRuleValueTypeInt16),
        },
        @{
            OTRuleKeyItemName : @"name",
            OTRuleKeyItemSize : @"name_bytes",
            OTRuleKeyItemType : @(OTRuleValueTypeStringUTF8),
        },
        @{
            OTRuleKeyItemName : @"age",
            OTRuleKeyItemSize : @(2),
            OTRuleKeyItemType : @(OTRuleValueTypeInt8),
        },
    ];
    
    NSArray *array = @[
        @{@"name":@"Rore",@"name_bytes":@(4),@"age":@(10)},
        @{@"name":@"Tom",@"name_bytes":@(3),@"age":@(20)},
        @{@"name":@"Candy",@"name_bytes":@(5),@"age":@(30)},
    ];
    NSData *data = [OTRuleHelper dataForArray:array withRules:rules];
    NSArray *result = [OTRuleHelper arrayForData:data withRules:rules];
    
    NSLog(@"~~>Data:%@",data);
    NSLog(@"~~>Array:%@",result);
}
@end
