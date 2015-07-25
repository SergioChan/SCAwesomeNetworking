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
        sharedInstance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json", @"text/plain",@"text/xml",@"application/rss+xml", @"application/json", nil];
        sharedInstance.requestSerializer = [AFHTTPRequestSerializer serializer];
        sharedInstance.requestSerializer.timeoutInterval=10.0f;
        sharedInstance.operationQueue = [ANOperationQueue sharedInstance];
        [AFNetworkActivityIndicatorManager sharedManager].enabled=YES;
        sharedInstance.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD",nil];
        sharedInstance.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
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
            [operation start];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"requestId is  %ld",request.operation.operationId);
                [[ANManager sharedInstance] removeRequestFromCache:request];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            }];
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
                      completion:(void (^)(AFHTTPRequestOperation *operation))completionBlock
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
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
    
    
    ANOperation *operation = [[ANOperation alloc]initWithOperation:[self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //确保返回的对象是ANOperation
        if([operation isKindOfClass:[ANOperation class]])
            [(ANOperationQueue *)self.operationQueue removeRequestByOperationId:[(ANOperation *)operation operationId]];
        
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }]];
    
    ANRequest *tmp = [[ANRequest alloc]initWithOperation:operation andCategory:category];
    tmp.context = context;
    tmp.tag = tag;
    [(ANOperationQueue *)self.operationQueue addRequest:tmp];
    
    completionBlock(operation);
    
    return tmp.operation;
}

- (ANOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                      completion:(void (^)(AFHTTPRequestOperation *operation))completionBlock
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self POST:URLString category:DEFAULT_CATEGORY context:nil tag:0 parameters:parameters completion:^(AFHTTPRequestOperation *operation){
        completionBlock(operation);
    }success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];
}
@end
