//
//  MainLogic.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 03.11.13.
//  Copyright (c) 2013 Sergey Kuritsyn. All rights reserved.
//

#import <zlib.h>
#import "MainLogic.h"
#import "Keys.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "Reachability.h"
#import "SVHTMLParser.h"
#import <MailCore/MailCore.h>

@interface MainLogic ()

@property (strong, nonatomic) NSMutableArray *users;
@property int lastUserID;
@property int maxSavedOrders;

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation MainLogic

#pragma mark - Инициализация

+(MainLogic*)shared {
    static MainLogic *sharedInstance;
	@synchronized(self)	{
		if (!sharedInstance)
			sharedInstance = [[MainLogic alloc] init];
		return sharedInstance;
	}
	return sharedInstance;
}

- (id)init {
    if (self=[super init]) {
        NSDictionary *usersd = [NSDictionary dictionaryWithContentsOfFile:[self pathToFile:kUsersFile]]; //получаем список всех пользователей из файла
        if (usersd == nil) { //если получили пустой объект, то файл не сущесвует -- первый запуск приложения на устройстве
            _lastUserID = -1;
            _users = [[NSMutableArray alloc] init];
            NSLog(@"before file created");
        }
        else { //получаем номер пользователя, который осуществлял вход последним и список всех пользователей
            _lastUserID = [[usersd objectForKey:kLastUserID] integerValue];
            _users = [usersd objectForKey:kUsersKey];
        }
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
//        _priceList = [[NSArray alloc] init];
//        _orders = [[NSMutableArray alloc] init];
        
        //подписываем наш объект на изменения статуса сетевого подключения
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        NSString *remoteHostName = @"www.smolvoda.ru"; //имя хоста для проверки наличия связи с ним
        
        self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
        [self.hostReachability startNotifier];
        
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        
        self.wifiReachability = [Reachability reachabilityForLocalWiFi];
        [self.wifiReachability startNotifier];
        
        _maxSavedOrders = 10;
        
        _deliveryTimes = @[@"10:00-13:00",@"13:00-16:00",@"16:00-18:00",@"18:00-20:00"];
        //_keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"SmolVoda" accessGroup:nil];
    }
    return self;
}

#pragma mark - Reachability Methods

- (void) reachabilityChanged:(NSNotification *)note { //отслеживание наличия подключения к Интернет
    NetworkStatus internetStatus = [_internetReachability currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            break;
        }
    }
    
    NetworkStatus hostStatus = [_hostReachability currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            break;
        }
    }
}

#pragma mark - Работа с файлами

- (NSString*)pathToFile:(NSString*)file { //возвращает полный путь к указанному файлу
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:file];
    return filePath;
}

- (NSDictionary*)loadLastUser { //загрузка данных последнего пользователя
    if (_lastUserID == -1)  //если пользователей не было -- первый запуск приложения на устройстве
        return nil; //то возвращаем пустой объект -- объект, вызвавший этот метод, ответственнен за обработку такой ситуации
    return [_users objectAtIndex:_lastUserID]; //возвращаем словарь, содержащий данные последнего пользователя
}

- (void)saveUsersToFile { //сохраняет данные пользователя в файл
    NSDictionary *usersd = [NSDictionary dictionaryWithObjectsAndKeys:_users, kUsersKey, [NSNumber numberWithInt:_lastUserID], kLastUserID, nil];
    [usersd writeToFile:[self pathToFile:kUsersFile] atomically:YES];
}

- (void)addUser:(NSDictionary*)user { //добавляет данные нового пользователя
    [_users addObject:user];
    _lastUserID = [_users count] - 1;
    [self saveUsersToFile];
}

- (NSDictionary*)loadLastOrder { //загрузка последнего заказа
    [self loadAllOrders];
    if ([_orders count] != 0)
        return [_orders objectAtIndex:0];
    else
        return nil;
}

- (void)loadAllOrders { //загрузка всех предыдущих заказов
    _orders = [NSMutableArray arrayWithContentsOfFile:[self pathToFile:kOrdersFile]];
}

