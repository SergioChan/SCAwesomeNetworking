//
//  ANManager.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ANManager.h"

@implementation ANManager

+ (ANManager *) sharedInstance
{
    static dispatch_once_t  onceToken;
    static ANManager * sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ANManager alloc] init];
        
#pragma - 这里建议将responseSerializer的可接受content-type设置成和服务器协议一致，可以保证response的序列化顺利完成
        sharedInstance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json", @"text/plain",@"text/xml",@"application/rss+xml", @"application/json", @"application/octet-stream", nil];
        sharedInstance.responseSerializer = [ANResponseSerializer serializer];
        
        sharedInstance.requestSerializer = [ANRequestSerializer serializer];
        sharedInstance.requestSerializer.timeoutInterval=GLOBAL_TIMEOUT_INTERVAL;
        sharedInstance.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD",nil];
        sharedInstance.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        sharedInstance.operationQueue = [ANOperationQueue sharedInstance];
        [AFNetworkActivityIndicatorManager sharedManager].enabled=YES;
        [sharedInstance.reachabilityManager startMonitoring];
    });
    
    return sharedInstance;
}

/**
 *  恢复指定分类下的缓存请求
 *
 *  @param categories 指定分类的集合
 */
- (void)resumeCachedRequestWithCategory:(NSArray *)categories
{
    NSMutableArray *dataArray = [[ANManager sharedInstance] getNeedResendRequests:categories];
    
    for (ANRequest *request  in dataArray) {
        AFHTTPRequestOperation *operation = request.operation;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[ANManager sharedInstance] removeRequestFromCache:request];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
        
        [(ANOperationQueue *)self.operationQueue addOperation:operation];
    }
}

/**
 *  缓存指定请求到指定分类下
 *
 *  @param request  请求
 *  @param category 分类
 *
 *  @return 请求的唯一标识
 */
- (NSInteger) cacheRequest:(ANRequest *) request
                  category:(int) category
{
    //先读取原来的请求
    NSLog(@"cache request:%ld",request.operation.operationId);
    NSString *requestCategory = [NSString stringWithFormat:@"%@",@(category)];
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *requests = [userPrefs objectForKey:RequestsKey];
    NSMutableDictionary *newRequests = [[NSMutableDictionary alloc]init];
    
    if(![requests isKindOfClass:[NSArray class]])
    {
        newRequests = [NSMutableDictionary dictionaryWithDictionary:requests];
    }
    
    //拿到当前分类下的请求
    
    NSArray *requestValues = [NSArray array];
    if(![requests isKindOfClass:[NSArray class]])
    {
        requestValues = [requests objectForKey:requestCategory];
    }
    
    if(requestValues == nil)
    {
        requestValues = [NSArray array];
    }
    
    NSMutableArray *newRequestValues = [NSMutableArray arrayWithArray:requestValues];
    NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:request];
    
    NSDictionary *tmp_data = [NSDictionary dictionaryWithObjects:@[requestData,[NSNumber numberWithInteger:request.operation.operationId]] forKeys:@[@"data",@"id"]];
    
    [newRequestValues addObject:tmp_data];
    
    //更新
    [newRequests setObject:newRequestValues forKey:requestCategory];
    [userPrefs setObject:newRequests forKey:RequestsKey];
    [userPrefs synchronize];
    
    return request.operation.operationId;
}

/**
 *  删除缓存的请求
 *
 *  @param request
 */
- (void) removeRequestFromCache:(ANRequest *)request
{
    
    NSString *requestCategory = [NSString stringWithFormat:@"%ld",request.category];
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *tmp_newRequests = [userPrefs objectForKey:RequestsKey];
    NSMutableDictionary *newRequests = [NSMutableDictionary dictionary];
    
    if(![tmp_newRequests isKindOfClass:[NSArray class]])
    {
        newRequests = [NSMutableDictionary dictionaryWithDictionary:[userPrefs objectForKey:RequestsKey]];
    }
    
    NSArray *requestValues = [newRequests objectForKey:requestCategory];
    
    NSMutableArray *newRequestValues = [NSMutableArray array];
    
    for (NSDictionary *requestValue in requestValues) {
        ANRequest *tmp = [NSKeyedUnarchiver unarchiveObjectWithData:[requestValue objectForKey:@"data"]];
        if (request.operation.operationId != tmp.operation.operationId) {
            [newRequestValues addObject:requestValue];
        }
    }
    //更新
    [newRequests setObject:newRequestValues forKey:requestCategory];
    [userPrefs setObject:newRequests forKey:RequestsKey];
    [userPrefs synchronize];
}

/**
 *  删除缓存的请求
 *
 *  @param request
 */
