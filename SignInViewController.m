//
//  SignInViewController.m
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 29/12/2016.
//  Copyright © 2016 Cheuk yu Yeung. All rights reserved.
//

#import "SignInViewController.h"
#import "UIViewController+Alerts.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *myNewUserBtn;

@end

@implementation SignInViewController

static Boolean calledAlready = false;

- (void)viewDidAppear:(BOOL)animated {
    if ([FIRAuth auth].currentUser) {
        // auto sign in
        [self performSegueWithIdentifier:@"signIn" sender:self];
        
        FIRUser *user = [FIRAuth auth].currentUser;
        NSString *email = user.email;
        // The user's ID, unique to the Firebase project.
        // Do NOT use this value to authenticate with your backend server,
        // if you have one. Use getTokenWithCompletion:completion: instead.
        NSString *uid = user.uid;
        NSURL *photoURL = user.photoURL;
        NSLog(@"email = %@, uid = %@, photoURL = %@",email,uid,photoURL);
    }
    if (!calledAlready){
        [FIRDatabase database].persistenceEnabled = YES;
        calledAlready = true;
    }
    _ref = [[FIRDatabase database] reference];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickLogin:(id)sender {
    NSLog(@"click login");
    [self showSpinner:^{
        [[FIRAuth auth] signInWithEmail:_emailField.text
           password:_passwordField.text
         completion:^(FIRUser *user, NSError *error) {
             [self hideSpinner:^{
                 if (error) {
                     [self showMessagePrompt:error.localizedDescription];
                     return;
                 }
                 [[[_ref child:@"users"] child:user.uid]
                  observeEventType:FIRDataEventTypeValue
                  withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                      if (![snapshot exists]) {
                          [self promptForNewUserName:user];
                      } else {
                          [self performSegueWithIdentifier:@"signIn" sender:self];
                      }
                  }];
             }];
         }];
    }];
}

- (void)promptForNewUserName:(FIRUser *)user {
    [self showTextInputPromptWithMessage:@"Username:"
     completionBlock:^(BOOL userPressedOK, NSString *_Nullable username) {
         if (!userPressedOK || !username.length) {
             return;
         }
         [self showSpinner:^{
             FIRUserProfileChangeRequest *changeRequest =[user profileChangeRequest];
             changeRequest.displayName = username;
             [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
                 [self hideSpinner:^{
                     if (error) {
                         [self showMessagePrompt:error.localizedDescription];
                         return;
                     }
                     [[[_ref child:@"users"] child:[FIRAuth auth].currentUser.uid]
                      setValue:@{@"username": username}];
                     [self performSegueWithIdentifier:@"signIn" sender:self];
                 }];
             }];
         }];
     }];
}


- (IBAction)clickNewUser:(id)sender {
    NSLog(@"click new user");
    [self showTextInputPromptWithMessage:@"Email:"
     completionBlock:^(BOOL userPressedOK, NSString *_Nullable email) {
         if (!userPressedOK || !email.length) {
             return;
         }
         [self showTextInputPromptWithMessage:@"Password:"
          completionBlock:^(BOOL userPressedOK, NSString *_Nullable password) {
              if (!userPressedOK || !password.length) {
                  return;
              }
              [self showTextInputPromptWithMessage:@"Username:"
               completionBlock:^(BOOL userPressedOK, NSString *_Nullable username) {
                   if (!userPressedOK || !username.length) {
                       return;
                   }
                   [self showSpinner:^{
                       [[FIRAuth auth] createUserWithEmail:email password:password
                        completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                            [self hideSpinner:^{
                                if (error) {
                                    [self showMessagePrompt:error.localizedDescription];
                                    return;
                                }
                            }];
                            [self showSpinner:^{
                                FIRUserProfileChangeRequest *changeRequest =
                                [[FIRAuth auth].currentUser profileChangeRequest];
                                changeRequest.displayName = username;
                                [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
                                    [self hideSpinner:^{
                                        if (error) {
                                            [self showMessagePrompt:error.localizedDescription];
                                            return;
                                        }
                                        // [START basic_write]
                                        [[[_ref child:@"users"] child:user.uid]
                                         setValue:@{@"username": username}];
                                        // [END basic_write]
                                        [self performSegueWithIdentifier:@"signIn" sender:self];
                                    }];
                                }];
                            }];
                        }];
                   }];
               }];
          }];
     }];
}

//close keyboard if any place is touched
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate protocol methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self clickLogin:nil];
    return YES;
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
