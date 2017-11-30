//
//  ProjectDetailViewController.h
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 30/12/2016.
//  Copyright © 2016 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectDetailViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSString *projectKey;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
