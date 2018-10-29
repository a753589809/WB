//
//  NSArray+VAInfo.m
//  123
//
//  Created by 123 on 16/8/25.
//  Copyright © 2016年 zzkko. All rights reserved.
//

#import "NSArray+VAInfo.h"

@implementation NSArray (VAInfo)

-(id)objectAt:(NSInteger)index
{
    if(index < self.count)
    {
        return self[index];
    }
    else
    {
        return nil;
    }
}

@end
