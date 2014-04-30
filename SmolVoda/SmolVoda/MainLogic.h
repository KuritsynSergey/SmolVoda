//
//  MainLogic.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 03.11.13.
//  Copyright (c) 2013 Sergey Kuritsyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConfirmViewController;

@interface MainLogic : NSObject

@property BOOL internetActive;
@property BOOL hostActive;
//@property BOOL fullFunctionality;

@property (strong, nonatomic) NSMutableDictionary *currentOrder;
@property (strong, nonatomic) NSDictionary *previousOrder;
@property (strong, nonatomic) NSMutableArray *orders;
@property (strong, nonatomic) NSDictionary *priceList;
@property (strong, nonatomic) NSArray *deliveryTimes;
@property (strong, nonatomic) NSArray *sellPoints;

@property (strong, nonatomic) NSArray *adSections;
@property (strong, nonatomic) NSDictionary *adItems;

@property (strong, nonatomic) NSString *wayToOrder;

//@property (weak, nonatomic) ConfirmViewController *confirmDelegate;
@property BOOL mailSendingFinished;
@property BOOL mailSent;

+ (MainLogic*)shared;
- (NSDictionary*)loadLastUser;
- (NSString*)formatPhoneNumber:(NSString*)number;
- (BOOL)isValidPhoneNumber:(NSString*)checkString;
- (void)saveUserWithName:(NSString*)name phoneNumber:(NSString*)number isLegalEntity:(BOOL)legalEntity;
- (void)loadAd;
- (void)loadPrice;
- (void)loadSellPoints;
- (int)priceByBottles:(int)bottles andTare:(int)tare;
- (NSDictionary*)loadLastOrder;
- (void)loadAllOrders;
- (void)sendOrder;

- (int)currentHour;
- (int)weekdayForDate:(NSDate*)date;

@end
