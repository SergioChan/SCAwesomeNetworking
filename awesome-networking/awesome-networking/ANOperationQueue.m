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

- (void)addRequest:(ANRequest *)req
{
    [super addOperation:req.operation];
    
    if(req.category != DEFAULT_CATEGORY)
    {
        // 如果是默认分类则不添加进需要被缓存的request集合，即扔进去不管
        [self.requestSet setObject:req forKey:[NSString stringWithFormat:@"%ld",(long)req.operation.operationId]];
    }
}
@end
