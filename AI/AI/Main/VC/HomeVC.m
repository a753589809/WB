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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    XTSoundPlayer *player = [XTSoundPlayer standardSoundPlayer];
//    [player play:@"设置语速"];
    
//    SceneRecognitionVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SceneRecognitionVC"];
//    [self.navigationController pushViewController:vc animated:YES];
    
    [[NetWorking defaultNetWorking] uploadingAddress:@"/update" andFile:@"model_dog.tar.gz" andProgress:^(NSProgress *progress) {
        
    } andBlock:^(NSDictionary *dict) {
        
    } andFailDownload:^{
        
    }];
}

@end

