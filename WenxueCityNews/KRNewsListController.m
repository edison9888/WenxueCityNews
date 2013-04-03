//
//  NewsListController.m
//
//  Created by Haihua Xiao on 13-3-10.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import "KRNewsListController.h"
#import "KRNewsStore.h"
#import "KRNews.h"
#import "KRNewsViewController.h"
#import "KRSettingViewController.h"
#import "KRDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KRAppDelegate.h"
#import "MBProgressHUD.h"
#import "ODRefreshControl.h"

@implementation KRNewsListController

- (id)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        
        [n setTitle:@"文学城新闻"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeUpdated:)
                                                     name:@"storeUpdated"
                                                   object:nil];        
        [[self tabBarItem] setTitle: @"新闻"];
        [[self tabBarItem] setImage: [UIImage imageNamed:@"rss"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshNews:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    int maxNewsId = [[KRNewsStore sharedStore] maxNewsId];
    [self fetchNews:0 to:maxNewsId max:40 appendToTop: YES force: YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (IBAction)refreshNews:(id)sender
{
    int maxNewsId = [[KRNewsStore sharedStore] maxNewsId];
    int maxNum = 100;
    NSLog(@"Fetch latest %d items from %d - ", maxNum, maxNewsId);
    [self fetchNews: 0 to:maxNewsId max:maxNum appendToTop: YES force: sender != nil completion:^() {
        if([sender respondsToSelector:@selector(endRefreshing)]) {
            [sender performSelector:@selector(endRefreshing)];
        }
    }];
}

- (IBAction)systemConfig:(id)sender
{
    KRSettingViewController *settingController = [[KRSettingViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:settingController];
    
    navController.navigationBar.tintColor = APP_COLOR;
    navController.toolbar.tintColor = APP_COLOR;
    
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];

    [self presentViewController:navController animated:YES completion:nil];
}

- (void) fetchNews: (int)from to:(int)to max:(int)max appendToTop:(BOOL)appendToTop force: (BOOL)force completion:(void (^)())completion
{
    MBProgressHUD *hud = nil;
    if(force) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在载入...";
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[KRNewsStore sharedStore] loadNews:from to:to max:max appendToTop:appendToTop force:force withHandler:^(NSArray *newsArray, NSError *error) {
        if(newsArray) {
            NSArray *allItems = [[KRNewsStore sharedStore] allItems];
            NSMutableArray  *ips = [[NSMutableArray alloc] initWithCapacity: [newsArray count]];
            for(id news in newsArray)
            {
                //NSLog(@"News(%d) - %@", [news newsId], [news title]);
                int lastRow = [allItems indexOfObject:news];
                
                NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
                [ips addObject:ip];
            }
            [[self tableView] insertRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationNone];
            if([ips count]) {
                [[self tableView] scrollToRowAtIndexPath: [ips objectAtIndex:0] atScrollPosition: UITableViewScrollPositionTop animated:YES];
            }
        }
        if(hud) {
            [hud hide:YES];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(completion) completion();
    }];
}

- (void)storeUpdated:(NSNotification *)notification
{
    NSLog(@"OK! %@", [NSThread currentThread]);
    [[self tableView] reloadData];
    NSLog(@"storeUpdated");
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
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    });
    
    [self refreshNews:refreshControl];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[KRNewsStore sharedStore] allItems] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath row];
    if(index < [[[KRNewsStore sharedStore] allItems] count]) {
        KRNews *news = [[[KRNewsStore sharedStore] allItems] objectAtIndex:[indexPath row]];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"UITableViewCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UIView *selectionColor = [[UIView alloc] init];
            selectionColor.backgroundColor = APP_COLOR;
            cell.selectedBackgroundView = selectionColor;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        }
        [[cell imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [[cell textLabel] setText: [news title]];
        if([news read]) {
            [[cell imageView] setImage: [UIImage imageNamed:@"bullet_grey"]];
            cell.textLabel.textColor = [UIColor colorWithRed:96/255.0f  green:96/255.0f  blue:96/255.0f alpha:1.0f];
        } else {
            [[cell imageView] setImage: [UIImage imageNamed:@"bullet_blue"]];
            cell.textLabel.textColor = [UIColor blackColor];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewReloadCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"UITableViewReloadCell"];
        }
        
        [[cell textLabel] setText: @"显示下20条..."];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath row];
    if(index < [[[KRNewsStore sharedStore] allItems] count]) {
        KRNews *selectedNews = [[KRNewsStore sharedStore] itemAt:index];
        [selectedNews setRead: YES];

        KRDetailViewController *detailViewController = [[KRDetailViewController alloc] init];
        [detailViewController setStartIndex: index];
        
        // Push it onto the top of the navigation controller's stack
        [[self navigationController] pushViewController:detailViewController animated:YES];
    } else {
        int minNewsId = [[KRNewsStore sharedStore] minNewsId];
        NSLog(@"Fetch previous 20 items: %d - ", minNewsId);
        [self fetchNews: minNewsId to:0 max:20 appendToTop:NO force: YES completion:nil];
    }
}

@end
