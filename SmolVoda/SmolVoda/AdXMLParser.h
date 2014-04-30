//
//  AdXMLParser.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 03.02.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdXMLParser : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableArray *arrayForTitles;
@property (strong, nonatomic) NSMutableArray *arrayForItems;
@property (strong, nonatomic) NSMutableDictionary *outputDictionary;

@end
