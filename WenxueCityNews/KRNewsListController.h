//
//  ViewController.h
//  ODRefreshControlDemo
//
//  Created by Fabio Ritrovato on 7/4/12.
//  Copyright (c) 2012 orange in a day. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRNewsListController : UITableViewController
{
    UILabel* infoLabel;
}
- (IBAction)refreshNews:(id)sender;
- (IBAction)systemConfig:(id)sender;

@end
