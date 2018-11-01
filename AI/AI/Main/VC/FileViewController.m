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
#import <Photos/Photos.h>

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
        __weak FileViewController *weakSelf = self;
        cell.down = ^(FileModel *model) {
            [weakSelf dowmFile:model];
        };
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
    NSString *file = [NSString stringWithFormat:@"%@/%@",kDownlistUrl, path];
    if (!isRefresh) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
    }
    [[NetWorking defaultNetWorking] requestAddress:file andPostParameters:nil andBlock:^(NSDictionary *dict) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
        if (isRefresh) {
            NSMutableArray *a = [FileModel getFileArrayWith:dict];
            self.fileArray = a;
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
        p = [NSString stringWithFormat:@"%@/%@/%@",kCreateDirUrl,self.filePath,path];
    }
    else {
        p = [NSString stringWithFormat:@"%@/%@",kCreateDirUrl,path];
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

- (void)dowmFile:(FileModel *)model {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
    [[NetWorking defaultNetWorking] downAddress:[NSString stringWithFormat:@"%@/%@",kDownfileUrl,model.filepath] andProgress:^(NSProgress *progress) {
        
    } andBlock:^(NSDictionary *dict) {
        NSString *filePathStr = [dict objectForKey:@"file"];
//        NSData *d = [NSData dataWithContentsOfFile:filePathStr];
//        UIImage *i = [UIImage imageWithData:d];
        UIImage *img = [UIImage imageWithContentsOfFile:filePathStr];
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
                }
            }];
        }
        else if (status == PHAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请在\"设置->隐私->照片\"中允许访问照片。" delegate:self cancelButtonTitle:L(@"Sure") otherButtonTitles:nil];
            [alert show];
        }
        else if (status == PHAuthorizationStatusAuthorized) {
            UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        }
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
    } andFailDownload:^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
        [self showTool:@"下载失败" view:self.view];
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        
    }
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
        [[NetWorking defaultNetWorking] requestPostAddress:kRemoveDirFileUrl andPostParameters:params andBlock:^(NSDictionary *dict) {
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
        NSString *p;
        if (self.filePath.length > 0) {
            p = [NSString stringWithFormat:@"%@/%@/%@",kUpfileUrl,self.filePath,imageName];
        }
        else {
            p = [NSString stringWithFormat:@"%@/%@",kUpfileUrl,imageName];
        }
        
        [[NetWorking defaultNetWorking] uploadingAddress:p data:UIImagePNGRepresentation(img) fileName:imageName andProgress:^(NSProgress *progress) {
            
        } andBlock:^(NSDictionary *dict) {
            FLog(@"%@", dict);
            if ([[dict objectForKey:@"result"] isEqual:@"0"]) {
                [self getFileList:self.filePath isRefresh:YES];
            }
            else {
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
                [self showTool:@"上传失败" view:self.navigationController.view];
            }
        } andFailDownload:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
            [self showTool:@"上传失败" view:self.navigationController.view];
        }];
        
    } failureBlock:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
    }];
    
}

@end
