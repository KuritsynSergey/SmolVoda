//
//  CustomTextField.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 20.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
    paddingView = nil;
    self.font = [UIFont fontWithName:@"Franklin Gothic Medium Cond" size:20];
    self.textColor = [UIColor colorWithRed:99.0/255.0 green:183.0/255.0 blue:224.0/255.0 alpha:1.0];
}


@end