- (void)saveCurrentOrder { //добавление текущего заказа в историю
    //считываем файл Orders.plist file, добавляем текущий элемент в массив, удаляем последний элемент, если всего их больше 10 и записываем обратно в файл.
    [self loadAllOrders];
    if (_orders == nil)
        _orders = [[NSMutableArray alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *orderDate = [dateFormatter stringFromDate:[NSDate date]];
    [_currentOrder setObject:orderDate forKey:kOrderDateKey];
    [_orders insertObject:_currentOrder atIndex:0];
    if ([_orders count] >  _maxSavedOrders) {
        for (int i = _maxSavedOrders; i < [_orders count]; i++) {
            [_orders removeObjectAtIndex:i];
        }
    }
    [_orders writeToFile:[self pathToFile:kOrdersFile] atomically:YES];
    _orders = nil;
}

#pragma mark - Проверка и отправка данных пользователя

- (NSString*)formatPhoneNumber:(NSString *)number { //форматирование номера телефона
    if ([number length] == 5 || [number length] == 6) {
        NSString *thirdPart = [number substringWithRange:NSMakeRange([number length]-2, 2)];
        NSString *secondPart = [number substringWithRange:NSMakeRange([number length]-4, 2)];
        NSString *firstPart = [number substringToIndex:[number length]-4];
        return [NSString stringWithFormat:@"%@-%@-%@",firstPart,secondPart,thirdPart];
    }
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSError *aError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:number defaultRegion:@"RU" error:&aError];
    return [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatNATIONAL error:&aError];
}

- (BOOL)isValidPhoneNumber:(NSString *)checkString { //проверка валидности введенного номера
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSError *aError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:checkString defaultRegion:@"RU" error:&aError];
    return ([phoneUtil isValidNumber:myNumber]);
}

- (BOOL)isValidEmail:(NSString *)checkString { //проверка валидности введенного адреса e-mail
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)saveUserWithName:(NSString*)name phoneNumber:(NSString*)number isLegalEntity:(BOOL)legalEntity {
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:
                          number, kPhoneNumberKey,
                          [name lowercaseString], kNameKey,
                          [NSNumber numberWithBool:legalEntity], kLegalEntityKey, nil];
    int userID = [self indexOfUser:user];
    if (userID != -1) { //пользователь найден -- разрешаем вход и сохраняем
        _lastUserID = userID;
        [self saveUsersToFile];
    } else {
        [self addUser:user];
    }
}

- (int)indexOfUser:(NSDictionary*)user { //поиск пользователя в списке локально сохраненных пользователях; если пользователь найден, возвращает индекс, иначе -- возвращает значение -1
    for (NSDictionary *aUser in _users) {
        if ([aUser isEqualToDictionary:user])
            return [_users indexOfObject:user];
    }
    return -1;
}

- (void)sendMailTo:(NSString*)recepient withSubject:(NSString*)subject withContent:(NSString*)message { //отправка письма по SMTP (опирается на внешнюю библиотеку)
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.mail.ru";
    smtpSession.port = 465; //25, 587, 465
    smtpSession.username = @"noreply-smolvoda@mail.ru";
    smtpSession.password = @"1qaz2wsx";
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:@"Ключ здоровья"
                                                  mailbox:@"noreply-smolvoda@mail.ru"];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                mailbox:recepient];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:subject];
    [builder setHTMLBody:message];
    NSData *rfc822Data = [builder data];
    
    _mailSendingFinished = NO;
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            _mailSent = NO;
            NSLog(@"Error sending email: %@", error);
        } else {
            _mailSent = YES;
            NSLog(@"Successfully sent email to %@",recepient);
        }
        _mailSendingFinished = YES;
    }];
}

