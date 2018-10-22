//
//  FileViewController.m
//  AI
//
//  Created by xuting on 2018/10/22.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "FileViewController.h"
#import "FileModel.h"
#import "FileCell.h"
#import "NetWorking.h"

@interface FileViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *filePathLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.filePathLabel.text = self.filePath;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell" forIndexPath:indexPath];
    if (self.fileArray.count > indexPath.row) {
        cell.model = self.fileArray[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.fileArray.count > indexPath.row) {
        FileModel *model = self.fileArray[indexPath.row];
        if ([model.type isEqualToString:@"0"]) {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
            NSString *file = [NSString stringWithFormat:@"/downlist/%@", model.filepath];
            [[NetWorking defaultNetWorking] requestAddress:file andPostParameters:nil andBlock:^(NSDictionary *dict) {
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
                NSArray *array = [dict objectForKey:@"filelist"];
                NSMutableArray *result = [NSMutableArray array];
                if ([array isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *d in array) {
                        FileModel *m = [[FileModel alloc] init];
                        m.type = [d objectForKey:@"type"];
                        m.filepath = [d objectForKey:@"filepath"];
                        [result addObject:m];
                    }
                }
                FileViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FileViewController"];
                vc.fileArray = result;
                vc.filePath = file;
                [self.navigationController pushViewController:vc animated:false];
                FLog(@"%@",dict);
            } andFailDownload:^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
                [self showTool:@"文件读取失败" view:self.navigationController.view];
            }];
        }
    }
}

@end
