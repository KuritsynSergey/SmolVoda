//
//  MainViewController.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 11.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralViewController.h"

@interface MainViewController : GeneralViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet CustomLabel *adLabel;
@property (weak, nonatomic) IBOutlet CustomLabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;

- (IBAction)order:(id)sender;
@end
