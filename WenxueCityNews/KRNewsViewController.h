//
//  KRNewsViewController.h
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-15.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KRNews;

@interface KRNewsViewController : UIViewController 
{
    UIWebView* webview;
}
@property (nonatomic, retain) KRNews *news;

- (IBAction)shareNews:(id)sender;

@end

