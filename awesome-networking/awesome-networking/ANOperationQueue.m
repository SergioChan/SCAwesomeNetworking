//
//  ANOperationQueue.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ANOperationQueue.h"

@implementation ANOperationQueue

+ (ANOperationQueue *) sharedInstance
{
    static dispatch_once_t  onceToken;
    static ANOperationQueue * sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ANOperationQueue alloc] init];
        sharedInstance.requestSet = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

/**
 *  根据指定的operationId从队列中取消该请求
 *
 *  @param operationId 操作的主键标识
 *
 *  @return 布尔值，代表是否成功执行
 */
- (BOOL)cancelOperationByOperationId:(NSInteger)operationId
{
    return NO;
}

- (BOOL)cacheOperationByOperationId:(NSInteger)operationId
{
    return NO;
}

- (NSArray *)getAllOperations
{
    return nil;
}

- (BOOL)cacheAllOperation
{
    return NO;
}

- (BOOL)cancelAllOperation
{
    return NO;
}

@end
