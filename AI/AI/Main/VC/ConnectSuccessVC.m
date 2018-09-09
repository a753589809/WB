//
//  ConnectSuccessVC.m
//  AI
//
//  Created by xuting on 2018/9/9.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "ConnectSuccessVC.h"

@interface ConnectSuccessVC () {
    __weak IBOutlet UIImageView *successImageView;
    __weak IBOutlet UILabel *resultLabel;
    __weak IBOutlet UIButton *okButton;
}

@end

@implementation ConnectSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [okButton setBackgroundImage:[AIUtil getResizableImage:@"Btn-short" edge:UIEdgeInsetsMake(18, 18, 18, 18)] forState:UIControlStateNormal];
}

- (IBAction)clickOk:(id)sender {
    
}

@end
