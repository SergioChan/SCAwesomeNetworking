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

/**
 *  覆盖了父类的初始化方法
 *
 *  @param urlRequest NSURLRequest
 *
 *  @return 实例
 */
- (instancetype)initWithRequest:(NSURLRequest *)urlRequest;

/**
 *  设置回调block的方法
 *
 *  @param success Callback when request is successfully operated
 *  @param failure Callback when request is failed to operate
 */
- (void)setANCompletionBlockWithSuccess:(void (^)(ANOperation *operation, id responseObject))success
                                failure:(void (^)(ANOperation *operation, NSError *error))failure;
@end
