//
//  BaseVC.h
//  AI
//
//  Created by xuting on 2018/9/5.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseVC : UIViewController

@property (nonatomic, assign) BOOL showMenuButton;

- (void)showTool:(NSString *)title view:(UIView *)v;

@end
