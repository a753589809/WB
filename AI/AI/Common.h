//
//  Common.h
//  kaixingou
//
//  Created by xuting on 15/5/28.
//  Copyright (c) 2015年 kaixingou. All rights reserved.
//

#ifndef kaixingou_Common_h
#define kaixingou_Common_h

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


#define Is_Iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_Iphone_X (Is_Iphone && kScreenHeight == 812.0)
#define kNaviHeight (Is_Iphone_X ? 88 : 64)
#define kTabbarHeight (Is_Iphone_X ? 83 : 49)
#define kBottomHeight (Is_Iphone_X ? 34 : 0)
#define kStatusBarHeight (Is_Iphone_X ? 44 : 20)


//返回按钮图片
#define kBackImage [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]


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


// 本地化
#define L(key) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]


// url
#define kBoxUrl @"http://10.10.10.254:8080"

#define kDownlistUrl @"/downlist"
#define kUpdateUrl @"/update"
#define kCreateDirUrl @"/createDir"
#define kDownfileUrl @"/downfile"
#define kUpfileUrl @"/upfile"
#define kRemoveDirFileUrl @"/removeDirFile"
#define kCheckmodelversionUrl @"/checkmodelversion"

// userdefault key
#define VOICEKEY @"VOICEKEY"

#endif
