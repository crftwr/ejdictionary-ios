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
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property int webViewLoadingCount;

- (void)startLoading:(NSString*)text;
- (void)scrollToDictionaryContents;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.tableView.delegate = self;
    
    //[self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"start editting");
    
    self.tableView.hidden = false;
    
    return true;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self startLoading: searchBar.text];
}

- (void)startLoading:(NSString*) text
{
    // Keyboard 閉じる
    [self.view endEditing:TRUE];
    
    // TableView 閉じる
    self.tableView.hidden = true;
    
    // WebViewにURLを使ってリクエスト
    {
        NSLog(@"Word: %@", text);
        
        NSString * escaped = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString * url_string = [NSString stringWithFormat: @"http://eow.alc.co.jp/sp/search.html?q=%@&pg=1", escaped ];
        
        NSLog(@"URL: %@", url_string);
        
        NSURL * url = [NSURL URLWithString:url_string];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        
        self.webViewLoadingCount = 0;
        [self.webView loadRequest: request];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(self.webViewLoadingCount==0)
    {
        [self.activityIndicator startAnimating];
        self.webView.alpha = 0.0f;
    }

    self.webViewLoadingCount++;
    
    //NSLog(@"start load %d", self.webViewLoadingCount );
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webViewLoadingCount--;
    
    if(self.webViewLoadingCount==0)
    {
        [self.activityIndicator stopAnimating];
     
        if(self.webView.alpha<=0.0f)
        {
            [self scrollToDictionaryContents];
            self.webView.alpha = 1.0f;
        }
    }

    //NSLog(@"finish load %d", self.webViewLoadingCount );
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scroll: %f,%f", scrollView.contentOffset.x, scrollView.contentOffset.y );
}

- (void)scrollToDictionaryContents
{
    [self.webView.scrollView setContentOffset:CGPointMake(0.0f,160.0f) animated:false];
}

@end
