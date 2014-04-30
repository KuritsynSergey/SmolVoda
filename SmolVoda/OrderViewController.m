//
//  OrderViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 11.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "OrderViewController.h"
#import "Keys.h"
#import "MainLogic.h"

@interface OrderViewController () {
    int bottlesQuantity;
    int tareQuantity;
    int price;
}

@end

@implementation OrderViewController

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
    _backgroundImageView.image = [UIImage imageNamed:@"OrderBackground.png"];
    
    bottlesQuantity = 1;
    tareQuantity = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    if (bottlesQuantity == 1)
        _minusBottleButton.enabled = NO;
    else
        _minusBottleButton.enabled = YES;
    if (tareQuantity == 0)
        _minusTareButton.enabled = NO;
    else
        _minusTareButton.enabled = YES;
    [self updateLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender { //Предотвращение segue по кнопке "Последний заказ", если еще не было ни одного заказа
    if ([identifier isEqualToString:@"Last"] && [[MainLogic shared] loadLastOrder] == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Вы еще не сделали ни одного заказа"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
        alertView = nil;
        return NO;
    }
    else
        return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { //подготовка к переходу на следующий экран -- сохраняем, куда именно перешел пользователь для правильной дальнейшней работы
    if ([segue.identifier isEqualToString:@"PersonData"]) {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:bottlesQuantity], kBottlesKey,
                              [NSNumber numberWithInt:tareQuantity], kReturnKey,
                              [NSNumber numberWithInt:price], kPriceKey, nil];
        [[MainLogic shared] setCurrentOrder:[NSMutableDictionary dictionaryWithDictionary:dict]];
        dict = nil;
    } else if ([segue.identifier isEqualToString:@"History"]) {
        [[MainLogic shared] loadAllOrders];
    }
    [[MainLogic shared] setWayToOrder:segue.identifier];
}

- (IBAction)minusBottle:(UIButton *)sender { //минус бутыль
    bottlesQuantity--;
    if (tareQuantity > 0) {
        tareQuantity--;
    }
    if (bottlesQuantity == 1)
        _minusBottleButton.enabled = NO;
    [self updateLabels];
}

- (IBAction)plusBottle:(UIButton *)sender { //плюс бутыль
    bottlesQuantity++;
    tareQuantity++;
    _minusBottleButton.enabled = YES;
    _minusTareButton.enabled = YES;
    [self updateLabels];
}

- (IBAction)minusTare:(UIButton *)sender { //минус единица возвратной тары
    tareQuantity--;
    if (tareQuantity == 0)
        _minusTareButton.enabled = NO;
    [self updateLabels];
}

- (IBAction)plusTare:(UIButton *)sender { //плюс единица возвратной тары
    tareQuantity++;
    _minusTareButton.enabled = YES;
    [self updateLabels];
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

- (void)updateLabels { //Перерасчет суммарной стоимости заказа, происходит при любых изменениях количества бутылей и единиц возвратной тары
    price = [[MainLogic shared] priceByBottles:bottlesQuantity andTare:tareQuantity];
    _bottlesLabel.text = [NSString stringWithFormat:@"Количество бутылей: %d",bottlesQuantity];
    _tareLabel.text = [NSString stringWithFormat:@"Возвращаемая тара: %d",tareQuantity];
    _priceLabel.text = [NSString stringWithFormat:@"Стоимость: %d рублей",price];
}

@end
