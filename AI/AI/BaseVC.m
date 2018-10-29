//
//  BaseVC.m
//  AI
//
//  Created by xuting on 2018/9/5.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "BaseVC.h"
#import "XTSheetView.h"

@interface BaseVC ()<XTSheetViewDelegat>

@property (nonatomic, strong) UIView *menuView; //右上角菜单

@end

@implementation BaseVC {
    UILabel *_voiceLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"AI Box";
    
    if (self.showMenuButton) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menuicon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(clickMenu)];
        [self.navigationItem setRightBarButtonItem:backItem];
    }
    
    if (self.navigationController.childViewControllers.count > 1) {
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithImage:kBackImage style:UIBarButtonItemStyleDone target:self action:@selector(backClick)];
        [self.navigationItem setLeftBarButtonItem:backItem];
    }
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
        NSString *t;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:VOICEKEY]) {
            t = @"开启语音朗读";
        }
        else {
            t = @"关闭语音朗读";
        }
        NSArray *titles = @[@"连接AI Box",t];
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
            if (i == 1) {
                _voiceLabel = label;
            }
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
//        NSArray *title = @[@"AI Box一键连中继",@"AI Box手动连接",@"手机热点连接AI Box",@"手机直连AI Box"];
//        NSArray *sub = @[@"手机使用2.4GWiFi时可用此连接方法",@"AI Box手动搜索周围WiFi连接",@"手机打开热点共享给AI Box连接",@"手机直接连接AI Box的网络，无法上internet网"];
        NSArray *title = @[@"手机直连AI Box"];
        NSArray *sub = @[@"手机直接连接AI Box的网络，无法上internet网"];
        XTSheetView *sheet = [[NSBundle mainBundle] loadNibNamed:@"XTSheetView" owner:nil options:nil].lastObject;
        sheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [sheet setTitleArray:title subTitle:sub];
        sheet.delegate = self;
        [self.navigationController.view addSubview:sheet];
        [sheet mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.mas_equalTo(self.navigationController.view);
        }];
    }
    else if (bt.tag == 1) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:VOICEKEY]) {
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:VOICEKEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _voiceLabel.text = @"关闭语音朗读";
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:VOICEKEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _voiceLabel.text = @"开启语音朗读";
        }
    }
    [self hideMenuView];
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)showTool:(NSString *)title view:(UIView *)v {
    MBProgressHUD *tool = [MBProgressHUD showHUDAddedTo:v animated:YES];
    tool.mode = MBProgressHUDModeText;
    tool.margin = 10.f;
    tool.yOffset = 200.f;
    tool.detailsLabelText = title;
    tool.detailsLabelFont = [UIFont systemFontOfSize:14];
    tool.removeFromSuperViewOnHide = YES;
    float a = title.length / 10.0;
    [tool hide:YES afterDelay:a > 1.5 ? a : 1.5f];
}

- (void)clickSheetView:(XTSheetView *)sheetView index:(NSInteger)index {
    if (index == 0) {
        NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        else {
            NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}
@end
