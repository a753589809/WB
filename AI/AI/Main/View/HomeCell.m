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
    
    __weak IBOutlet UILabel *msgLabel;
    __weak IBOutlet UIImageView *imgView;
}

- (void)setModel:(HomeModel *)model {
    _model = model;
    msgLabel.text = model.title;
    imgView.image = [UIImage imageNamed:model.imageName];
}

@end
