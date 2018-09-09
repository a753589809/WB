//
//  AIUtil.m
//  AI
//
//  Created by xuting on 2018/9/9.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "AIUtil.h"

@implementation AIUtil

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UILabel*)createLabelWithFrame:(CGRect)frame font:(UIFont *)font title:(NSString*)title color:(UIColor *)color {
    UILabel*label = [[UILabel alloc]initWithFrame:frame];
    label.numberOfLines  =0;//换几行
    label.text = title;
    label.font = font;
    label.textColor = color;
    return label;
}

+ (UIImage *)getResizableImage:(NSString *)imageName edge:(UIEdgeInsets)inset {
    return [[UIImage imageNamed:imageName] resizableImageWithCapInsets:inset];
}

@end
