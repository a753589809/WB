//
//  Common.h
//  kaixingou
//
//  Created by xuting on 15/5/28.
//  Copyright (c) 2015年 kaixingou. All rights reserved.
//

#ifndef kaixingou_Common_h
#define kaixingou_Common_h

//__weak  __strong
/**
 * 强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 * 调用方式: `@weakify(object)`实现弱引用转换，`@strongify(object)`实现强引用转换
 *
 * 示例：
 * @weakify(object)
 * [obj block:^{
 * @strongify(object)
 * strong_object = something;
 * }];
 */
#ifndef    weakify
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#endif
#ifndef    strongify
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = block##_##object;
#endif
#endif


//屏幕的宽、高
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//iPhone 6,iPhone 6Plus适配
#define Size(x)  ((x)*kScreenWidth/320.f)
#define Size6(x) ((x)*kScreenWidth/375.f)

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define Is_Iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_Iphone_X (Is_Iphone && kScreenHeight == 812.0)
#define kNaviHeight (Is_Iphone_X ? 88 : 64)
#define kTabbarHeight (Is_Iphone_X ? 83 : 49)
#define kBottomHeight (Is_Iphone_X ? 34 : 0)
#define kStatusBarHeight (Is_Iphone_X ? 44 : 20)

//判断系统版本
#define  IOS8_LATER  [[UIDevice currentDevice].systemVersion floatValue] >= 8.0
#define  IOS10_LATER [[UIDevice currentDevice].systemVersion floatValue] >= 10.0

//判断是否 Retina屏、设备是否iPhone 5、是否是iPad
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)


//返回按钮图片
#define kBackImage [[UIImage imageNamed:@"menuicon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]


//Alert
#define kCreateAlert(title) UIAlertView *_alertView11 = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];\
[_alertView11 show];


//NSLog
#ifdef DEBUG
#   define FLog(fmt, ...) NSLog((@"%sine %d [L] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#   define DLog(fmt, ...) NSLog(fmt)
#else
#   define FLog(...)
#   define DLog(...)
#endif
#define RLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#ifdef DEBUG
#   define ALog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ALog(...)
#endif


//颜色
#define ColorRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RGBA(r,g,b,a)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b)      RGBA(r,g,b,1.0f)
#define RGBACOLOR(r,g,b,a)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]


#endif
