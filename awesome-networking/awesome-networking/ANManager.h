//
//  ANManager.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANHeader.h"
#import "ANRequest.h"
#import "ANOperationQueue.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkActivityIndicatorManager.h"

typedef void (^successBlock)(void);
typedef void (^failErrorBlock)(NSError *error);

@interface ANManager : AFHTTPRequestOperationManager

+ (ANManager *) sharedInstance;

/**
 *  恢复指定分类下的缓存请求
 *
 *  @param categories 指定分类的集合
 */
- (void)resumeCachedRequestWithCategory:(NSArray *)categories;

/**
 *  缓存指定请求到指定分类下
 *
 *  @param request  请求
 *  @param category 分类
 *
 *  @return 请求的唯一标识
 */
- (NSInteger) cacheRequest:(ANRequest *) request
                  category:(int) category;

/**
 *  删除缓存的请求
 *
 *  @param request
 */
- (void) removeRequestFromCache:(ANRequest *)request;

/**
 *  根据id删除缓存的请求
 *
 *  @param requestId
 */
- (void) removeRequestFromCacheById:(NSInteger)deleteRequestId;

/**
 *  获取指定的分类的请求列表
 *
 */
- (NSMutableArray *) getNeedResendRequests:(NSArray *) categories;

/**
 *  用POST方法创建并运行一个`ANOperation`的对象，附带了附加字典，缓存分类和缓存标识
 *
 *  @param URLString  <#URLString description#>
 *  @param category   <#category description#>
 *  @param context    <#context description#>
 *  @param tag        <#tag description#>
 *  @param parameters <#parameters description#>
 *  @param success    <#success description#>
 *  @param failure    <#failure description#>
 *
 *  @return <#return value description#>
 */
- (ANOperation *)POST:(NSString *)URLString
             category:(ANCategory)category
              context:(NSDictionary *)context
                  tag:(NSInteger)tag
           parameters:(id)parameters
           completion:(void (^)(AFHTTPRequestOperation *operation))completionBlock
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  用POST方法创建并运行一个`ANOperation`的对象
 *
 *  @param URLString  <#URLString description#>
 *  @param parameters <#parameters description#>
 *  @param success    <#success description#>
 *  @param failure    <#failure description#>
 *
 *  @return <#return value description#>
 */
- (ANOperation *)POST:(NSString *)URLString
           parameters:(id)parameters
           completion:(void (^)(AFHTTPRequestOperation *operation))completionBlock
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
