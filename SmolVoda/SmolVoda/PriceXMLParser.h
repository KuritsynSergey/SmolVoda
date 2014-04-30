//
//  PriceXMLParser.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 15.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PriceXMLParser : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableArray *outputArray;

@end
