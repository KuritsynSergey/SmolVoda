//
//  ConfirmViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 19.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "ConfirmViewController.h"
#import "Keys.h"
#import "MainLogic.h"

@interface ConfirmViewController () {
    BOOL elevator;
}

@property (strong, nonatomic) UIPickerView *timePicker;
@property (strong, nonatomic) UIDatePicker *datePicker;

@property (strong, nonatomic) NSDate *deliveryDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation ConfirmViewController

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
    
    _backgroundImageView.image = [UIImage imageNamed:@"ConfirmBackground.png"];
    _centralScrollView.contentSize = _centralScrollView.frame.size;
    _centralScrollView.backgroundColor = [UIColor redColor];
    if ([UIScreen mainScreen].bounds.size.height > 480) {
        CGRect frame = _centralScrollView.frame;
        frame.size.height += 70;
        _centralScrollView.frame = frame;
    }
    NSDictionary *order = [[MainLogic shared] currentOrder];
    int quantity = [[order objectForKey:kBottlesKey] intValue];
    int price = [[order objectForKey:kPriceKey] intValue];
    int tare = [[order objectForKey:kReturnKey] intValue];
    _descriptionLabel.text = [NSString stringWithFormat:@"Вода артезианская «Ключ здоровья»\nКоличество: %d, возвратная тара: %d\nСтоимость: %d руб.",quantity,tare,price];
    elevator = NO;
    
    NSDictionary *dict = [[MainLogic shared] loadLastOrder];
    if (dict != nil) {
        _streetTextField.text = dict[kStreetKey];
        _houseTextField.text = dict[kHouseKey];
        _flatTextField.text = dict[kFlatKey];
        _floorTextField.text = dict[kFloorKey];
        _porchTextField.text = dict[kPorchKey];
        elevator = [dict[kElevatorKey] boolValue];
        [self imageForCheckbox];
    }
    dict = nil;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker sizeToFit];
    _datePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _datePicker.locale = [NSLocale currentLocale];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    _datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:1*24*60*60];
    _datePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:kDaysForOrder*24*60*60];
    [_datePicker addTarget:self action:@selector(datePickerDidScroll) forControlEvents:UIControlEventValueChanged];
    
    _dateTextField.inputView = _datePicker;
    
    _timePicker = [[UIPickerView alloc] init];
    [_timePicker sizeToFit];
    _timePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _timePicker.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    _timePicker.tag = 1;
    _timePicker.delegate = self;
    _timePicker.dataSource = self;
    _timePicker.showsSelectionIndicator = YES;
    
    _timeTextField.inputView = _timePicker;
    
    // create a done view + done button, attach to it a doneClicked action, and place it in a toolbar as an accessory input view...
    // Prepare done button
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
//    keyboardDoneButtonView.alpha = 0.1f;
//    keyboardDoneButtonView.backgroundColor = [UIColor redColor];
//    keyboardDoneButtonView.tintColor = [UIColor clearColor];
//    keyboardDoneButtonView.barStyle = UIBarStyleDefault;
    keyboardDoneButtonView.translucent = NO;
//    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(doneTapped:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flex, doneButton, nil]];
    
    // Plug the keyboardDoneButtonView into the text field...
    _timeTextField.inputAccessoryView = keyboardDoneButtonView;
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    self.backgroundImageView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    [self.backgroundImageView addGestureRecognizer:tgr];
    [self.view addGestureRecognizer:tgr];
    [_centralScrollView addGestureRecognizer:tgr];
    tgr = nil;
    
//    [[MainLogic shared] setConfirmDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerForKeyboardNotifications]; //подписываемся на уведомления от клавиатуры
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //отписываемся от уведомлений клавиатуры
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)backgroundTapped:(id)sender { //пользователь тапнул за пределами текстовых полей -- скрываем клавиатуру
    if ([_dateTextField isFirstResponder] || [_timeTextField isFirstResponder]) {
        [_dateTextField resignFirstResponder];
        [_timeTextField resignFirstResponder];
        [self updateTextFields];
    }
    [_streetTextField resignFirstResponder];
    [_houseTextField resignFirstResponder];
    [_flatTextField resignFirstResponder];
    [_floorTextField resignFirstResponder];
    [_porchTextField resignFirstResponder];
}

