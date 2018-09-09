//
//  XTSheetView.m
//  AI
//
//  Created by xuting on 2018/9/8.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "XTSheetView.h"

@implementation XTSheetView {
    NSArray *_titleArray;
    NSArray *_subArray;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCancel)]];
}

- (void)setTitleArray:(NSArray *)titleArray subTitle:(NSArray *)subArray {
    _titleArray = titleArray;
    _subArray = subArray;
    
    CGFloat y = kScreenHeight;
    if (titleArray.count > 0) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(10, 0, kScreenWidth - 20, 60);
        b.bottom = y - 10;
        [b addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
        [b setBackgroundImage:[AIUtil getResizableImage:@"menu-Button-short" edge:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateNormal];
        [b setBackgroundImage:[AIUtil getResizableImage:@"menu-Button-short-p" edge:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateHighlighted];
        [self addSubview:b];
        
        UILabel *label = [AIUtil createLabelWithFrame:CGRectMake(0, 0, b.width, b.height) font:[UIFont systemFontOfSize:20] title:@"取消" color:ColorRGB(0x4980F9)];
        label.textAlignment = NSTextAlignmentCenter;
        [b addSubview:label];
        y = kScreenHeight - 80;
    }
    
    for (NSInteger i=titleArray.count-1; i>=0; i--) {
        NSString *imageName1;
        NSString *imageName2;
        if (i == 0) {
            imageName1 = @"menu-Header-short";
            imageName2 = @"menu-Header-short-p";
        }
        else if (i == titleArray.count - 1) {
            imageName1 = @"menu-Bottom-short";
            imageName2 = @"menu-Bottom-short-p";
        }
        else {
            imageName1 = @"menu-Middle-short";
            imageName2 = @"menu-Middle-short-p";
        }
        
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(10, 0, kScreenWidth - 20, 60);
        b.bottom = y;
        b.tag = i;
        [b addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        [b setBackgroundImage:[AIUtil getResizableImage:imageName1 edge:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateNormal];
        [b setBackgroundImage:[AIUtil getResizableImage:imageName2 edge:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateHighlighted];
        [self addSubview:b];
        
        UILabel *label = [AIUtil createLabelWithFrame:CGRectMake(0, 11, b.width, 28) font:[UIFont systemFontOfSize:20] title:[titleArray objectAt:i] color:ColorRGB(0x4980F9)];
        label.textAlignment = NSTextAlignmentCenter;
        [b addSubview:label];
        
        UILabel *label2 = [AIUtil createLabelWithFrame:CGRectMake(0, label.bottom, b.width, 13) font:[UIFont systemFontOfSize:10] title:[subArray objectAt:i] color:ColorRGB(0x8F8F8F)];
        label2.textAlignment = NSTextAlignmentCenter;
        [b addSubview:label2];
        
        if (i != titleArray.count - 1) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, b.height - 1, b.width, 1)];
            line.backgroundColor = ColorRGB(0xe0e0e0);
            [b addSubview:line];
        }
        
        y -= b.height;
    }
    
}

- (void)clickCancel {
    [self removeFromSuperview];
}

- (void)clickMenu:(UIButton *)bt {
    [self clickCancel];
}

@end
