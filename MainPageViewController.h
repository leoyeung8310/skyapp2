//
//  MainPageViewController.h
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 29/12/2016.
//  Copyright © 2016 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FirebaseDatabaseUI;
@import Firebase;

@interface MainPageViewController : UIViewController<UITableViewDelegate>

// [START define_database_reference]
@property (strong, nonatomic) FIRDatabaseReference *ref;
// [END define_database_reference]
@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
