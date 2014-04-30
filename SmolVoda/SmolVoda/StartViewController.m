//
//  StartViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 11.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "StartViewController.h"
#import "MainLogic.h"

@interface StartViewController ()

@end

@implementation StartViewController

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
    _backgroundImageView.image = [UIImage imageNamed:@"LaunchImage.png"];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated { //ждем секунду и переходим в следующий экран
    [super viewDidAppear:animated];
    //Создаем объект класса MainLogic и ждем секунду в потоке, чтобы устройство успело отследить наличие/отсутствие подключения к Интернет
    [MainLogic shared];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"sleep...");
        [NSThread sleepForTimeInterval:1.0f];
        NSLog(@"wake up!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"start" sender:self];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
