//
//  LoginViewController.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 07.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralViewController.h"

@interface LoginViewController : GeneralViewController
@property (weak, nonatomic) IBOutlet CustomTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *nameTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *patronymicTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *centralScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;

- (IBAction)tapNextButton:(id)sender;
- (IBAction)formatPhoneNumber:(UITextField *)sender;
- (IBAction)checkboxTapped:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goNext:(id)sender;

@end
