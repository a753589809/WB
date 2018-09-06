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
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kScreenWidth / 2 - 0.5, kScreenWidth / 2);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [self.collectionView setCollectionViewLayout:layout];
    
    NSArray *titleArray = @[@"狗狗品种",@"场景识别",@"手相",@"面相",@"发型指导",@"明星脸"];
    NSArray *imageArray = @[@"icon-dog",@"icon-scene",@"icon-hand",@"icon-Physiognomy",@"icon-hair",@"icon-face"];
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
    XTSoundPlayer *player = [XTSoundPlayer standardSoundPlayer];
    [player play:@"哈哈"];
}

@end

