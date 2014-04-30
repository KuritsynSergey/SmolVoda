//
//  MapViewController.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 23.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GeneralViewController.h"

@interface MapViewController : GeneralViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)goBack:(id)sender;
@end
