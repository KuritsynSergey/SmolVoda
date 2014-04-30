//
//  AdXMLParser.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 03.02.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "AdXMLParser.h"
#import "Keys.h"

@interface AdXMLParser () {
    NSMutableString *currentElementValue; // an ad hoc string to hold element value
    NSString *currentSection;
    NSMutableDictionary *cooler;
    NSMutableArray *section;
}

@end

@implementation AdXMLParser

- (id)init {
    if (self = [super init]) {
        @autoreleasepool {
            _arrayForTitles = [[NSMutableArray alloc] init];
            _arrayForItems = [[NSMutableArray alloc] init];
            _outputDictionary = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"section"]) {
        section = [[NSMutableArray alloc] init];
//        [_arrayForTitles addObject:[attributeDict objectForKey:@"title"]];
        currentSection = [[NSString  alloc] initWithString:[attributeDict objectForKey:@"title"]];
    }
    if ([elementName isEqualToString:@"item"])
        cooler = [[NSMutableDictionary alloc] init];
    currentElementValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (cooler) {
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
    if ([elementName isEqualToString:@"coolers"])
        return;
    if ([elementName isEqualToString:@"section"]) {
        [_outputDictionary setObject:section forKey:currentSection];
        section = nil;
        currentSection = nil;
    } else if (cooler) {
        NSArray *brokenStrings = [currentElementValue componentsSeparatedByCharactersInSet:[NSCharacterSet controlCharacterSet]];
        if ([elementName isEqualToString:@"item"]) {
            // We are done with item entry – add the parsed item to array
            [section addObject:cooler];
            cooler = nil;
        }
        else if ([elementName isEqualToString:@"description"])
            [cooler setObject:brokenStrings[0] forKey:kCoolerDescrKey]; //possible risk!
        else if ([elementName isEqualToString:@"image"])
            [cooler setObject:brokenStrings[0] forKey:kCoolerImageKey];
        else if ([elementName isEqualToString:@"price"])
            [cooler setObject:brokenStrings[0] forKey:kCoolerCostKey];
    }
}

@end
