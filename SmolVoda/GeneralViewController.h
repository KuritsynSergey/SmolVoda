//
//  GeneralViewController.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 10.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "CustomLabel.h"
#import "CustomTextField.h"
#import "PickerTextField.h"

@interface GeneralViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) UIButton *vkButton;
@property (weak, nonatomic) UIButton *twitterButton;
@property (weak, nonatomic) UIButton *facebookButton;
@property (weak, nonatomic) UIButton *shareButton;
@property (weak, nonatomic) UIButton *phoneCallButton;
@property (weak, nonatomic) UIButton *mapsButton;
@property (weak, nonatomic) UIButton *webButton;

@end
