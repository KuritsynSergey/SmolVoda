//
//  SVHTMLParser.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 15.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "Keys.h"
#import "SVHTMLParser.h"
#import "HTMLParser.h"
#import "PriceXMLParser.h"
#import "SellPointsXMLParser.h"
#import "AdXMLParser.h"

@interface SVHTMLParser ()

@property (strong, nonatomic) HTMLParser *parser;

@end

@implementation SVHTMLParser

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        NSError *error = nil;
        _parser = [[HTMLParser alloc] initWithContentsOfURL:url error:&error];
        if (error)
            return nil;
    }
    return self;
}

- (NSDictionary*)parsePrice {
    @autoreleasepool {
        PriceXMLParser *priceParserDelegate = [[PriceXMLParser alloc] init];
//        NSURL *url = [NSURL URLWithString:@"http://www.smolvoda.ru/Price.xml"];
//        NSXMLParser *priceParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Price" ofType:@"xml"];
        NSXMLParser *priceParser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:path]];
        priceParser.delegate = priceParserDelegate;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if ([priceParser parse]) {
            NSMutableArray *outputArray = priceParserDelegate.outputArray;
            NSNumber *number = [outputArray objectAtIndex:[outputArray count]-1];
            [dict setValue:number forKey:kTarePriceKey];
            [outputArray removeObjectAtIndex:[outputArray count]-1];
            [dict setValue:outputArray forKey:kPriceListKey];
            return dict;
        }
        else
            return nil;
    }
    
}

- (NSArray*)parseSellPoints {
    @autoreleasepool {
        SellPointsXMLParser *sellPointsParserDelegate = [[SellPointsXMLParser alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SellPoints" ofType:@"xml"];
        NSXMLParser *sellPointsParser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:path]];
        sellPointsParser.delegate = sellPointsParserDelegate;
        if ([sellPointsParser parse])
            return [NSArray arrayWithArray:sellPointsParserDelegate.outputArray];
        else
            return nil;
    }
}

- (NSDictionary*)parseAd {
    @autoreleasepool {
        AdXMLParser *adXMLParserDelegate = [[AdXMLParser alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Coolers" ofType:@"xml"];
        NSXMLParser *adParser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:path]];
        adParser.delegate = adXMLParserDelegate;
        if ([adParser parse])
            return [NSDictionary dictionaryWithDictionary:adXMLParserDelegate.outputDictionary];
        else
            return nil;
    }
    /*
    NSError *error = nil;
    NSString *URLString = @"http://www.smolvoda.ru";
    NSMutableDictionary *catalog = [[NSMutableDictionary alloc] init]; //полный каталог
    NSMutableArray *catalogArray = [[NSMutableArray alloc] init]; //раздел каталога, содержащий однотипные кулеры
    NSMutableDictionary *item; //отдельный кулер
    NSString *description; //название кулера
    NSString *imageLink; //ссылка на изображение
    NSString *cost; //цена
    //Кулеры настольные
    HTMLParser *parser = [[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://smolvoda.ru/katalog-produktsii/kulery-nastolnye/kulery-nastolnye-s-kompressornym-okhlazhdeniem"] error:&error];
    HTMLNode *node = [[parser body] findChildOfClass:@"items-leading"];
    description = [[node findChildTag:@"a"] contents];
    imageLink = [URLString stringByAppendingString:[[node findChildTag:@"img"] getAttributeNamed:@"src"]];
    cost = [[node findChildTag:@"p"] contents];
    item = [[NSMutableDictionary alloc] initWithObjectsAndKeys:description, kCoolerDescrKey, imageLink, kCoolerImageKey, cost, kCoolerCostKey, nil];
    [catalogArray addObject:item];
    NSLog(@"%@",item);
    item = nil;*/
}

@end