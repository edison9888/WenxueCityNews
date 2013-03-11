//
//  KRNewsService.m
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-10.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import "KRNewsService.h"
#import "AFJSONRequestOperation.h"

@implementation KRNewsService
- (void)loadNews
{
    NSURL *url = [NSURL URLWithString:@"http://wenxuecity.cloudfoundry.com/news/mobilelist"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"IP Address: %@", JSON);
    } failure:nil];
    
    [operation start];
}
@end
