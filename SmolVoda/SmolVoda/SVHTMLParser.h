//
//  SVHTMLParser.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 15.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVHTMLParser : NSObject

- (id)initWithURL:(NSURL*)url;
- (NSDictionary*)parseAd;
- (NSDictionary*)parsePrice;
- (NSArray*)parseSellPoints;

@end
