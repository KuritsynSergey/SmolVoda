//
//  SellPointsXMLParser.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 23.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "Keys.h"
#import "SellPointsXMLParser.h"

@interface SellPointsXMLParser () {
    NSMutableString *currentElementValue; // an ad hoc string to hold element value
    NSMutableDictionary *sellPoint;
}

@end

@implementation SellPointsXMLParser

- (id)init {
    if (self = [super init]) {
        @autoreleasepool {
            _outputArray = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"sellpoint"])
        sellPoint = [[NSMutableDictionary alloc] init];
    currentElementValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (sellPoint) {
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
    if ([elementName isEqualToString:@"splist"])
        return;
    if (sellPoint) {
        if ([elementName isEqualToString:@"sellpoint"]) {
            // We are done with item entry – add the parsed item
            // object to our SellPoints array
            [_outputArray addObject:sellPoint];
            // release object
            sellPoint = nil;
        }
        else if ([elementName isEqualToString:@"description"])
            [sellPoint setObject:currentElementValue forKey:kDescriptionKey];
        else if ([elementName isEqualToString:@"latitude"])
            [sellPoint setObject:[NSNumber numberWithFloat:[currentElementValue floatValue]] forKey:kLatitudeKey];
        else if ([elementName isEqualToString:@"longitude"])
            [sellPoint setObject:[NSNumber numberWithFloat:[currentElementValue floatValue]] forKey:kLongitudeKey];
    }
}

@end
