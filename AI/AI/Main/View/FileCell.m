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
    __weak IBOutlet UIButton *selButton;
    __weak IBOutlet UIButton *downButton;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)cliclSelect:(id)sender {
    selButton.selected = !selButton.isSelected;
    self.model.isSelect = selButton.isSelected;
}

- (IBAction)downFile:(id)sender {
    if (self.down) {
        self.down(self.model);
    }
}

- (void)setModel:(FileModel *)model {
    _model = model;
    fileNameLabel.text = model.showName;
    selButton.selected = model.isSelect;
    downButton.hidden = true;
    if ([model.type isEqual:@"0"]) {
        imgView.image = [UIImage imageNamed:@"Folder"];
    }
    else if ([model.type isEqual:@"1"]) {
        imgView.image = [UIImage imageNamed:@"pic"];
        downButton.hidden = false;
    }
    else if ([model.type isEqual:@"2"]) {
        imgView.image = [UIImage imageNamed:@"music"];
    }
    else if ([model.type isEqual:@"3"]) {
        imgView.image = [UIImage imageNamed:@"movie"];
    }
    else {
        imgView.image = [UIImage imageNamed:@"file"];
    }
}

@end
