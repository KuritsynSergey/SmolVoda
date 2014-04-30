//
//  PickerTextField.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 27.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "PickerTextField.h"

@implementation PickerTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectZero;
}

@end
