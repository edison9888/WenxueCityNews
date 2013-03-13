//
//  KRNewsService.m
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-10.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import "KRNews.h"
#import "Base64.h"
#import "KRNewsService.h"
#import "AFJSONRequestOperation.h"

@implementation KRNewsService
- (void) loadNews: (int)from to:(int)to max:(int)max withHandler:(void (^)(NSArray *retrievedData, NSError *error))handler
{
    NSString * url = [[NSString alloc] initWithFormat:@"http://wenxuecity.cloudfoundry.com/news/mobilelist?from=%d&to=%d&max=%d", from, to, max];
    NSURL* targetUrl = [[NSURL alloc] initWithString: url];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetUrl];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *jsonNewsArray = [JSON mutableArrayValueForKey:@"newsList"];
        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity: [jsonNewsArray count]];
        NSLog(@"%d news fetched", [jsonNewsArray count]);
        for (id jsonNews in jsonNewsArray)
        {
            NSString *newsId = [jsonNews valueForKeyPath:@"id"];
            NSString *title = [jsonNews valueForKeyPath:@"title"];
            NSString *content = [jsonNews valueForKeyPath:@"content"];
            
            KRNews *news = [[KRNews alloc] init];
            news.newsId = [newsId intValue];
            news.title = [title base64DecodedString];
            news.content = [content base64DecodedString];
            
            [ret addObject:news];
        }
        handler(ret, NULL);
    } failure:nil];
    
    [operation start];    
}

@end
