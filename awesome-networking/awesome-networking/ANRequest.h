//
//  ANRequest.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANHeader.h"
#import "ANOperation.h"
#import "AFHTTPRequestOperation.h"

@interface ANRequest : NSObject
{
    NSInteger category;
    NSInteger tag;
    ANOperation *operation;
    NSDictionary *context;
}

/**
 *  分类
 */
@property(nonatomic, assign) NSInteger category;

/**
 *  特殊标识
 */
@property(nonatomic, assign) NSInteger tag;

/**
 *  基本网络请求操作
 */
@property(nonatomic, strong) ANOperation *operation;

/**
 *  扩展字典
 */
@property(nonatomic, strong) NSDictionary *context;

- (instancetype)initWithOperation:(AFHTTPRequestOperation *)oper
                      andCategory:(NSInteger)category;
@end
