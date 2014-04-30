//
//  GeneralViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 10.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "GeneralViewController.h"
#import "MapViewController.h"
#import "REActivityViewController.h"

@interface GeneralViewController ()

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSURL *smolvodaLink;

@property (nonatomic, strong) REActivityViewController *activityViewController;

@end

@implementation GeneralViewController

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
    _message = @"Я заказываю доставку артезианской воды со своего iPhone!";
    _smolvodaLink = [NSURL URLWithString:@"http://www.smolvoda.ru"];

    CGRect frameBtn;
    
    /*
    //VK button
    frameBtn = CGRectMake(184.0, 9.5, 30.0, 30.0);
    _vkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_vkButton setImage:[UIImage imageNamed:@"vk_enabled.png"] forState:UIControlStateNormal];
    [_vkButton setImage:[UIImage imageNamed:@"vk_disabled.png"] forState:UIControlStateDisabled];
    [_vkButton setFrame:frameBtn];
    [_vkButton addTarget:self action:@selector(shareVK:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_vkButton];
    
    //Twitter button
    frameBtn = CGRectMake(233.0, 9.5, 30.0, 30.0);
    _twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_twitterButton setImage:[UIImage imageNamed:@"twitter_enabled.png"] forState:UIControlStateNormal];
    [_twitterButton setImage:[UIImage imageNamed:@"twitter_disabled.png"] forState:UIControlStateDisabled];
    [_twitterButton setFrame:frameBtn];
    [_twitterButton addTarget:self action:@selector(sendTweet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_twitterButton];
    
    //Facebook button
    frameBtn = CGRectMake(278.0, 9.5, 30.0, 30.0);
    _facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_facebookButton setImage:[UIImage imageNamed:@"facebook_enabled.png"] forState:UIControlStateNormal];
    [_facebookButton setImage:[UIImage imageNamed:@"facebook_disabled.png"] forState:UIControlStateDisabled];
    [_facebookButton setFrame:frameBtn];
    [_facebookButton addTarget:self action:@selector(recommendationFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_facebookButton];
    */
    //phone call button
    frameBtn = CGRectMake(11.5, 4.5, 30.0, 42.0);
    _phoneCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_phoneCallButton setImage:[UIImage imageNamed:@"phoneCallButton.png"] forState:UIControlStateNormal];
    [_phoneCallButton setFrame:frameBtn];
    [_phoneCallButton addTarget:self action:@selector(makePhoneCall:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_phoneCallButton];
    
    //maps button
    frameBtn = CGRectMake(50.0, 4.5, 30.0, 42.0);
    _mapsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mapsButton setImage:[UIImage imageNamed:@"maps.png"] forState:UIControlStateNormal];
    [_mapsButton setFrame:frameBtn];
    [_mapsButton addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_mapsButton];
    
    //web button
    frameBtn = CGRectMake(88.5, 4.5, 42.0, 42.0);
    _webButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_webButton setImage:[UIImage imageNamed:@"webButton.png"] forState:UIControlStateNormal];
    [_webButton setFrame:frameBtn];
    [_webButton addTarget:self action:@selector(goToSite:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_webButton];
    
    //share button
    frameBtn = CGRectMake(275.0, 4.5, 42.0, 42.0);
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareButton setImage:[UIImage imageNamed:@"ShareButton.png"] forState:UIControlStateNormal];
    [_shareButton setFrame:frameBtn];
    [_shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shareButton];
    
    //prepare activities
    
    REFacebookActivity *facebookActivity = [[REFacebookActivity alloc] init];
    RETwitterActivity *twitterActivity = [[RETwitterActivity alloc] init];
    REVKActivity *vkActivity = [[REVKActivity alloc] initWithClientId:@"4236551"];
    REMessageActivity *messageActivity = [[REMessageActivity alloc] init];
    REMailActivity *mailActivity = [[REMailActivity alloc] init];
    RECopyActivity *copyActivity = [[RECopyActivity alloc] init];
    vkActivity.userInfo =@{@"url": _smolvodaLink,
                           @"text": _message,
                           @"image": [UIImage imageNamed:@"150.png"]};

    // Compile activities into an array, we will pass that array to
    // REActivityViewController on the next step
    //
    NSArray *activities = @[facebookActivity, twitterActivity, vkActivity,
                            messageActivity, mailActivity, copyActivity];
    // Create REActivityViewController controller and assign data source
    //
    _activityViewController = [[REActivityViewController alloc] initWithViewController:self activities:activities];
    _activityViewController.userInfo = @{@"url": _smolvodaLink,
                                         @"text": _message};
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        //нажата отмена -- ничего не делаем
    }
    else {
        switch (alertView.tag) {
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://84812353510"]];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Осуществление звонка

- (void)makePhoneCall:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"telprompt://84812353510"]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Вы хотите позвонить в офис компании «Ключ здоровья»?"
                                                            message:@"8 (4812) 35-35-10"
                                                           delegate:self
                                                  cancelButtonTitle:@"Отмена"
                                                  otherButtonTitles:@"Позвонить",nil];
        [alertView show];
        alertView.tag = 1;
        alertView = nil;
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Данная функция доступна только на iPhone."
                                                           delegate:self
                                                  cancelButtonTitle:@"ОК"
                                                  otherButtonTitles: nil];
        [alertView show];
        alertView = nil;
    }
}

#pragma mark - Переход к картам

- (void)showMap:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    MapViewController *mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [self presentViewController:mapController animated:NO completion:nil];
}

- (void)goToSite:(id)sender {
    [[UIApplication sharedApplication] openURL:_smolvodaLink];
}

#pragma mark - Публикации в социальные сети

- (void)share:(id)sender {
    [_activityViewController presentFromViewController:self];
}


@end
