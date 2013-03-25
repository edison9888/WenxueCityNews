//
//  KRConfigStore.m
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-20.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import "KRConfigStore.h"

@implementation KRConfigStore
@synthesize pageSize, fontSize;

+ (KRConfigStore *)sharedStore
{
    static KRConfigStore *sharedStore = nil;
    if(!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}


- (id)init
{
    self = [super init];
    if(self) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        pageSize = [ud objectForKey:@"pageSize"];
        if(!pageSize) {
            pageSize = [NSNumber numberWithInt: KR_PAGE_SIZE];
        } else {
            int p = [pageSize intValue];
            if(p < KR_PAGE_SIZE || p > KR_PAGE_SIZE * KR_OPTION_COUNT) {
                pageSize = [NSNumber numberWithInt: KR_PAGE_SIZE];
            }
        }
        fontSize = [ud objectForKey:@"fontSize"];
        if(!fontSize) {
            fontSize = [NSNumber numberWithInt: 1];
        } else {
            int p = [fontSize intValue];
            if(p < 0 || p > 3) {
                fontSize = [NSNumber numberWithInt: 1];
            }
        }
        nameArray = [NSArray arrayWithObjects:@"小",@"中",@"大", @"超大", nil];
    }
    return self;
}

- (void)save
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:pageSize forKey:@"pageSize"];
    [ud setObject:fontSize forKey:@"fontSize"];
}
-(NSString*)sizeName:(int)size
{
    return [nameArray objectAtIndex:size];
}

-(int)textSize
{
    int textSize = [fontSize intValue];
    switch(textSize)
    {
        case 0: textSize = 75; break;
        case 1: textSize = 100; break;
        case 2: textSize = 125; break;
        default: textSize = 155; break;
    }
    return textSize;
}

@end
