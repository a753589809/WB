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

- (void)requestAddress2:(NSString *)address key:(NSString *)key andPostParameters:(NSDictionary *)postDic andBlock:(blockDownload)getdic andFailDownload:(blockFailDownLoad)failBlock;

- (void)uploadingAddress:(NSString *)address
                 andFile:(NSString *)file
             andProgress:(blockProgress)progress
                andBlock:(blockDownload)block
         andFailDownload:(blockFailDownLoad)failBlock;

@end
