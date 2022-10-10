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
    [self sample1];
}

- (void)sample1{
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
    ];
    NSDictionary *dict = @{
        @"uid":@(1025),
        @"token":@"A8C864D4C95464E8",
    };
    NSData *data = [OTRuleHelper dataForDictionary:dict withRules:rules];
    NSDictionary *json = [OTRuleHelper dictionaryForData:data withRules:rules];
    NSLog(@"~~>Data:%@",data);
    NSLog(@"~~>Json:%@",json);
}
@end
