//
//  ANResponseSerializer.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/30.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLResponseSerialization.h"

@interface ANResponseSerializer : AFHTTPResponseSerializer

/**
 Creates and returns a serializer with default configuration.
 */
+ (instancetype)serializer;

/**
 Options for reading the response JSON data and creating the Foundation objects. For possible values, see the `NSJSONSerialization` documentation section "NSJSONReadingOptions". `0` by default.
 */
@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

/**
 Whether to remove keys with `NSNull` values from response JSON. Defaults to `NO`.
 */
@property (nonatomic, assign) BOOL removesKeysWithNullValues;

/**
 Creates and returns a JSON serializer with specified reading and writing options.
 
 @param readingOptions The specified JSON reading options.
 */
+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;

@end
