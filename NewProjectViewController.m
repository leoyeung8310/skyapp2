//
//  NewProjectViewController.m
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 30/12/2016.
//  Copyright © 2016 Cheuk yu Yeung. All rights reserved.
//

#import "NewProjectViewController.h"
#import "User.h"
#import "Project.h"
@import Firebase;

@interface NewProjectViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@end

@implementation NewProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // [START create_database_reference]
    self.ref = [[FIRDatabase database] reference];
    // [END create_database_reference]
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSubmit:(id)sender {
    // [START single_value_read]
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        User *user = [[User alloc] initWithUsername:snapshot.value[@"username"]];
        
        // [START_EXCLUDE]
        [self writeNewProject:userID
                  username:user.username
                     title:_titleTextField.text];
        // Finish this Activity, back to the stream
        [self.navigationController popViewControllerAnimated:YES];
        // [END_EXCLUDE]
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    // [END single_value_read]
}

- (void)writeNewProject:(NSString *)userID username:(NSString *)username title:(NSString *)title{
    // Create new project at /user-projects/$userid/$projectid and at
    // /projects/$projectid simultaneously
    // [START write_fan_out]
    NSString *key = [[_ref child:@"projects"] childByAutoId].key;
    NSDictionary *project = @{@"uid": userID,
                           @"author": username,
                           @"title": title};
    NSDictionary *childUpdates = @{[@"/projects/" stringByAppendingString:key]: project,
                                   [NSString stringWithFormat:@"/user-projects/%@/%@/", userID, key]: project};
    [_ref updateChildValues:childUpdates];
    // [END write_fan_out]
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
