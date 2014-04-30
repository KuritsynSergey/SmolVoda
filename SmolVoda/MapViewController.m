//
//  MapViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 23.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "MapViewController.h"
#import "MainLogic.h"
#import "Keys.h"

@interface MapViewController ()

@property (weak, nonatomic) GMSMapView *mapView;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _backgroundImageView.image = [UIImage imageNamed:@"LoginBackground.png"];
    
    self.mapsButton.enabled = NO;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:54.7843260
                                                            longitude:32.0461740
                                                                 zoom:16];
    CGRect frame = CGRectMake(16.5, 79, 289, [UIScreen mainScreen].bounds.size.height - (79 + 46));
    self.mapView = [GMSMapView mapWithFrame:frame camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    [self.view addSubview:self.mapView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[MainLogic shared] loadSellPoints];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary *sellPoint in [[MainLogic shared] sellPoints]) {
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.title = sellPoint[kDescriptionKey];
                CLLocationCoordinate2D coords;
                coords.latitude = [sellPoint[kLatitudeKey] floatValue];
                coords.longitude = [sellPoint[kLongitudeKey] floatValue];
                marker.position = coords;
                marker.appearAnimation = kGMSMarkerAnimationPop;
                marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:99.0/255.0 green:183.0/255.0 blue:224.0/255.0 alpha:1.0]];
                marker.map = self.mapView;
                marker = nil;
            }
        });
    });
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew //| NSKeyValueObservingOptionInitial
                      context:NULL];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView removeObserver:self forKeyPath:@"myLocation"];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"myLocation"]) {
        [self.mapView animateToLocation:self.mapView.myLocation.coordinate];
        self.mapView.trafficEnabled = YES;
    }
}

- (IBAction)goBack:(id)sender { //Кнопка "Назад" -- анимация
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
