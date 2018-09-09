//
//  HomeCell.m
//  AI
//
//  Created by xuting on 2018/9/5.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "HomeCell.h"
#import "HomeModel.h"

@implementation HomeCell {
    __weak IBOutlet UIView *_bgView;
    __weak IBOutlet UILabel *msgLabel;
    __weak IBOutlet UIImageView *imgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _bgView.layer.cornerRadius = 5.0;
    _bgView.layer.shadowColor = [UIColor lightGrayColor].CGColor;//阴影颜色
    _bgView.layer.shadowOffset = CGSizeMake(0, 0);//偏移距离
    _bgView.layer.shadowOpacity = 0.15;//不透明度
    _bgView.layer.shadowRadius = 15.0;//半径
    
}

- (void)setModel:(HomeModel *)model {
    _model = model;
    msgLabel.text = model.title;
    imgView.image = [UIImage imageNamed:model.imageName];
}

@end
