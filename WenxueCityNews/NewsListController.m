//
//  NewsListController.m
//
//  Created by Haihua Xiao on 13-3-10.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import "NewsListController.h"
#import "ODRefreshControl.h"
#import "KRNewsStore.h"
#import "KRNews.h"
#import "KRNewsService.h"

@implementation NewsListController

- (id)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        
        [n setTitle:NSLocalizedString(@"文学城新闻", @"appTitle")];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        
    [[KRNewsStore sharedStore] loadNews:0 to:0 max:20 withHandler:^(KRNews *news, NSError *error) {
        NSArray *allItems = [[KRNewsStore sharedStore] allItems];
        NSLog(@"News(%d) - %@", [news newsId], [news title]);
        int lastRow = [allItems indexOfObject:news];
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
        [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
                                withRowAnimation:UITableViewRowAnimationTop];
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    NSLog(@"Starting refreshing...");
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[KRNewsStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KRNews *news = [[[KRNewsStore sharedStore] allItems]
                  objectAtIndex:[indexPath row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"UITableViewCell"];
    }

    [[cell textLabel] setText:[news title]];
    
    return cell;
}


@end
