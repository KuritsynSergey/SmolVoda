//
//  LastOrderViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 19.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "LastOrderViewController.h"
#import "MainLogic.h"
#import "Keys.h"

@interface LastOrderViewController ()

@property (weak, nonatomic) NSDictionary *order;

@end

@implementation LastOrderViewController

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
    
    if (![[MainLogic shared] orders] && [_selectedOrder intValue] == 0)
        _order = [[MainLogic shared] loadLastOrder];
    else
        _order = [[[MainLogic shared] orders] objectAtIndex:[_selectedOrder intValue]];
    _streetLabel.text = [_order objectForKey:kStreetKey];
    _houseLabel.text = [_order objectForKey:kHouseKey];
    _flatLabel.text = [_order objectForKey:kFlatKey];
    _floorLabel.text = [_order objectForKey:kFloorKey];
    _porchLabel.text = [_order objectForKey:kPorchKey];
    NSString *imageName = [[_order objectForKey:kElevatorKey] boolValue] ? @"checkbox_checked.png" : @"checkbox_unchecked.png";
    _checkboxImageView.image = [UIImage imageNamed:imageName];
    _dateLabel.text = [_order objectForKey:kDateKey];
    _timeLabel.text = [_order objectForKey:kTimeKey];
    int quantity = [[_order objectForKey:kBottlesKey] intValue];
    int price = [[_order objectForKey:kPriceKey] intValue];
    int tare = [[_order objectForKey:kReturnKey] intValue];
    _descriptionLabel.text = [NSString stringWithFormat:@"Вода артезианская «Ключ здоровья»\nКоличество: %d, Возвратная тара: %d\nСтоимость: %d руб.",quantity,tare,price];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { //подготовка к переходу на следующий экран -- делаем загруженный последний заказ текущим
    if ([segue.identifier isEqualToString:@"RepeatOrder"]) {
        [[MainLogic shared] setCurrentOrder:[NSMutableDictionary dictionaryWithDictionary:_order]];
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
