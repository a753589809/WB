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
#import <AssetsLibrary/AssetsLibrary.h>

@interface FileViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *filePathLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popToRootVC)];
    [self.navigationItem setRightBarButtonItem:backItem];
    
    self.filePathLabel.text = [NSString stringWithFormat:@"/%@",self.filePath];
}

- (void)popToRootVC {
    [self.navigationController popToRootViewControllerAnimated:true];
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
            [self getFileList:model.filepath isRefresh:NO];
        }
    }
}


#pragma mark - 数据
- (NSMutableArray *)getSelectFile {
    NSMutableArray *a = [NSMutableArray array];
    for (FileModel *m in self.fileArray) {
        if (m.isSelect) {
            [a addObject:m.filepath];
        }
    }
    return a;
}

- (void)getFileList:(NSString *)path isRefresh:(BOOL)isRefresh {
    if (path == nil) {
        path = @"";
    }
    NSString *file = [NSString stringWithFormat:@"/downlist/%@", path];
    if (isRefresh) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
    }
    [[NetWorking defaultNetWorking] requestAddress:file andPostParameters:nil andBlock:^(NSDictionary *dict) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
        if (isRefresh) {
            [self.tableView reloadData];
        }
        else {
            FileViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FileViewController"];
            vc.fileArray = [FileModel getFileArrayWith:dict];
            vc.filePath = path;
            [self.navigationController pushViewController:vc animated:false];
        }
        FLog(@"%@",dict);
    } andFailDownload:^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
        [self showTool:@"文件读取失败" view:self.navigationController.view];
    }];
}

- (void)requestAddFolder:(NSString *)path {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
    NSString *p;
    if (self.filePath.length > 0) {
        p = [NSString stringWithFormat:@"/createDir/%@/%@",self.filePath,path];
    }
    else {
        p = [NSString stringWithFormat:@"/createDir/%@",path];
    }
    [[NetWorking defaultNetWorking] requestAddress:p andPostParameters:nil andBlock:^(NSDictionary *dict) {
        [self getFileList:self.filePath isRefresh:YES];
        FLog(@"%@",dict);
    } andFailDownload:^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
        [self showTool:@"文件夹创建失败" view:self.navigationController.view];
    }];
}


#pragma mark - 事件操作
- (IBAction)addFolder:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新建文件夹" message:@"请输入文件夹名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 88;
    [alert show];
}

- (IBAction)uploadFile:(id)sender {
    UIImagePickerControllerSourceType rceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = rceType;
    imagePicker.delegate = self;
    imagePicker.navigationBar.translucent = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)dowmFile:(id)sender {
//    NSMutableArray *a = [NSMutableArray array];
//    for (FileModel *m in self.fileArray) {
//        if (m.isSelect) {
//            if (![m.type isEqualToString:@"1"]) {
//                [self showTool:@"只支持下载图片" view:self.view];
//                return;
//            }
//            [a addObject:m.filepath];
//        }
//    }
//    if (a.count == 0) {
//        [self showTool:@"请选择需要下载的图片" view:self.view];
//        return;
//    }
//    NSInteger i = 0;
//    for (NSString *path in a) {
//        
//    }
}

- (IBAction)delFolder:(id)sender {
    NSMutableArray *file = [self getSelectFile];
    if (file.count == 0) {
        [self showTool:@"请选择需要操作的文件" view:self.view];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定删除所选文件或文件夹吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 99;
    [alert show];
}

#pragma mark - alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 88) {
        UITextField *field = [alertView textFieldAtIndex:0];
        if (field.text.length > 0) {
            [self requestAddFolder:field.text];
        }
    }
    else if (buttonIndex == 1 && alertView.tag == 99) {
        NSMutableArray *file = [self getSelectFile];
        if (file.count == 0) {
            [self showTool:@"请选择需要操作的文件" view:self.view];
            return;
        }
        NSMutableString *pathStr = [NSMutableString string];
        for (int i=0; i<file.count; i++) {
            NSString *s = file[i];
            [pathStr appendString:s];
            if (i != file.count - 1) {
                [pathStr appendString:@","];
            }
        }
        NSDictionary *params = @{@"data":[NSString stringWithFormat:@"[paths=%@]", pathStr]};
        FLog(@"%@",params);
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
        [[NetWorking defaultNetWorking] requestPostAddress:@"/removeDirFile" andPostParameters:params andBlock:^(NSDictionary *dict) {
            [self getFileList:self.filePath isRefresh:YES];
            FLog(@"%@",dict);
        } andFailDownload:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
            [self showTool:@"文件删除失败" view:self.navigationController.view];
        }];
    }
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if (img == nil)
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
    
    NSURL *imageUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary assetForURL:imageUrl resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSString *imageName = representation.filename;
        NSLog(@"imageName:%@", imageName);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *doucumentDirectory = paths[0];
        NSString *fullPath = [doucumentDirectory stringByAppendingPathComponent:imageName];
        [UIImageJPEGRepresentation(img, 1) writeToFile:fullPath atomically:YES];
        
        NSString *p;
        if (self.filePath.length > 0) {
            p = [NSString stringWithFormat:@"/update/%@/%@",self.filePath,imageName];
        }
        else {
            p = [NSString stringWithFormat:@"/update/%@",imageName];
        }
        [[NetWorking defaultNetWorking] uploadingFileAddress:p andFile:fullPath andProgress:^(NSProgress *progress) {
            FLog(@"%@", progress);
        } andBlock:^(NSDictionary *dict) {
            FLog(@"%@", dict);
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
            if ([[dict objectForKey:@"result"] isEqual:@"0"]) {
                [self getFileList:self.filePath isRefresh:YES];
            }
            else {
                [self showTool:@"上传失败" view:self.navigationController.view];
            }
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        } andFailDownload:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
            [self showTool:@"上传失败" view:self.navigationController.view];
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        }];
        
    } failureBlock:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
    }];
    
}

@end