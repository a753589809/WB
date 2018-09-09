//
//  AIUtil.h
//  AI
//
//  Created by xuting on 2018/9/9.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIUtil : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UILabel*)createLabelWithFrame:(CGRect)frame font:(UIFont *)font title:(NSString*)title color:(UIColor *)color;

+ (UIImage *)getResizableImage:(NSString *)imageName edge:(UIEdgeInsets)inset;

@end
