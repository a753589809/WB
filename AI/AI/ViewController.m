//
//  ViewController.m
//  AI
//
//  Created by xuting on 2018/8/31.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"
#import "ScanViewController.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ImageHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoViewController.h"

#define kCreateAlert(title) UIAlertView *_alertView11 = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];\
[_alertView11 show];

@interface ViewController()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate> {
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UILabel *msgLabel;
    __weak IBOutlet UITextField *regiestNameField;
    BOOL isRegist;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    regiestNameField.delegate = self;
    
}

- (IBAction)shootVideo:(id)sender {
    VideoViewController *video = [[VideoViewController alloc] init];
    [self.navigationController pushViewController:video animated:YES];
}

- (IBAction)qrcode:(id)sender {
//    QRCodeViewController *vc = [[QRCodeViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
    
    // 创建将要连接的WIFI配置实例
//    if (@available(iOS 11.0, *)) {
//        NEHotspotConfiguration * hotspotConfig = [[NEHotspotConfiguration alloc] initWithSSID:@"BOJINGnet-B1787" passphrase:@"12345678" isWEP:NO];
//        // 开始连接 (调用此方法后系统会自动弹窗确认)
//        [[NEHotspotConfigurationManager sharedManager] applyConfiguration:hotspotConfig completionHandler:^(NSError * _Nullable error) {
//            NSLog(@"%@", error);
//        }];
//    } else {
//        // Fallback on earlier versions
//    }
    isRegist = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选择", nil];
    [actionSheet showInView:self.view];
    
}

- (IBAction)clickRegiest:(id)sender {
    isRegist = YES;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选择", nil];
    [actionSheet showInView:self.view];
}

- (void)recognitionImage:(UIImage *)image {
    
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
    NSData *data = [NSData dataWithBytes:bitmap length:224*224*3];
    free(bitmap);
    
    NSString *name;
    if (isRegist) {
        name = regiestNameField.text;
    }
    
    [ImageHelper postImage:data name:name callback:^(BOOL success, NSDictionary *dic, NSError *error) {
        if (success) {
            NSLog(@"%@",dic);
            self->msgLabel.text = dic[@"name"];
        }
        else {
            NSLog(@"%@",error);
        }
    }];
    
}


#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerControllerSourceType rceType;
    //拍照
    if (buttonIndex == 0) {
        
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        
        if(authStatus == AVAuthorizationStatusNotDetermined){
            
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if(granted){//点击允许访问时调用
                    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
                    if (!isCamera) {
                        kCreateAlert(@"此设备没有摄像头");
                    }
                    else {
                        UIImagePickerController *pickerVC = [[UIImagePickerController alloc]init];
                        pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
                        pickerVC.delegate = self;
                        [self presentViewController:pickerVC animated:YES completion:nil];
                    }
                    
                }
            }];
            
        }
        else if(authStatus == AVAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在\"设置->隐私->相机\"中允许访问相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        else {
            
            BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
            if (!isCamera) {
                kCreateAlert(@"此设备没有摄像头");
                return;
            }
            
            UIImagePickerController *pickerVC = [[UIImagePickerController alloc]init];
            pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerVC.delegate = self;
            [self presentViewController:pickerVC animated:YES completion:nil];
            
        }
        
    }
    //选择相册
    else if (buttonIndex == 1) {
        
        rceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.sourceType = rceType;
        imagePicker.delegate = self;
        imagePicker.navigationBar.translucent = NO; //关闭半透明
        //        [imagePicker.navigationBar setBarTintColor:RED_COLOR];
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    
}


#pragma mark - UIImagePickerController delegate
//选择了一个照片、拍完一个照照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //1.关闭相册控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if (img == nil)
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    imageView.image = img;
    [self recognitionImage:img];
    
}


#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
