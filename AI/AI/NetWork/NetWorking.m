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

- (void)uploading {
    //创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //发送post请求上传路径
    /*
     第一个参数:请求路径
     第二个参数:字典(非文件参数)
     第三个参数:constructingBodyWithBlock 处理要上传的文件数据
     第四个参数:进度回调
     第五个参数:成功回调 responseObject响应体信息
     第六个参数:失败回调
     */
    [manager POST:@"服务器ip" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        UIImage *image = [UIImage imageNamed:@"xxx.png"];
        NSData *imageData = UIImagePNGRepresentation(image);
        
        //使用formData拼接数据
        /* 方法一:
         第一个参数:二进制数据 要上传的文件参数
         第二个参数:服务器规定的
         第三个参数:文件上传到服务器以什么名称保存
         */
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"xxx.png" mimeType:@"image/png"];
        
        //方法二:
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@""] name:@"file" fileName:@"xxx.png" mimeType:@"image/png" error:nil];
        
        //方法三:
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@""] name:@"file" error:nil];
        
    }
         progress:^(NSProgress * _Nonnull uploadProgress) {
             
             NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
             
         }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
              NSLog(@"上传成功.%@",responseObject);
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
              NSLog(@"上传失败.%@",error);
          }];
}

- (void)down {
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    /* 下载地址 */
    NSURL *url = [NSURL URLWithString:@"http://xxx/test.mp4"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    /* 下载路径 */
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [path stringByAppendingPathComponent:url.lastPathComponent];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSLog(@"下载完成");
        
    }];
    [downloadTask resume];

}

- (void)down2 {
    //创建传话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cn.bing.com/az/hprichbg/rb/WindmillLighthouse_ZH-CN12870536851_1920x1080.jpg"]];
    //下载文件
    /*
     第一个参数:请求对象
     第二个参数:progress 进度回调
     第三个参数:destination 回调(目标位置)
     有返回值
     targetPath:临时文件路径
     response:响应头信息
     第四个参数:completionHandler 下载完成后的回调
     filePath:最终的文件路径
     */
    NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request
                                                                 progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                     //下载进度
                                                                     NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                                                                 }
                                                              destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                  //保存的文件路径
                                                                  NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
                                                                  return [NSURL fileURLWithPath:fullPath];
                                                                  
                                                              }
                                                        completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                            
                                                            NSLog(@"%@",filePath);
                                                        }];
    
    //执行Task
    [download resume];
}

@end
