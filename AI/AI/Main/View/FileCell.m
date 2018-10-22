//
//  FileCell.m
//  AI
//
//  Created by xuting on 2018/10/22.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "FileCell.h"

@implementation FileCell {
    
    __weak IBOutlet UIImageView *imgView;
    __weak IBOutlet UILabel *fileNameLabel;
    __weak IBOutlet UILabel *desLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(FileModel *)model {
    fileNameLabel.text = model.filepath;
    desLabel.text = @"11";
}

@end
