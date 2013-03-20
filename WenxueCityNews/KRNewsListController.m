//
//  NewsListController.m
//
//  Created by Haihua Xiao on 13-3-10.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import "KRNewsListController.h"
#import "ODRefreshControl.h"
#import "KRNewsStore.h"
#import "KRNews.h"
#import "KRNewsViewController.h"
#import "KRSettingViewController.h"

@implementation KRNewsListController

- (id)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStylePlain];
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

    [self.navigationController setToolbarHidden:NO];
    
    UIImage *refreshImage = [UIImage imageNamed:@"refresh"];
//    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshNews:)];
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithImage:refreshImage landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(refreshNews:)];
    
    UIImage *configImage = [UIImage imageNamed:@"cog"];
    UIBarButtonItem* configButton = [[UIBarButtonItem alloc] initWithImage:configImage landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(systemConfig:)];
    
    infoLabel = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [infoLabel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], UITextAttributeFont,nil] forState:UIControlStateNormal];

    UIBarButtonItem* space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [self setToolbarItems:[NSArray arrayWithObjects:refreshButton, space1, infoLabel, space2, configButton, nil]];
    
    [self updateInfoLabel];
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    int maxNewsId = [[KRNewsStore sharedStore] maxNewsId];
    [self fetchNews:0 to:maxNewsId max:40 appendToTop: YES];
}

- (IBAction)refreshNews:(id)sender
{
    int maxNewsId = [[KRNewsStore sharedStore] maxNewsId];
    NSLog(@"Fetch latest items: %d - ", maxNewsId);
    [self fetchNews: 0 to:maxNewsId max:100 appendToTop: YES];
}

- (IBAction)systemConfig:(id)sender
{
    KRSettingViewController *settingController = [[KRSettingViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:settingController];
    
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];

    [self presentViewController:navController animated:YES completion:nil];
}

- (void) updateInfoLabel
{
    NSArray *allItems = [[KRNewsStore sharedStore] allItems];
    [infoLabel setTitle: [NSString stringWithFormat:@"%d 条新闻, %d 条未读", [allItems count], [[KRNewsStore sharedStore] unread]]];
}

- (void) fetchNews: (int)from to:(int)to max:(int)max appendToTop:(BOOL)appendToTop
{
//    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    activityView.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
//    [activityView setBackgroundColor:[UIColor blackColor]];
//    [activityView startAnimating];
//    [self.view addSubview:activityView];
    
    [[KRNewsStore sharedStore] loadNews:from to:to max:max appendToTop:appendToTop withHandler:^(NSArray *newsArray, NSError *error) {
        NSArray *allItems = [[KRNewsStore sharedStore] allItems];
        NSMutableArray  *ips = [[NSMutableArray alloc] initWithCapacity: [newsArray count]];
        for(id news in newsArray)
        {
            NSLog(@"News(%d) - %@", [news newsId], [news title]);
            int lastRow = [allItems indexOfObject:news];
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
            [ips addObject:ip];
        }
        [[self tableView] insertRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationNone];
        [self updateInfoLabel];
    }];
}

- (void)storeUpdated:(NSNotification *)note
{
    NSLog(@"OK! %@", [NSThread currentThread]);
    [[self tableView] reloadData];
    NSLog(@"DONE");
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
        [refreshControl endRefreshing];
    });
    
    [self refreshNews:nil];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[KRNewsStore sharedStore] allItems] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath row];
    if(index < [[[KRNewsStore sharedStore] allItems] count]) {
        KRNews *news = [[[KRNewsStore sharedStore] allItems]
                        objectAtIndex:[indexPath row]];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"UITableViewCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        [[cell textLabel] setText: [news title]];
        if([news read]) {
            [[cell imageView] setImage: [UIImage imageNamed:@"bullet_grey"]];
        } else {
            [[cell imageView] setImage: [UIImage imageNamed:@"bullet_blue"]];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewReloadCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"UITableViewReloadCell"];
        }
       
        [[cell textLabel] setText: NSLocalizedString(@"载入更多...", @"loadMore")];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        return cell;
   }
}

- (void)tableView:(UITableView *)aTableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath row];
    if(index < [[[KRNewsStore sharedStore] allItems] count]) {
        NSArray *items = [[KRNewsStore sharedStore] allItems];
        KRNews *selectedNews = [items objectAtIndex:[indexPath row]];
        [selectedNews setRead: YES];
        
        KRNewsViewController *detailViewController = [[KRNewsViewController alloc] init];
        [detailViewController setNews:selectedNews];
        [self updateInfoLabel];
        
        // Push it onto the top of the navigation controller's stack
        [[self navigationController] pushViewController:detailViewController
                                               animated:YES];
    } else {
        int minNewsId = [[KRNewsStore sharedStore] minNewsId];
        NSLog(@"Fetch previous 20 items: %d - ", minNewsId);
        [self fetchNews: minNewsId to:0 max:20 appendToTop:NO];
    }
}

@end
