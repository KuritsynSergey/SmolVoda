//
//  PriceXMLParser.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 15.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "Keys.h"
#import "PriceXMLParser.h"

@interface PriceXMLParser () {
    NSMutableString *currentElementValue; // an ad hoc string to hold element value
    NSMutableDictionary *priceItem;
    NSNumber *tare;
}

//@property (strong, nonatomic) FeedItem *tempItem;

@end

@implementation PriceXMLParser


- (id)init {
    if (self = [super init]) {
        @autoreleasepool {
            _outputArray = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"listitem"] || [elementName isEqualToString:@"tareprice"])
        priceItem = [[NSMutableDictionary alloc] init];
    currentElementValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (priceItem || tare) {
        if (!currentElementValue) {
            // init the ad hoc string with the value
            currentElementValue = [[NSMutableString alloc] initWithString:string];
        } else {
            // append value to the ad hoc string
            [currentElementValue appendString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"pricelist"])
        return;
    if (priceItem) {
        if ([elementName isEqualToString:@"listitem"]) {
            // We are done with item entry – add the parsed item
            // object to our price array
            [_outputArray addObject:priceItem];
            // release object
            priceItem = nil;
        }
        else if ([elementName isEqualToString:@"minquantity"])
            [priceItem setObject:[NSNumber numberWithInteger:[currentElementValue integerValue]] forKey:kMinQuantityKey];
        else if ([elementName isEqualToString:@"maxquantity"])
            [priceItem setObject:[NSNumber numberWithInteger:[currentElementValue integerValue]] forKey:kMaxQuantityKey];
        else if ([elementName isEqualToString:@"price"])
            [priceItem setObject:[NSNumber numberWithInteger:[currentElementValue integerValue]] forKey:kPriceKey];
    }
    if ([elementName isEqualToString:@"tareprice"]) {
        [_outputArray addObject:[NSNumber numberWithInteger:[currentElementValue integerValue]]];
//        [priceItem setObject:[NSNumber numberWithInteger:[currentElementValue integerValue]] forKey:kTarePriceKey];
//        [_outputArray addObject:priceItem];
        priceItem = nil;
    }
}

@end
