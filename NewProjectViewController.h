//
//  NewProjectViewController.h
//  Skyapp 2
//
//  Created by Cheuk yu Yeung on 30/12/2016.
//  Copyright © 2016 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface NewProjectViewController : UIViewController <UITextFieldDelegate>

@property(strong, nonatomic) FIRDatabaseReference *ref;

@end
