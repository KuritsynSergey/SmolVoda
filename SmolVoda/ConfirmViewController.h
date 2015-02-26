//
//  ConfirmViewController.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 19.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "GeneralViewController.h"
#import "MBProgressHUD.h"
#import "BSKeyboardControls.h"

@interface ConfirmViewController : GeneralViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, MBProgressHUDDelegate, BSKeyboardControlsDelegate>

@property (weak, nonatomic) IBOutlet CustomTextField *streetTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *porchTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *flatTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *houseTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *floorTextField;
@property (weak, nonatomic) IBOutlet UIButton *elevatorButton;
@property (weak, nonatomic) IBOutlet PickerTextField *dateTextField;
@property (weak, nonatomic) IBOutlet PickerTextField *timeTextField;
@property (weak, nonatomic) IBOutlet CustomLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *centralScrollView;

- (IBAction)goBack:(id)sender;
- (IBAction)checkout:(id)sender;
- (IBAction)dateTextFieldExit:(id)sender;
- (IBAction)checkboxTapped:(id)sender;

@end
