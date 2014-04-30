//
//  SellPointsXMLParser.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 23.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SellPointsXMLParser : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableArray *outputArray;

@end