- (void)updateTextFields { //обновляем значения текстовых полей с методами ввода через использование UIPicker
    NSDate *date = [_datePicker date];
    _dateTextField.text = [_dateFormatter stringFromDate:date];
    _deliveryDate = date;
    _timeTextField.text = [[MainLogic shared] deliveryTimes][[_timePicker selectedRowInComponent:0]];
    //блокируем поле времени, если
    //а) заказ на воскресенье
    //б) заказ на субботу в пятницу вечером
    //в) заказ на субботу в субботу
    if (([[MainLogic shared] weekdayForDate:_deliveryDate] == 1) ||
        ([[MainLogic shared] weekdayForDate:_deliveryDate] == 7 && (([[MainLogic shared] weekdayForDate:[NSDate date]] == 6 && [[MainLogic shared] currentHour] >= 17) || [[MainLogic shared] weekdayForDate:[NSDate date]] == 7))) {
        _timeTextField.text = @"";
        _timeTextField.enabled = NO;
    } else {
        _timeTextField.enabled = YES;
    }
}

- (void)datePickerDidScroll { //если пользователь прокрутил UIPicker с датами, то обновляем UIPicker с временами доставки и обновляем поля
    [self updateTextFields];
    [_timePicker reloadComponent:0];
}

- (void)doneTapped:(id)sender { //нажата кнопка "Готово" на UIToolbar, прикрепленного к UIPicker с временами доставки
    [self updateTextFields];
    [_timeTextField resignFirstResponder];
}

- (BOOL)inputIsValid { //проверка валидности введенных данных -- полностью заполнены поля адреса доставки + дата и время доставки
    if (!([_streetTextField.text isEqualToString:@""] || _streetTextField.text == nil)
        && !([_houseTextField.text isEqualToString:@""] || _houseTextField.text == nil)
        && !([_flatTextField.text isEqualToString:@""] || _flatTextField.text == nil)
        && !([_floorTextField.text isEqualToString:@""] || _floorTextField.text == nil)
        && !([_porchTextField.text isEqualToString:@""] || _porchTextField.text == nil)
        && !([_dateTextField.text isEqualToString:@""] || _dateTextField.text == nil)
        && !([_timeTextField.text isEqualToString:@""] || _timeTextField.text == nil))
        return YES;
    NSString *messageString = [NSString string];
    if ([_streetTextField.text isEqualToString:@""] || _streetTextField.text == nil || [_houseTextField.text isEqualToString:@""] || _houseTextField.text == nil ||
        [_flatTextField.text isEqualToString:@""] || _flatTextField.text == nil || [_floorTextField.text isEqualToString:@""] || _floorTextField.text == nil ||
        [_porchTextField.text isEqualToString:@""] || _porchTextField.text == nil)
        messageString = [messageString stringByAppendingString:@"Адрес введен не полностью.\n"];
    if ([_dateTextField.text isEqualToString:@""] || _dateTextField.text == nil)
        messageString = [messageString stringByAppendingString:@"Не введена дата.\n"];
    if ([_timeTextField.text isEqualToString:@""] || _timeTextField.text == nil)
        messageString = [messageString stringByAppendingString:@"Не введено время.\n"];
    messageString = [messageString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка данных"
                                                        message:messageString
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    alertView = nil;
    return NO;
}

- (void)imageForCheckbox { //смена картинки на галке "Лифт"
    if (!elevator)
        [_elevatorButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    else
        [_elevatorButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
}

- (void)registerForKeyboardNotifications { //подписка на уведомления от клавиатуры
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        if (_centralScrollView.contentSize.height == _centralScrollView.frame.size.height) {
            CGSize size = _centralScrollView.contentSize;
            size.height += 70;
            _centralScrollView.contentSize = size;
        }
        if ([_dateTextField isFirstResponder] || [_timeTextField isFirstResponder]) {
            [_centralScrollView setContentOffset:CGPointMake(0, 70) animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        [_centralScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:0.5f];
            dispatch_async(dispatch_get_main_queue(), ^{
                CGSize size = _centralScrollView.contentSize;
                size.height -= 70;
                _centralScrollView.contentSize = size;
            });
        });
    }
}

- (void)checkOrderSendStatus:(NSTimer*)sender {
    MainLogic *model = [MainLogic shared];
    if (![model mailSendingFinished])
        return;
    [sender invalidate];
    [_HUD hide:YES];
    if (![model mailSent]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка подключения"
                                                            message:@"Возможно администратор Вашей сети блокирует некоторые типы трафика."
                                                           delegate:nil
                                                  cancelButtonTitle:@"ОК"
                                                  otherButtonTitles: nil];
        [alertView show];
        alertView = nil;
    } else {
        NSString *message;
        //получаем текущее время (текущий час)
        int weekday = [model weekdayForDate:[NSDate date]];
        int currentHour = [model currentHour];
        if (weekday == 7 || weekday == 1 || (weekday == 6 && currentHour >=17))
            message = @"По указанному номеру телефона c Вами свяжется оператор.\nОбратите внимание: заказ будет обработан в понедельник в 9:00";
        else if (currentHour < 9 || currentHour >=17)
            message = @"По указанному номеру телефона c Вами свяжется оператор.\nЗаказ будет обработан в 9:00";
        else
            message = @"В ближайшее время по указанному номеру телефона с Вами свяжется оператор";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Заказ принят"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"ОК"
                                                  otherButtonTitles: nil];
        alertView.tag = 4;
        [alertView show];
        alertView = nil;
    }
}

