//
//  NetWorking.m
//
//
//  Created by daboge on 14-11-10.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "NetWorking.h"
#import <AFNetworking.h>
#include <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 1024*8

@interface NetWorking()

@property (nonatomic, strong)AFHTTPSessionManager *manager;

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
        self.manager.requestSerializer.timeoutInterval = 20.0f;
//        self.manager.requestSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"application/x-www-form-urlencoded",@"text/json",@"text/html",@"text/xml",@"text/plain", nil];
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer]; //申明返回的结果是json类型
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"application/x-www-form-urlencoded",@"text/json",@"text/html",@"text/xml",@"text/plain", nil]; //如果报接受类型不一致请替换一致text/html或别的
    }
    return self;
}

- (void)requestAddress:(NSString *)address andPostParameters:(NSDictionary *)postDic andBlock:(blockDownload)getdic andFailDownload:(blockFailDownLoad)failBlock {
    self.manager.requestSerializer.timeoutInterval = 20.0f;
    NSString *url = [NSString stringWithFormat:@"%@%@", kBoxUrl, address];
    FLog(@"get====%@",url);
    _sessionDataTask = [self.manager GET:url parameters:postDic progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        getdic(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock();
        FLog(@"erroe:%@",error);
        FLog(@"erroe:%@",[error localizedDescription]);
    }];
}

- (void)requestPostAddress:(NSString *)address andPostParameters:(NSDictionary *)postDic andBlock:(blockDownload)getdic andFailDownload:(blockFailDownLoad)failBlock {
    self.manager.requestSerializer.timeoutInterval = 20.0f;
    NSString *url = [NSString stringWithFormat:@"%@%@", kBoxUrl, address];
    FLog(@"post====%@",url);
    _sessionDataTask = [self.manager POST:url parameters:postDic progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        getdic(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock();
        FLog(@"erroe:%@",error);
        FLog(@"erroe:%@",[error localizedDescription]);
    }];
}

- (void)uploadingAddress:(NSString *)address
                 andFile:(NSString *)file
             andProgress:(blockProgress)progress
                andBlock:(blockDownload)block
         andFailDownload:(blockFailDownLoad)failBlock {
    self.manager.requestSerializer.timeoutInterval = 30.0f;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    [self.manager.requestSerializer setValue:[NetWorking getFileMD5WithPath:filePath] forHTTPHeaderField:@"fileInfoMd5"];
    _sessionDataTask = [self.manager POST:[NSString stringWithFormat:@"%@%@", kBoxUrl, address] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /*
         此方法参数
         1. 要上传的文件路径
         2. 后台处理文件的字段,若没有可为空
         3. 要保存在服务器上的[文件名]
         4. 上传文件的[mimeType]
         application/octet-stream为通用型
         */
        
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        [formData appendPartWithFileURL:fileUrl name:@"" fileName:file mimeType:@"application/octet-stream" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock();
        FLog(@"error:%@",[error localizedDescription]);
    }];
    
}

- (void)uploadingAddress:(NSString *)address
                    data:(NSData *)data
                fileName:(NSString *)fileName
             andProgress:(blockProgress)progress
                andBlock:(blockDownload)block
         andFailDownload:(blockFailDownLoad)failBlock {
    self.manager.requestSerializer.timeoutInterval = 30.0f;
//    [self.manager.requestSerializer setValue:[NetWorking getFileMD5WithPath:filePath] forHTTPHeaderField:@"fileInfoMd5"];
    _sessionDataTask = [self.manager POST:[NSString stringWithFormat:@"%@%@", kBoxUrl, address] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"application/octet-stream"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock();
        FLog(@"error:%@",[error localizedDescription]);
    }];
    
}

- (void)downAddress:(NSString *)address
        andProgress:(blockProgress)progress
           andBlock:(blockDownload)block
    andFailDownload:(blockFailDownLoad)failBlock {
    
    self.manager.requestSerializer.timeoutInterval = 30.0f;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBoxUrl, address]];
    FLog(@"%@",url.absoluteURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePathStr = [path stringByAppendingPathComponent:url.lastPathComponent];
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//        FLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePathStr];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            failBlock();
            FLog(@"error:%@",[error localizedDescription]);
        }
        else {
            block(@{@"file":filePathStr});
        }
    }];
    [downloadTask resume];

}


+ (NSString*)getFileMD5WithPath:(NSString*)path {
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
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
    [self.manager POST:@"http://10.10.10.254:8080/upfile/11.png" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        UIImage *image = [UIImage imageNamed:@"11.png"];
        NSData *imageData = UIImagePNGRepresentation(image);
        
        //使用formData拼接数据
        /* 方法一:
         第一个参数:二进制数据 要上传的文件参数
         第二个参数:服务器规定的
         第三个参数:文件上传到服务器以什么名称保存
         */
//        [formData appendPartWithFileData:imageData name:@"file" fileName:@"11.png" mimeType:@"image/png"];
        
        //方法二:
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"11.png" ofType:nil];
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"xxx.png" mimeType:@"image/jpeg" error:nil];
        
        //方法三:
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@""] name:@"file" error:nil];
        
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


@end
