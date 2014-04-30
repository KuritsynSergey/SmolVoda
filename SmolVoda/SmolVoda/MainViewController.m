//
//  MainViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 11.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Keys.h"
#import "MainViewController.h"
#import "MainLogic.h"

static int scrollViewPageWidth = 287;

@interface MainViewController ()

@end

@implementation MainViewController

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
    _backgroundImageView.image = [UIImage imageNamed:@"MainBackground.png"];
    
    if ([[MainLogic shared] internetActive] && [[MainLogic shared] hostActive]) {
        [[MainLogic shared] loadPrice];
        [[MainLogic shared] loadAd];
        [self customizeAdView];
        NSDictionary *dict = [[MainLogic shared] priceList];
        NSNumber *bottlePrice = dict[kPriceListKey][0][kPriceKey];
        _mainLabel.text = [NSString stringWithFormat:@"Вода артезианская\n«Ключ здоровья»\nпервой категории\n\nБутыль 19 литров\nЦена: %@ руб.\nЗалоговая стоимость тары: %@ руб.",bottlePrice, dict[kTarePriceKey]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[MainLogic shared] internetActive] || ![[MainLogic shared] hostActive]) {
        NSString *message = [[MainLogic shared] internetActive] ? @"Наш сервер недоступен.\nПроверьте подключение к сети Интернет" : @"Необходимо наличие подключения к сети Интернет.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка подключения"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"ОК"
                                                  otherButtonTitles: nil];
        [alertView show];
        alertView = nil;
        self.vkButton.enabled = NO;
        self.twitterButton.enabled = NO;
        self.facebookButton.enabled = NO;
        self.webButton.enabled = NO;
        _orderButton.enabled = NO;
    } else {
        self.vkButton.enabled = YES;
        self.twitterButton.enabled = YES;
        self.facebookButton.enabled = YES;
        self.webButton.enabled = YES;
        _orderButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView { //Меняем заголовок рекламного блока в зависимости от отображаемого материала
    MainLogic *model = [MainLogic shared];
    int page = floor((scrollView.contentOffset.x - scrollViewPageWidth / 2) /scrollViewPageWidth) + 1;
    NSArray *keys = [[model adItems] allKeys];
    if (page < [[model adItems][keys[0]] count]) {
        _adLabel.text = keys[0];
    } else if (page < [[model adItems][keys[1]] count] + [[model adItems][keys[0]] count]) {
        _adLabel.text = keys[1];
    } else if (page < [[model adItems][keys[2]] count] + [[model adItems][keys[1]] count] + [[model adItems][keys[0]] count]) {
        _adLabel.text = keys[2];
    }
}

#pragma mark - Custom Methods

- (void)customizeAdView { //настройка представления рекламного блока
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(17, [UIScreen mainScreen].bounds.size.height - 112.5, scrollViewPageWidth, 97)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    MainLogic *model = [MainLogic shared];
    NSArray *keys = [[model adItems] allKeys];
    int i = 0;
    for (NSString *key in keys) {
        NSArray *section = [[model adItems] objectForKey:key];
        for (NSDictionary *cooler in section) {
            //cooler image
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(scrollViewPageWidth*i, 5, 75, 87)];
            __block UIActivityIndicatorView *activityIndicator;
            __weak UIImageView *weakImageView = imgView;
            NSURL *imageURL = [NSURL URLWithString:cooler[kCoolerImageKey]];
            [imgView setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
             {
                 if (!activityIndicator)
                 {
                     [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                     activityIndicator.center = weakImageView.center;
                     [activityIndicator startAnimating];
                 }
             }
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
             {
                 [activityIndicator removeFromSuperview];
                 activityIndicator = nil;
             }];
            [scrollView addSubview:imgView];
            imgView = nil;
            //cooler description;
            CustomLabel *descrLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(scrollViewPageWidth*i+78, 2, 210, 70)];
            descrLabel.numberOfLines = 3;
            descrLabel.textColor = [UIColor colorWithRed:0/255.0 green:51/255.0 blue:153/255.0 alpha:1.0];
            descrLabel.font = [UIFont fontWithName:descrLabel.font.familyName size:15];
            descrLabel.backgroundColor = [UIColor clearColor];
            descrLabel.text = cooler[kCoolerDescrKey];
//            [descrLabel sizeToFit];
            [scrollView addSubview:descrLabel];
            descrLabel = nil;
            //cooler cost
            CustomLabel *costLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(scrollViewPageWidth*i+78, 68, 200, 55)];
            costLabel.textColor = [UIColor colorWithRed:0/255.0 green:51/255.0 blue:153/255.0 alpha:1.0];
            costLabel.font = [UIFont fontWithName:costLabel.font.familyName size:15];
            costLabel.backgroundColor = [UIColor clearColor];
            costLabel.text = [NSString stringWithFormat:@"цена: %@",cooler[kCoolerCostKey]];
            [costLabel sizeToFit];
            [scrollView addSubview:costLabel];
            costLabel = nil;
            i++;
        }
    }
    scrollView.contentSize = CGSizeMake(scrollViewPageWidth*i, 70);
    _adLabel.text = keys[0];
    [self.view addSubview:scrollView];
}

#pragma mark - IBActions

- (IBAction)order:(id)sender { //Тап по кнопке "Заказать"
    [self performSegueWithIdentifier:@"Order" sender:self];
}

@end
