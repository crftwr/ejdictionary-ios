//
//  ViewController.m
//  Eijiro
//
//  Created by Shimomura Tomonori on 2014/05/21.
//  Copyright (c) 2014年 craftware. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search: %@", searchBar.text);
    
    NSString * escaped = [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString * url_string = [NSString stringWithFormat: @"http://eow.alc.co.jp/sp/search.html?q=%@&pg=1", escaped ];
    
    NSLog(@"url: %@", url_string);
    
    NSURL * url = [NSURL URLWithString:url_string];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest: request];
}

@end
