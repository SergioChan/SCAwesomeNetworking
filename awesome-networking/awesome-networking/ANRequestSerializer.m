//
//  ANRequestSerializer.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/30.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ANRequestSerializer.h"

@implementation ANRequestSerializer

/**
 *  重写了父类序列化request的方法，将非NSDictionary的接口通过父类的该方法返回
 *  只有类型为NSData的protoBuffer的数据需要通过子类的这个方法返回
 *
 *  @param request    请求
 *  @param parameters 需要序列化的BODY数据
 *  @param error      错误
 *
 *  @return 序列化之后的请求
 */
- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(request);
    if(!parameters)
    {
        return [super requestBySerializingRequest:request withParameters:parameters error:error];
    }
    else
    {
        if([parameters isKindOfClass:[NSDictionary class]])
        {
            return [super requestBySerializingRequest:request withParameters:parameters error:error];
        }
        else
        {
            NSMutableURLRequest *mutableRequest = [request mutableCopy];
            
            [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
                if (![request valueForHTTPHeaderField:field]) {
                    [mutableRequest setValue:value forHTTPHeaderField:field];
                }
            }];
            [mutableRequest setHTTPBody:parameters];
            return mutableRequest;
        }
    }
}
@end