- (void) removeRequestFromCacheById:(NSInteger)deleteRequestId
{
    NSMutableArray *t_categories = [NSMutableArray array];
    for(NSInteger i = 0 ;i < MAXCategory ; i++)
        [t_categories addObject:[NSString stringWithFormat:@"%ld",i]];
    NSArray *categories = [NSArray arrayWithArray:t_categories];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *tmp_newRequests = [userPrefs objectForKey:RequestsKey];
    NSMutableDictionary *newRequests = [NSMutableDictionary dictionary];
    
    if(![tmp_newRequests isKindOfClass:[NSArray class]])
    {
        newRequests = [NSMutableDictionary dictionaryWithDictionary:[userPrefs objectForKey:RequestsKey]];
    }
    
    for(NSString *tmp_category_name in categories)
    {
        NSArray *requestValues = [newRequests objectForKey:tmp_category_name];
        
        NSMutableArray *newRequestValues = [NSMutableArray array];
        
        for (NSDictionary *requestValue in requestValues) {
            ANRequest *tmp = [NSKeyedUnarchiver unarchiveObjectWithData:[requestValue objectForKey:@"data"]];
            if (deleteRequestId != tmp.operation.operationId) {
                [newRequestValues addObject:requestValue];
            }
        }
        //更新
        [newRequests setObject:newRequestValues forKey:tmp_category_name];
    }
    
    [userPrefs setObject:newRequests forKey:RequestsKey];
    [userPrefs synchronize];
}

/**
 *  获取指定的分类的请求列表
 *
 */
- (NSMutableArray *) getNeedResendRequests:(NSArray *) categories
{
    if (!categories) {
        NSMutableArray *t_categories = [NSMutableArray array];
        for(NSInteger i = 0 ;i < MAXCategory ; i++)
            [t_categories addObject:[NSString stringWithFormat:@"%ld",i]];
        categories = [NSArray arrayWithArray:t_categories];
    }
    
    NSMutableArray *resendRequests = [NSMutableArray array];
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *requests = [userPrefs objectForKey:RequestsKey];
    
    if(!requests)
    {
        return resendRequests;
    }
    
    if(requests.count == 0)
    {
        return resendRequests;
    }
    
    NSMutableArray *requestValues = [NSMutableArray array];
    
    for(NSString *tmp_category_name in categories)
    {
        NSArray *tmp_requests_per_category = [requests objectForKey:tmp_category_name];
        if(tmp_requests_per_category)
            [requestValues addObjectsFromArray:tmp_requests_per_category];
    }
    
    for(NSDictionary *tmp_request_dictionary in requestValues)
    {
        if([tmp_request_dictionary objectForKey:@"data"])
            [resendRequests addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[tmp_request_dictionary objectForKey:@"data"]]];
    }
    
    return resendRequests;
}

- (ANOperation *)POST:(NSString *)URLString
                        category:(ANCategory)category
                         context:(NSDictionary *)context
                             tag:(NSInteger)tag
                      parameters:(id)parameters
                      completion:(void (^)(ANOperation *operation))completed
                         success:(void (^)(ANOperation *operation, id responseObject))success
                         failure:(void (^)(ANOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        return nil;
    }
    
    ANOperation *t_operation = [self ANHTTPRequestOperationWithRequest:request success:^(ANOperation *operation, id responseObject) {
        [(ANOperationQueue *)self.operationQueue removeRequestByOperationId:[operation operationId]];
        success(operation,responseObject);
    } failure:^(ANOperation *operation, NSError *error) {
        if(error.code == HTTP_NONETWORK_CODE || error.code == HTTP_NOTCONNECTEDTOSERVER_CODE || error.code == HTTP_TIMEOUT_CODE || error.code == HTTP_RESPONSENOTJSON_CODE)
            [(ANOperationQueue *)self.operationQueue cacheOperationByOperationId:[operation operationId]];
        
        [(ANOperationQueue *)self.operationQueue removeRequestByOperationId:[operation operationId]];
        failure(operation,error);
    }];
    
    ANRequest *tmp = [[ANRequest alloc]initWithOperation:t_operation andCategory:category];
    tmp.context = context;
    tmp.tag = tag;
    
    completed(t_operation);
    
    [(ANOperationQueue *)self.operationQueue addRequest:tmp];
    [(ANOperationQueue *)self.operationQueue addOperation:t_operation];
    
    return t_operation;
}

- (ANOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                      completion:(void (^)(ANOperation *operation))completed
                         success:(void (^)(ANOperation *operation, id responseObject))success
                         failure:(void (^)(ANOperation *operation, NSError *error))failure
{
    return [self POST:URLString category:DEFAULT_CATEGORY context:nil tag:0 parameters:parameters completion:^(ANOperation *operation){
        completed(operation);
    }success:^(ANOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(ANOperation *operation, NSError *error) {
        failure(operation,error);
    }];
}

- (ANOperation *)ANHTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(ANOperation *operation, id responseObject))success
                                                    failure:(void (^)(ANOperation *operation, NSError *error))failure
{
    ANOperation *operation = [[ANOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    [operation setANCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;
    
    return operation;
}

//- (NSInteger)codeForUnderlyingError:(NSError *)error
//{
//    NSDictionary *underlyingErrorInfo = error.userInfo;
//    if([underlyingErrorInfo objectForKey:@"NSUnderlyingError"])
//    {
//        NSError *errorToReturn = [underlyingErrorInfo objectForKey:@"NSUnderlyingError"];
//        return errorToReturn.code;
//    }
//}

@end
