//
//  MainPageViewController.m
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 29/12/2016.
//  Copyright © 2016 Cheuk yu Yeung. All rights reserved.
//

#import "MainPageViewController.h"
#import "Project.h"
#import "ProjectTableViewCell.h"
#import "ProjectDataSource.h"
#import "ProjectDetailViewController.h"

@import Firebase;

@interface MainPageViewController ()

@end

@implementation MainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"< 登出"
                                style:UIBarButtonItemStyleDone
                                target:self
                                action:@selector(OnClick_btnBack:)];
    self.navigationItem.leftBarButtonItem = btnBack;
    
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc]
                                initWithTitle:@"+"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(OnClick_btnAdd:)];
    self.navigationItem.rightBarButtonItem = btnAdd;
    
    // [START create_database_reference]
    self.ref = [[FIRDatabase database] reference];
    // [END create_database_reference]
    
    self.dataSource = [[ProjectDataSource alloc] initWithQuery:[self getQuery]
                                                 modelClass:[Project class]
                                                   nibNamed:@"ProjectTableViewCell"
                                        cellReuseIdentifier:@"project"
                                                       view:self.tableView];
    
    [self.dataSource
     populateCellWithBlock:^void(ProjectTableViewCell *__nonnull cell,
                                 Project *__nonnull project) {
         cell.authorImage.image = [UIImage imageNamed:@"ic_account_circle"];
         cell.authorLabel.text = project.author;
         cell.projectTitle.text = project.title;
     }];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        
        //Fire base user logout
        NSError *signOutError;
        BOOL status = [[FIRAuth auth] signOut:&signOutError];
        if (!status) {
            NSLog(@"Error signing out: %@", signOutError);
            return;
        }
        
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)OnClick_btnBack:(id)sender  {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)OnClick_btnAdd:(id)sender  {
    [self performSegueWithIdentifier:@"newProject" sender:self];
}

- (FIRDatabaseQuery *) getQuery {
    // [START recent_projects_query]
    FIRDatabaseQuery *recentProjectsQuery = [[self.ref child:@"projects"] queryLimitedToFirst:100];
    // [END recent_projects_query]
    return recentProjectsQuery;
    //return self.ref;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"goProjectDetail" sender:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goProjectDetail"]) {
        NSIndexPath *path = sender;
        ProjectDetailViewController *detail = segue.destinationViewController;
        FirebaseTableViewDataSource *source = self.dataSource;
        FIRDataSnapshot *snapshot = [source objectAtIndex:path.row];
        detail.projectKey = snapshot.key;
    }
}
@end
