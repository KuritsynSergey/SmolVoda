//
//  LoginViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 07.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "LoginViewController.h"
#import "GeneralViewController.h"
#import "MainLogic.h"
#import "Keys.h"

@interface LoginViewController () {
    BOOL legalEntity;
}

@end

@implementation LoginViewController

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
    
    _centralScrollView.contentSize = _centralScrollView.frame.size;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [_centralScrollView addGestureRecognizer:tgr];
    [self.view addGestureRecognizer:tgr];
    
    legalEntity = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    NSDictionary *user = [[MainLogic shared] loadLastUser]; //загружаем последнего пользователя
    if (user) { //берем его данные
        _phoneTextField.text = [user objectForKey:kPhoneNumberKey];
        NSArray *name = [[user objectForKey:kNameKey] componentsSeparatedByString:@" "];
        @try {
            _lastNameTextField.text = [name[0] capitalizedString];
            _nameTextField.text = [name[1] capitalizedString];
            _patronymicTextField.text = [name[2] capitalizedString];
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@",exception);
        }
        legalEntity = [[user objectForKey:kLegalEntityKey] boolValue];
        [self imageForCheckbox];
    }
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

- (void)imageForCheckbox { //смена картинки на кнопке "юр.лицо"
    if (!legalEntity)
        [_checkboxButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    else
        [_checkboxButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (IBAction)tapNextButton:(id)sender { //передача управления следующему полю ввода по нажатию на кнопку Done/Next клавиатуры
    switch ([sender tag]) {
        case 1:
            [_nameTextField becomeFirstResponder];
            break;
        case 2:
            [_patronymicTextField becomeFirstResponder];
            break;
        case 3:
            [_phoneTextField becomeFirstResponder];
            break;
        default:
            [_lastNameTextField resignFirstResponder];
            [_nameTextField resignFirstResponder];
            [_patronymicTextField resignFirstResponder];
            [_phoneTextField resignFirstResponder];
            break;
    }
}

- (IBAction)formatPhoneNumber:(UITextField *)sender {
    NSString* totalString = sender.text;
    if (!([totalString isEqualToString:@""] || totalString == nil)) {
        sender.text = [[MainLogic shared] formatPhoneNumber:totalString];
    }
}

- (IBAction)checkboxTapped:(id)sender{ //обработка тапа по кнопке "юр.лицо"
    legalEntity = !legalEntity;
    [self imageForCheckbox];
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

- (IBAction)goNext:(id)sender {
    if ([self inputIsValid]) {
        NSString *name = [NSString stringWithFormat:@"%@ %@ %@",_lastNameTextField.text,_nameTextField.text,_patronymicTextField.text];
        [[MainLogic shared] saveUserWithName:name phoneNumber:_phoneTextField.text isLegalEntity:legalEntity];
        [self performSegueWithIdentifier:@"Confirm" sender:self];
    }
}

#pragma mark - Custom Methods

- (void)backgroundTap:(id)sender { //Убираем клавиатуру, если пользователь тапнул за пределами текстовых полей
    [_lastNameTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
    [_patronymicTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
}


- (BOOL)inputIsValid { //проверка валидности введенных данных; если данные не верны, то указывается, в каком поле пользователь допустил ошибку
    MainLogic *logic = [MainLogic shared];
    if ([logic isValidPhoneNumber:_phoneTextField.text]
        && !([_nameTextField.text isEqualToString:@""] || _nameTextField.text == nil)
        && !([_lastNameTextField.text isEqualToString:@""] || _lastNameTextField.text == nil))
        return YES;
    NSString *messageString = [NSString string];
    if ([_lastNameTextField.text isEqualToString:@""] || _lastNameTextField.text == nil)
        messageString = [messageString stringByAppendingString:@"Не введена фамилия.\n"];
    if ([_nameTextField.text isEqualToString:@""] || _nameTextField.text == nil)
        messageString = [messageString stringByAppendingString:@"Не введено имя.\n"];
    if (![logic isValidPhoneNumber:_phoneTextField.text])
        messageString = [messageString stringByAppendingString:@"Неверный формат номера телефона.\n"];
    messageString = [messageString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка данных"
                                                        message:messageString
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    return NO;
}

- (void)registerForKeyboardNotifications { //регистрация на уведомления от клавиатуры
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification { //Увеличиваем длину контента scrollView, если была вызвана клавиатура
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        if (_centralScrollView.contentSize.height == _centralScrollView.frame.size.height) {
            CGSize size = _centralScrollView.contentSize;
            size.height += 90;
            _centralScrollView.contentSize = size;
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification { //Возвращаем длину контента scrollView в исходное значение
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        [_centralScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:0.5f];
            dispatch_async(dispatch_get_main_queue(), ^{
                CGSize size = _centralScrollView.contentSize;
                size.height -= 90;
                _centralScrollView.contentSize = size;
            });
        });
    }
}

@end
