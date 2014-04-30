//
//  SlideLeftCustomSegue.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 15.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SlideLeftCustomSegue.h"

@implementation SlideLeftCustomSegue

- (void)perform {
    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [srcViewController.view.window.layer addAnimation:transition forKey:nil];
    
    [srcViewController presentViewController:destViewController animated:NO completion:nil];
}

@end
