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
    IBOutlet UIWebView *webview;
    IBOutlet UIToolbar *toolBar;
}
@property (nonatomic, retain) KRNews *news;

- (IBAction)changeFontSize:(id)sender;
- (IBAction)shareNews:(id)sender;

@end