- (void)sendOrder { //Отправка сформированного заказа в компанию
    //sending...
    NSMutableString *message = [[NSMutableString alloc] init];
    NSString *messagePart;
    NSDictionary *user = [self loadLastUser];
    messagePart = [[user objectForKey:kNameKey] capitalizedString];
    [message appendString:[NSString stringWithFormat:@"<html><p>Пользователь: <b>%@</b>",messagePart]];
    if ([[user objectForKey:kLegalEntityKey] boolValue])
        [message appendString:@" (юридическое лицо)"];
    messagePart = [user objectForKey:kPhoneNumberKey];
    [message appendString:[NSString stringWithFormat:@"<p>Телефон: <b>%@</b>",messagePart]];
    messagePart = [_currentOrder objectForKey:kBottlesKey];
    [message appendString:[NSString stringWithFormat:@"<p>Количество бутылей с водой: <b>%@</b>",messagePart]];
    messagePart = [_currentOrder objectForKey:kReturnKey];
    [message appendString:[NSString stringWithFormat:@"<p>Количество возвратной тары: <b>%@</b>",messagePart]];
    messagePart = [_currentOrder objectForKey:kDateKey];
    [message appendString:[NSString stringWithFormat:@"<p>Дата доставки: <b>%@</b>",messagePart]];
    messagePart = [_currentOrder objectForKey:kTimeKey];
    [message appendString:[NSString stringWithFormat:@"<p>Время доставки: <b>%@</b>",messagePart]];
    messagePart = [[_currentOrder objectForKey:kElevatorKey] boolValue] ? @" есть" : @"а нет";
    messagePart = [NSString stringWithFormat:@"улица %@, д. %@, %@ подъезд, кв. %@, %@ этаж, лифт%@",
                   _currentOrder[kStreetKey],_currentOrder[kHouseKey],_currentOrder[kPorchKey],_currentOrder[kFlatKey],_currentOrder[kFloorKey],messagePart];
    [message appendString:[NSString stringWithFormat:@"<p>Адрес доставки: <b>%@</b></html>",messagePart]];
    [self sendMailTo:kRegistratorMail withSubject:@"Новый заказ" withContent:message];
    [self saveCurrentOrder];
}

#pragma mark - Загрузка данных с сайта www.smolvoda.ru

- (void)loadPrice { //загрузка прайс-листа
    if (!_priceList) {
        SVHTMLParser *parser = [[SVHTMLParser alloc] init];
        _priceList = [parser parsePrice];
        parser = nil;
    }
}

- (void)loadAd { //загрузка рекламы -- кулеры и аксессуары
    if (!_adItems) {
        SVHTMLParser *parser = [[SVHTMLParser alloc] init];
        _adItems = [parser parseAd];
        parser = nil;
    }
//    NSLog(@"%@",_adItems);
}

- (void)loadSellPoints { //загрузка данных о точках продаж
    if (!_sellPoints) {
        SVHTMLParser *parser = [[SVHTMLParser alloc] init];
        _sellPoints = [parser parseSellPoints];
        parser = nil;
    }
//    NSLog(@"%@",_sellPoints);
}

#pragma mark - Расчеты

- (int)priceByBottles:(int)bottles andTare:(int)tare { //расчет стоимости заказа на основе количества покупаемых бутылей и возвратной тары
    int price = 0;
    int priceB = 0;
    int priceT = [_priceList[kTarePriceKey] intValue];
    BOOL found = NO;
    int i = 0;
    do {
        NSDictionary *item = [[_priceList objectForKey:kPriceListKey] objectAtIndex:i];
        NSArray *tempArray = _priceList[kPriceListKey];
        if ((bottles >= [[item objectForKey:kMinQuantityKey] intValue] && bottles <= [[item objectForKey:kMaxQuantityKey] intValue]) || i == [tempArray count] - 1) {
            priceB = [[item objectForKey:kPriceKey] intValue]+priceT;
            found = YES;
        }
        i++;
    } while (!found);
    price = bottles*priceB - tare*priceT;
    return price;
}

- (int)currentHour { //Возвращает текущий час
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
    NSString *time = [_dateFormatter stringFromDate:[NSDate date]];
    NSRange range = [time rangeOfString:@":"];
    int hour = [[time substringToIndex:range.location] intValue];
//    NSRange range2 = {range.length, 2};
//    int munute = [[time substringWithRange:range2] intValue];
    [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return hour;
}

- (int)weekdayForDate:(NSDate*)date { //возвращает день недели по дате
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    int weekDay = [components weekday];
    [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
    return weekDay;
}

#pragma mark -

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _currentOrder = nil;
    _previousOrder = nil;
    _deliveryTimes = nil;
    _orders = nil;
    _priceList = nil;
    _users = nil;
    _wayToOrder = nil;
    _dateFormatter = nil;
}

@end
