//
//  ANOperation.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "ANHeader.h"

@interface ANOperation : AFHTTPRequestOperation

/**
 *  主键标识
 */
@property(nonatomic, assign) NSInteger operationId;

/**
 *  时间戳
 */
@property(nonatomic, strong) NSString *timestamp;


- (instancetype)initWithOperation:(AFHTTPRequestOperation *)op;
@end
