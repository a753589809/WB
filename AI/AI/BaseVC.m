//
//  BaseVC.m
//  AI
//
//  Created by xuting on 2018/9/5.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "BaseVC.h"
#import "XTSheetView.h"

@interface BaseVC ()

@property (nonatomic, strong) UIView *menuView; //右上角菜单

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"AI Box";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menuicon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(clickMenu)];
    [self.navigationItem setRightBarButtonItem:backItem];
}

- (UIView *)menuView {
    if (!_menuView) {
        
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [_menuView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenuView)]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kNaviHeight - 10, 214, 59+65)];
        imageView.right = _menuView.width - 15;
        imageView.userInteractionEnabled = true;
        [_menuView addSubview:imageView];
        
        CGFloat y = 0;
        NSArray *titles = @[@"连接AI Box",@"关闭语音朗读"];
        NSArray *images = @[@"menu-link",@"menu-sound"];
        NSArray *bgimages = @[@"menu-bg-1",@"menu-bg-2"];
        
        for (int i=0; i<titles.count; i++) {
            CGFloat h;
            if (i == 0) {
                h = 65;
            }
            else {
                h = 59;
            }
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.frame = CGRectMake(0, y, imageView.width, h);
            [b addTarget:self action:@selector(clickMune:) forControlEvents:UIControlEventTouchUpInside];
            [b setBackgroundImage:[UIImage imageNamed:bgimages[i]] forState:UIControlStateNormal];
            [b setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-p", bgimages[i]]] forState:UIControlStateHighlighted];
            b.tag = i;
            [imageView addSubview:b];
            y += (h - 2);
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 22, 22)];
            img.bottom = b.height - 18.5;
            img.image = [UIImage imageNamed:images[i]];
            [b addSubview:img];
            UILabel *label = [self createLabelWithFrame:CGRectMake(img.right + 15, 0, b.width - img.right - 15, 59) font:[UIFont systemFontOfSize:18] title:titles[i] color:[UIColor whiteColor]];
            label.bottom = b.height;
            [b addSubview:label];
        }
    }
    return _menuView;
}

- (UILabel*)createLabelWithFrame:(CGRect)frame font:(UIFont *)font title:(NSString*)title color:(UIColor *)color {
    UILabel*label = [[UILabel alloc]initWithFrame:frame];
    label.numberOfLines  =0;//换几行
    label.text = title;
    label.font = font;
    label.textColor = color;
    return label;
}

- (void)clickMenu {
    [self showMenuView];
}

//显示菜单
- (void)showMenuView {
    [self.view endEditing:true];
    if (self.menuView.superview) {
        [self hideMenuView];
    }
    else {
        [self.navigationController.view addSubview:self.menuView];
    }
}

//关闭菜单
- (void)hideMenuView {
    [self.menuView removeFromSuperview];
}

- (void)clickMune:(UIButton *)bt {
    if (bt.tag == 0) {
        NSArray *title = @[@"AI Box一键连中继",@"AI Box手动连接",@"手机热点连接AI Box",@"手机直连AI Box"];
        NSArray *sub = @[@"手机使用2.4GWiFi时可用此连接方法",@"AI Box手动搜索周围WiFi连接",@"手机打开热点共享给AI Box连接",@"手机直接连接AI Box的网络，无法上internet网"];
        XTSheetView *sheet = [[NSBundle mainBundle] loadNibNamed:@"XTSheetView" owner:nil options:nil].lastObject;
        sheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [sheet setTitleArray:title subTitle:sub];
        [self.navigationController.view addSubview:sheet];
        [sheet mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.mas_equalTo(self.navigationController.view);
        }];
    }
    else if (bt.tag == 1) {
        
    }
    [self hideMenuView];
}

@end
