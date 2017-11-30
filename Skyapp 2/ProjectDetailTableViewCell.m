//
//  ProjectDetailTableViewCell.m
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 6/1/2017.
//  Copyright © 2017 Cheuk yu Yeung. All rights reserved.
//

#import "ProjectDetailTableViewCell.h"

@implementation ProjectDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)labelClick
{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = @[
                       [[UIMenuItem alloc] initWithTitle:@"<<" action:@selector(sendToSnap:)],
                       //[[UIMenuItem alloc] initWithTitle:@"?" action:@selector(reply:)],
                       ];
    [menu setTargetRect:self.bounds inView:self];
    [menu setMenuVisible:YES animated:YES];
}

#pragma mark - UIMenuController
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.detailLabel.text){
        if ((action == @selector(sendToSnap:) && self.isCommand)
            || action == @selector(copy:))
            return YES;
    }
    return NO;
}

#pragma mark - Menu Item
- (void)copy:(UIMenuController *)menu
{
    [UIPasteboard generalPasteboard].string = self.detailLabel.text;
}

- (void)sendToSnap:(NSIndexPath *)indexPath{
    NSString * str = [self.detailStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]; //for json decoding/encoding
    NSString * cmd = [NSString stringWithFormat:@"pasteACommand(\"%@\")",str]; // for escapting " in javscript
    [self.webView stringByEvaluatingJavaScriptFromString:cmd];
}


@end
