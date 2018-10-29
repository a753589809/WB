//
//  NetWorking.h
//  
//
//  Created by daboge on 14-11-10.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^blockDownload)(NSDictionary *dict);
typedef void (^blockFailDownLoad) (void);
typedef void (^blockProgress) (NSProgress *progress);

@interface NetWorking : NSObject

+ (NetWorking *)defaultNetWorking;

- (void)requestAddress:(NSString *)address andPostParameters:(NSDictionary *)postDic andBlock:(blockDownload)getdic andFailDownload:(blockFailDownLoad)failBlock;

- (void)requestPostAddress:(NSString *)address andPostParameters:(NSDictionary *)postDic andBlock:(blockDownload)getdic andFailDownload:(blockFailDownLoad)failBlock;

- (void)uploadingAddress:(NSString *)address
                 andFile:(NSString *)file
             andProgress:(blockProgress)progress
                andBlock:(blockDownload)block
         andFailDownload:(blockFailDownLoad)failBlock;

- (void)uploadingAddress:(NSString *)address
                    data:(NSData *)data
                fileName:(NSString *)fileName
             andProgress:(blockProgress)progress
                andBlock:(blockDownload)block
         andFailDownload:(blockFailDownLoad)failBlock;

- (void)downAddress:(NSString *)address
        andProgress:(blockProgress)progress
           andBlock:(blockDownload)block
    andFailDownload:(blockFailDownLoad)failBlock;
- (void)uploading;
@end
