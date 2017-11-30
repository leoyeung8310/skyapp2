//
//  ProjectDetailTableViewCell.h
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 6/1/2017.
//  Copyright © 2017 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) NSString *detailStr;
@property (nonatomic, assign) BOOL isCommand;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) UIWebView *webView;
@end
