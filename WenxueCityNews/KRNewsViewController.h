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

@property (nonatomic, retain) KRNews *news;

- (id)initWithNews:(KRNews *)news;

@end

