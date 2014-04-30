//
//  CustomLabel.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 15.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CustomLabel.h"

@implementation CustomLabel

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
    self.font = [UIFont fontWithName:@"Franklin Gothic Medium Cond" size:self.font.pointSize];
//    self.textColor = [UIColor colorWithRed:105.0/255.0 green:179.0/255.0 blue:44.0/255.0 alpha:1.0];
    self.layer.shadowColor = [[UIColor colorWithWhite:0.0 alpha:0.18] CGColor];
    self.layer.shadowOffset = CGSizeMake(2.6, 1.5);
    self.layer.shadowRadius = 1.1;
    self.layer.shadowOpacity = 1.0;
    self.layer.masksToBounds = NO;
    self.layer.shouldRasterize = YES;
    [super drawRect:rect];
}


@end
