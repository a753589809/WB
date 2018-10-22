//
//  FileViewController.h
//  AI
//
//  Created by xuting on 2018/10/22.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface FileViewController : BaseVC

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSMutableArray *fileArray;

@end
