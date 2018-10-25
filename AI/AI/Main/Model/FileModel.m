//
//  FileModel.m
//  AI
//
//  Created by xuting on 2018/10/22.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel

+ (NSMutableArray *)getFileArrayWith:(NSDictionary *)dict {
    NSArray *array = [dict objectForKey:@"filelist"];
    NSMutableArray *result = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in array) {
            FileModel *m = [[FileModel alloc] init];
            m.filepath = [d objectForKey:@"filepath"];
            NSArray *fa = [m.filepath componentsSeparatedByString:@"/"];
            m.showName = fa.lastObject;
            NSString *type = [d objectForKey:@"type"];
            if ([type isEqual:@"0"]) { //文件夹
                m.type = @"0";
            }
            else {
                NSArray *a = [m.filepath componentsSeparatedByString:@"."];
                NSString *last = a.lastObject;
                NSArray *img = @[@"jpg",@"png",@"jpeg",@"gif",@"bmp"];
                NSArray *audio = @[@"mp3",@"wav",@"cd",@"asf",@"real",@"wma",@"ape",@"module",@"mp3pro",@"midi",@"vqf"];
                NSArray *video = @[@"avi",@"flv",@"mp4",@"mov",@"mpeg",@"mpg",@"mkv",@"dat",@"wmv",@"ogm",@"rmvb",@"rm",@"3gp",@"ogg"];
                if ([img containsObject:last]) {
                    m.type = @"1"; //图片
                }
                else if ([audio containsObject:last]) {
                    m.type = @"2"; //音频
                }
                else if ([video containsObject:last]) {
                    m.type = @"3"; //视频
                }
                else {
                    m.type = @"4"; //其他
                }
            }
            [result addObject:m];
        }
    }
    return result;
}

@end
