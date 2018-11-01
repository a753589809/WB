//
//  NSArray+VAInfo.h
//  123
//
//  Created by 123 on 16/8/25.
//  Copyright © 2016年 zzkko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (VAInfo)

/** 通过下标安全访问 如果越界 返回 nil*/
-(id)objectAt:(NSInteger)index;

@end
