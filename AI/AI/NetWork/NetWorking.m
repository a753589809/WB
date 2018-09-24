//
//  NetWorking.m
//
//
//  Created by daboge on 14-11-10.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "NetWorking.h"
#import <AFNetworking.h>

@interface NetWorking()

@property (nonatomic, strong)AFHTTPSessionManager *manager;
@property (nonatomic, strong)NSString *app_Version;

@end

@implementation NetWorking {
    NSURLSessionDataTask *_sessionDataTask;
}

+ (NetWorking *)defaultNetWorking {
    
    static NetWorking *netw = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        netw = [[self alloc] init];
    });
    return netw;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [AFHTTPSessionManager manager];
        self.manager.requestSerializer.timeoutInterval = 45.0f;
//        self.manager.requestSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"application/x-www-form-urlencoded",@"text/json",@"text/html",@"text/xml",@"text/plain", nil];
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer]; //申明返回的结果是json类型
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"application/x-www-form-urlencoded",@"text/json",@"text/html",@"text/xml",@"text/plain", nil]; //如果报接受类型不一致请替换一致text/html或别的
    }
    return self;
}

- (void)requestAddress:(NSString *)address andPostParameters:(NSDictionary *)postDic andBlock:(blockDownload)getdic andFailDownload:(blockFailDownLoad)failBlock {
    _sessionDataTask = [self.manager GET:address parameters:postDic progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        getdic(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock();
        FLog(@"erroe:%@",error);
        FLog(@"erroe:%@",[error localizedDescription]);
    }];

}

- (void)requestAddress2:(NSString *)address key:(NSString *)key andPostParameters:(NSDictionary *)postDic andBlock:(blockDownload)getdic andFailDownload:(blockFailDownLoad)failBlock {
    
    [self.manager.requestSerializer setValue:key forHTTPHeaderField:@"authorization-user"];
//    [self.manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [self.manager.requestSerializer ]
//    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer]; 
    _sessionDataTask = [self.manager GET:address parameters:postDic progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        getdic(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock();
        FLog(@"erroe:%@",error);
        FLog(@"erroe:%@",[error localizedDescription]);
    }];
    
}


+ (void)postUrl:(NSString *)url key:(NSString *)key callback:(void(^)(BOOL success, NSDictionary *dic, NSError *error))callback {
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    request.timeoutInterval= 30;
    [request setValue:key forHTTPHeaderField:@"authorization-user"];
    
    // 设置body
//    [request setHTTPBody:imageData];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                 @"text/html",
                                                 @"text/json",
                                                 @"text/javascript",
                                                 @"text/plain",
                                                 @"application/octet-stream",
                                                 nil];
    manager.responseSerializer = responseSerializer;
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (responseObject) {
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSMutableDictionary *dic = d.mutableCopy;
            callback(true, dic, error);
        }
        else {
            callback(false, nil, error);
        }
    }] resume];
    
}


- (void)uploadingAddress:(NSString *)address
                 andFile:(NSString *)file
             andProgress:(blockProgress)progress
                andBlock:(blockDownload)block
         andFailDownload:(blockFailDownLoad)failBlock {
    
//    kRequestUrl
    _sessionDataTask = [self.manager POST:kRequestUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *filePath = [documentsDirectoryURL URLByAppendingPathComponent:file];
        /*
         此方法参数
         1. 要上传的文件路径
         2. 后台处理文件的字段,若没有可为空
         3. 要保存在服务器上的[文件名]
         4. 上传文件的[mimeType]
         application/octet-stream为通用型
         */
        [formData appendPartWithFileURL:filePath name:@"" fileName:file mimeType:@"application/octet-stream" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock();
        NSLog(@"error:%@",[error localizedDescription]);
    }];
    
}

@end