#pragma mark - UIPickerView Data Source

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger number = 0;
    switch (pickerView.tag) {
        case 1:
            number = 4;
            if (_deliveryDate != nil) {
                if ([[MainLogic shared] weekdayForDate:[NSDate date]] == 7)
                    number = 2;
            }
            break;
        case 2:
        default:
            break;
    }
    
    return number;
}

#pragma mark - UIPickerView Delegate


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *result;
    switch (pickerView.tag) {
        case 1:
            result = [[MainLogic shared] deliveryTimes][row];
            break;
        default:
            break;
    }
    return result;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    switch (alertView.tag) {
        case 3:
            if (buttonIndex == [alertView cancelButtonIndex]){
                //нажата отмена -- ничего не делаем
            }else{
                [[[MainLogic shared] currentOrder] addEntriesFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                             _dateTextField.text,kDateKey,
                                                                             _timeTextField.text,kTimeKey,
                                                                             _streetTextField.text,kStreetKey,
                                                                             _houseTextField.text,kHouseKey,
                                                                             _flatTextField.text,kFlatKey,
                                                                             _floorTextField.text,kFloorKey,
                                                                             _porchTextField.text,kPorchKey,
                                                                             [NSNumber numberWithBool:elevator],kElevatorKey,nil]];
                _HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:_HUD];
                
                _HUD.delegate = self;
                _HUD.labelText = @"Отправка";
                _HUD.minSize = CGSizeMake(135.f, 135.f);
                
                [_HUD show:YES];
                [[MainLogic shared] sendOrder];
                [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(checkOrderSendStatus:)
                                               userInfo:nil
                                                repeats:YES];
                /*
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [NSThread sleepForTimeInterval:5.0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_HUD hide:YES];
                    });
                });*/
                
            }
            break;
        case 4:
            if (buttonIndex == [alertView cancelButtonIndex])
                [self goBack:self];
            break;
        default:
            break;
    }
}

#pragma mark - IBActions

- (IBAction)goBack:(id)sender { //Кнопка "Назад" -- анимация
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    //Если функция вызвана самим ConfirmViewController (через код -- в случае отправки заказа в компанию), необходимо определить, какому UIViewController необходимо сделать dismiss:
    //это зависит от того как мы попали в это окно -- через новый заказ, повторение последнего заказа или историю заказов
    NSString *way = [[MainLogic shared] wayToOrder];
    if (sender == self) {
        UIViewController *vc;
        if ([way isEqualToString:@"PersonData"])
            vc = self.presentingViewController.presentingViewController.presentingViewController;
        else if ([way isEqualToString:@"Last"])
            vc = self.presentingViewController.presentingViewController.presentingViewController.presentingViewController;
        else if ([way isEqualToString:@"History"])
            vc = self.presentingViewController.presentingViewController.presentingViewController.presentingViewController.presentingViewController;
        [vc dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (IBAction)checkout:(id)sender { //Кнопка "Оформить"
    if ([self inputIsValid] && [[MainLogic shared] internetActive]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Подтверждение"
                                                            message:@"Подтвердите корректность Вашего заказа."
                                                           delegate:self
                                                  cancelButtonTitle:@"Отмена"
                                                  otherButtonTitles:@"ОК",nil];
        alertView.tag = 3;
        [alertView show];
        alertView = nil;
    } else if (![[MainLogic shared] internetActive]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка подключения"
                                                            message:@"Для оформления заказа необходимо подключение к сети Интернет."
                                                           delegate:nil
                                                  cancelButtonTitle:@"ОК"
                                                  otherButtonTitles: nil];
        [alertView show];
        alertView = nil;
    }
}

- (IBAction)dateTextFieldExit:(id)sender { //Обновление полей даты и времени в случае выхода из редактирования поля даты доставки
    [self updateTextFields];
}

- (IBAction)checkboxTapped:(id)sender { //обработка тапа по кнопке "Лифт"
    elevator = !elevator;
    [self imageForCheckbox];
}

@end
