//
//  ANOperationQueue.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRequest.h"
#import "ANManager.h"

@interface ANOperationQueue : NSOperationQueue

@property (nonatomic, strong) NSMutableDictionary *requestSet;

/**
 *  根据指定的operationId从队列中取消该请求
 *
 *  @param operationId 操作id
 *
 *  @return 是否成功执行的布尔值
 */
- (BOOL)cancelOperationByOperationId:(NSInteger)operationId;

/**
 *  根据操作id缓存操作
 *
 *  @param operationId 操作id
 *
 *  @return 是否成功执行的布尔值
 */
- (BOOL)cacheOperationByOperationId:(NSInteger)operationId;

/**
 *  获取全部操作对象
 *
 *  @return 操作对象数组
 */
- (NSArray *)getAllOperations;

/**
 *  获取队列的实例
 *
 *  @return 队列
 */
+ (ANOperationQueue *) sharedInstance;

/**
 *  缓存队列中的所有操作
 *
 *  @return 是否成功执行的布尔值
 */
- (BOOL)cacheAllOperation;

/**
 *  根据操作的id删除缓存的请求
 *
 *  @param operationId 操作id
 */
- (void)removeRequestByOperationId:(NSInteger)operationId;

/**
 *  取消队列中的所有操作
 *
 *  @return 是否成功执行的布尔值
 */
- (BOOL)cancelAllOperation;

/**
 *  往队列中添加请求
 *
 *  @param req 请求对象
 */
- (void)addRequest:(ANRequest *)req;
@end
