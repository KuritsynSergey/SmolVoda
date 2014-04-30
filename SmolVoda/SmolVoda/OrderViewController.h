//
//  OrderViewController.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 11.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralViewController.h"

@interface OrderViewController : GeneralViewController
@property (weak, nonatomic) IBOutlet UIButton *minusBottleButton;
@property (weak, nonatomic) IBOutlet UIButton *minusTareButton;
@property (weak, nonatomic) IBOutlet CustomLabel *bottlesLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *tareLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)minusBottle:(UIButton *)sender;
- (IBAction)plusBottle:(UIButton *)sender;
- (IBAction)minusTare:(UIButton *)sender;
- (IBAction)plusTare:(UIButton *)sender;
- (IBAction)goBack:(id)sender;
@end
