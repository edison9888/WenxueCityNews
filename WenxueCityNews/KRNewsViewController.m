//
//  KRNewsViewController.m
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-15.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import "KRNewsViewController.h"
#import "KRNews.h"

@implementation KRNewsViewController
@synthesize news;

/*
- (void)loadView
{
    // Create an instance of UIWebView as large as the screen
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIWebView *wv = [[UIWebView alloc] initWithFrame:screenFrame];
    // Tell web view to scale web content to fit within bounds of webview
    [wv setScalesPageToFit:YES];

    [self setView:wv];
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *mainBundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareNews:)];
    toolBar.items = [NSArray arrayWithObjects:shareButtonItem, nil];
    
    NSString *html = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-family: \"%@\"; font-size: %dpx;}\n"
                                   "html {-webkit-text-size-adjust: none; /* Never autoresize text */}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>", @"helvetica", 48, [news content]];

//    UIImage *image = [UIImage imageNamed:@"font.png"];
//    UIBarButtonItem *changeSize = [[UIBarButtonItem alloc] initWithImage: image style:UIBarButtonItemStylePlain target:self action: @selector(changeFontSize:)];
    UIBarButtonItem *changeSize = [[UIBarButtonItem alloc] initWithTitle:@"A" style:UIBarButtonItemStylePlain target:self action: @selector(changeFontSize:)];
    [[self navigationItem] setRightBarButtonItem: changeSize];
    [webview setScalesPageToFit:YES];
    [webview loadHTMLString: html baseURL: mainBundleURL];
}

- (IBAction)changeFontSize:(id)sender
{
    NSLog(@"Change font size");
}

- (IBAction)shareNews:(id)sender
{
    NSLog(@"Share this news");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
