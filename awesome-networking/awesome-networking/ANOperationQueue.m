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
        sharedInstance.maxConcurrentOperationCount = 1;
        sharedInstance.requestSet = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (BOOL)cancelOperationByOperationId:(NSInteger)operationId
{
    NSString *operationKey = [NSString stringWithFormat:@"%ld",operationId];
    if([self.requestSet objectForKey:operationKey])
    {
        ANRequest *tmp = (ANRequest *)[self.requestSet objectForKey:operationKey];
        [tmp.operation cancel];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)cacheOperationByOperationId:(NSInteger)operationId
{
    NSString *operationKey = [NSString stringWithFormat:@"%ld",operationId];
    if([self.requestSet objectForKey:operationKey])
    {
        ANRequest *tmp = (ANRequest *)[self.requestSet objectForKey:operationKey];
        [[ANManager sharedInstance] cacheRequest:tmp category:tmp.category];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSArray *)getAllOperations
{
    NSMutableArray * t_return = [NSMutableArray array];
    for(ANRequest *t_request in self.requestSet)
    {
        [t_return addObject:t_request.operation];
    }
    return t_return;
}

- (BOOL)cacheAllOperation
{
    for(ANRequest *t_request in self.requestSet)
    {
        [[ANManager sharedInstance] cacheRequest:t_request category:t_request.category];
    }
    return YES;
}

- (BOOL)cancelAllOperation
{
    [self cancelAllOperations];
    return YES;
}

- (void)addRequest:(ANRequest *)req
{
    if(req.category != DEFAULT_CATEGORY)
    {
        // 如果是默认分类则不添加进需要被缓存的request集合，即扔进去不管
        [self.requestSet setObject:req forKey:[NSString stringWithFormat:@"%ld",(long)req.operation.operationId]];
    }
}

- (void)removeRequestByOperationId:(NSInteger)operationId
{
    NSLog(@"trying to remove operation with id:%ld",operationId);
    NSString *operationKey = [NSString stringWithFormat:@"%ld",operationId];
    if ([self.requestSet objectForKey:operationKey])
    {
        NSLog(@"removed operation with id:%ld",operationId);
        [self.requestSet removeObjectForKey:operationKey];
    }
}
@end
