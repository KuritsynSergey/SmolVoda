//
//  LastOrderViewController.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 19.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "GeneralViewController.h"

@interface LastOrderViewController : GeneralViewController

@property (copy, nonatomic) NSNumber *selectedOrder;

@property (weak, nonatomic) IBOutlet CustomLabel *streetLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *houseLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *flatLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *floorLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *porchLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxImageView;
@property (weak, nonatomic) IBOutlet CustomLabel *dateLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *timeLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)goBack:(id)sender;
@end
