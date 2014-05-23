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

@property (assign) int webViewLoadingCount;
@property NSMutableArray * historyList;

- (void)startLoading:(NSString*)text;
- (void)scrollToDictionaryContents;
- (void)addHistory:(NSString*)text;
- (void)saveData;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.historyList = [NSMutableArray array];
    {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [self.historyList addObjectsFromArray: [defaults stringArrayForKey:@"historyList"] ];
    }
    
    [self.searchBar setPlaceholder:NSLocalizedString(@"SearchBarPlaceHolder",nil)];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
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
        
        [self addHistory: text];
        
        NSString * escaped = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString * url_string = [NSString stringWithFormat: @"http://eow.alc.co.jp/sp/search.html?q=%@&pg=1", escaped ];
        
        NSLog(@"URL: %@", url_string);
        
        NSURL * url = [NSURL URLWithString:url_string];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        
        self.webView.alpha = 0.0f;
        
        self.webViewLoadingCount = 0;
        [self.webView loadRequest: request];
    }
}

- (void)addHistory:(NSString *)text
{
    // 古くて重複する履歴を削除する
    for( int i=0 ; i<self.historyList.count ; )
    {
        if([ self.historyList[i] isEqualToString:text ])
        {
            [self.historyList removeObjectAtIndex:i];
            continue;
        }
        ++i;
    }
    
    // 先頭に履歴を挿入
    [self.historyList insertObject:text atIndex:0];

    // 個数を制限
    const int maxItems = 100;
    if(self.historyList.count>maxItems)
    {
        [self.historyList removeObjectsInRange:NSMakeRange(maxItems, self.historyList.count-maxItems)];
    }
    
    // 画面を更新
    [self.tableView reloadData];
    
    // 保存
    [self saveData];
}

- (void)saveData
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.historyList forKey:@"historyList"];
    [defaults synchronize];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.historyList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchBar.text = self.historyList[indexPath.row];

    [self startLoading:self.searchBar.text];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // 元データ削除
        [self.historyList removeObjectAtIndex:indexPath.row];
        
        // TableView のアイテムを削除
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}

@end
