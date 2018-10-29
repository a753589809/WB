//
//  FileCell.h
//  AI
//
//  Created by xuting on 2018/10/22.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"

@interface FileCell : UITableViewCell

@property (nonatomic, strong) FileModel *model;

@property (nonatomic, copy) void(^ down)(FileModel *model);

@end
