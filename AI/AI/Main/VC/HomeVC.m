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

#define kCellSpaing 7.5

@interface HomeVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [NSMutableArray array];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(kCellSpaing, kCellSpaing, 0, kCellSpaing);
    CGFloat w = (kScreenWidth - 2 * kCellSpaing) / 2;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(w, w);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [self.collectionView setCollectionViewLayout:layout];
    
    NSArray *titleArray = @[@"狗狗品种",@"场景识别",@"手相",@"面相",@"发型指导",@"明星脸"];
    NSArray *imageArray = @[@"icon-dog-icon",@"icon-dog-icon",@"icon-dog-icon",@"icon-dog-icon",@"icon-dog-icon",@"icon-dog-icon"];
    for (int i=0; i<titleArray.count; i++) {
        HomeModel *model = [[HomeModel alloc] init];
        model.title = [titleArray objectAt:i];
        model.imageName = [imageArray objectAt:i];
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
    
//    http://10.10.10.254:8080/update/model_dog
    [[NetWorking defaultNetWorking] uploadingAddress:@"http://10.10.10.254:8080/update/model_flowers_200" andFile:@"model_flowers.tar" andProgress:^(NSProgress *progress) {
        NSLog(@"%@", progress);
    } andBlock:^(NSDictionary *dict) {
        NSLog(@"%@", dict);
    } andFailDownload:^{
        
    }];
    
    
    
    
    
    
    
    
    
    
//    XTSoundPlayer *player = [XTSoundPlayer standardSoundPlayer];
//    [player play:@"设置语速"];
    
//    SceneRecognitionVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SceneRecognitionVC"];
//    [self.navigationController pushViewController:vc animated:YES];
    
//    [[NetWorking defaultNetWorking] uploadingAddress:@"/update" andFile:@"model_dog.tar.gz" andProgress:^(NSProgress *progress) {
//
//    } andBlock:^(NSDictionary *dict) {
//
//    } andFailDownload:^{
//
//    }];
    
    
//    http://sellingsys.s1.natapp.cc/
//    public final static String serverWeb_IP = "http://192.168.0.6:8080/webPortal";
    
//    [[NetWorking defaultNetWorking] requestAddress:@"http://sellingsys.s1.natapp.cc/webPortal/app/uploadAuthor" andPostParameters:@{} andBlock:^(NSDictionary *dict) {
//        NSLog(@"%@",dict);
//
//        /*
//         {
//         "authorization-key" = "e40eb8ae-e11f-4f37-a451-8aae6dfe9c39";
//         logIndex = "";
//         shrgMsg = "";
//         shrgStatus = S;
//         }
//         */
////        app端根据与服务器约定的 authorization-key+ MD5(authorization-key+PLAINTEXT_KEY) 生成加密后的密钥值//  PLAINTEXT_KEY = "shrgha"
//
//        NSString *key1 = [NSString stringWithFormat:@"%@shrgha",[dict objectForKey:@"authorization-key"]].md5;
//        NSString *key2 = [NSString stringWithFormat:@"%@,%@",[dict objectForKey:@"authorization-key"], key1];
//
//
//        [[NetWorking defaultNetWorking] requestAddress2:@"http://192.168.0.6:8080/webPortal/app/remoteUpload" key:key2 andPostParameters:@{@"fileUuid":@"CAE3BB84820180912183205.tar.gz",@"modelId":@"55"} andBlock:^(NSDictionary *dict) {
//            NSLog(@"%@",dict);
//        } andFailDownload:^{
//
//        }];
//
//    } andFailDownload:^{
//
//    }];
}

@end

