//
//  HomeVC.m
//  AI
//
//  Created by xuting on 2018/9/5.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "HomeVC.h"
#import "HomeCell.h"
#import "HomeModel.h"
#import "XTSoundPlayer.h"
#import "ConnectSuccessVC.h"
#import "SceneRecognitionVC.h"
#import "NetWorking.h"
#import "ViewController.h"
#import "FileModel.h"
#import "FileViewController.h"
#import "QRCodeViewController.h"

#define kCellSpaing 15

@interface HomeVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation HomeVC

- (void)viewDidLoad {
    self.showMenuButton = YES;
    [super viewDidLoad];
    
    self.data = [NSMutableArray array];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(kCellSpaing, kCellSpaing, 0, kCellSpaing);
    CGFloat w = (kScreenWidth - 3 * kCellSpaing) / 2 - 1;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(w, w);
    layout.minimumLineSpacing = kCellSpaing;
    layout.minimumInteritemSpacing = kCellSpaing;
    [self.collectionView setCollectionViewLayout:layout];
    
    NSArray *titleArray = @[L(@"无线U盘"),L(@"明星脸"),L(@"夫妻相"),L(@"狗狗品种"),L(@"花")];
    NSArray *imageArray = @[@"icon-usb",@"icon-face copy",@"icon-Physiognomy Copy",@"icon-dog copy",@"icon-flower"];
    NSArray *colorArray = @[@"007FEF",@"E84C3C",@"F5B908",@"00BA9A",@"1BB7F0"];
    NSArray *modelNameArray = @[@"",@"model_celebrities_v0.00001",@"model_couples_v0.00001",@"model_dog_v0.00001",@"model_flowers_v0.00002"];
    NSArray *modelIdArray = @[@"0",@"57",@"63",@"55",@"64"];
    
//    NSArray *titleArray = @[L(@"明星脸"),L(@"夫妻相"),L(@"狗狗品种"),L(@"花")];
//    NSArray *imageArray = @[@"icon-face copy",@"icon-Physiognomy Copy",@"icon-dog copy",@"icon-flower"];
//    NSArray *colorArray = @[@"E84C3C",@"F5B908",@"00BA9A",@"1BB7F0"];
//    NSArray *modelNameArray = @[@"model_celebrities_v0.00001",@"model_couples_v0.00001",@"model_dog_v0.00001",@"model_flowers_v0.00001"];
//    NSArray *modelIdArray = @[@"57",@"63",@"55",@"64"];
    
    for (int i=0; i<titleArray.count; i++) {
        HomeModel *model = [[HomeModel alloc] init];
        model.title = [titleArray objectAt:i];
        model.imageName = [imageArray objectAt:i];
        model.color = [colorArray objectAt:i];
        model.modelName = [modelNameArray objectAt:i];
        model.ID = [modelIdArray objectAt:i];
        [self.data addObject:model];
    }
    [self.collectionView reloadData];
}


#pragma mark - delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCell" forIndexPath:indexPath];
    HomeModel *model = [self.data objectAt:indexPath.item];
    cell.model = model;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeModel *model = [self.data objectAt:indexPath.item];
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.model = model;
    vc.showMenuButton = YES;
    [self.navigationController pushViewController:vc animated:true];
//    QRCodeViewController *code = [[QRCodeViewController alloc] init];
//    [self.navigationController pushViewController:code animated:YES];
    return;
    
    
    if (!model) {
        return;
    }
    if ([model.ID isEqualToString:@"0"]) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
        [[NetWorking defaultNetWorking] requestAddress:kDownlistUrl andPostParameters:nil andBlock:^(NSDictionary *dict) {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
            FileViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FileViewController"];
            vc.fileArray = [FileModel getFileArrayWith:dict];
            vc.filePath = @"";
            [self.navigationController pushViewController:vc animated:true];
            FLog(@"%@",dict);
        } andFailDownload:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
            [self showTool:@"U盘读取失败" view:self.navigationController.view];
        }];
    }
    else {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
        [[NetWorking defaultNetWorking] requestAddress:[NSString stringWithFormat:@"%@/%@",kCheckmodelversionUrl, model.modelName] andPostParameters:nil andBlock:^(NSDictionary *dict) {
            
            if ([[dict objectForKey:@"result"] isEqual:@"0"]) {
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
                ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
                vc.model = model;
                vc.showMenuButton = YES;
                [self.navigationController pushViewController:vc animated:true];
            }
            else {
                // 传模型文件
                [[NetWorking defaultNetWorking] uploadingAddress:[NSString stringWithFormat:@"%@/%@",kUpdateUrl, model.modelName] andFile:[NSString stringWithFormat:@"%@.tar", model.modelName] andProgress:^(NSProgress *progress) {
                    FLog(@"%@", progress);
                } andBlock:^(NSDictionary *dict) {
                    FLog(@"%@", dict);
                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
                    if ([[dict objectForKey:@"result"] isEqual:@"0"]) {
                        ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
                        vc.showMenuButton = YES;
                        vc.model = model;
                        [self.navigationController pushViewController:vc animated:true];
                    }
                    else {
                        [self showTool:@"模型上传失败" view:self.navigationController.view];
                    }
                } andFailDownload:^{
                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
                    [self showTool:@"模型上传失败" view:self.navigationController.view];
                }];
            }
            
            FLog(@"%@",dict);
        } andFailDownload:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
            [self showTool:@"模型检测失败" view:self.navigationController.view];
        }];
    }
    
}

@end

