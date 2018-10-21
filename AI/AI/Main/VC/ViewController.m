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
#import "XTSoundPlayer.h"

#define kCreateAlert(title) UIAlertView *_alertView11 = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];\
[_alertView11 show];

@interface ViewController()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate> {

    __weak IBOutlet UILabel *typeLabel;
    __weak IBOutlet UIView *topImageBgView;
    __weak IBOutlet UIImageView *topImageView;
    __weak IBOutlet UIImageView *topDefaultImageView;
    __weak IBOutlet UILabel *topTipsLabel;
    __weak IBOutlet UIImageView *bottomImageView;
    __weak IBOutlet UILabel *resultLabel;
    __weak IBOutlet UIButton *_changeButton;
    
    __weak IBOutlet NSLayoutConstraint *bottomImageViewHeigth;
    __weak IBOutlet NSLayoutConstraint *containerHeight;
    
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *preLayer;
    AVCaptureDeviceInput *input;
    
    CALayer *rahmenView;
    
    UITapGestureRecognizer *_tap;
    
    BOOL isRequest;
    
}

@end

@implementation ViewController

- (void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    typeLabel.text = self.model.title;
    topImageView.hidden = YES;
    _changeButton.hidden = YES;
    containerHeight.constant = kScreenWidth - 80 + 60;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBgView:)];
}

// 相册
- (IBAction)clickPhotoAlbum:(id)sender {
    UIImagePickerControllerSourceType rceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = rceType;
    imagePicker.delegate = self;
    imagePicker.navigationBar.translucent = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    if (session && session.isRunning) {
        [session stopRunning];
        [preLayer removeFromSuperlayer];
    }
    topImageView.hidden = false;
    _changeButton.hidden = YES;
    [topImageBgView removeGestureRecognizer:_tap];
}

// 拍照
- (IBAction)clickTakePhotos:(id)sender {
    
    if (session && session.isRunning) {
        [session stopRunning];
        [preLayer removeFromSuperlayer];
    }
    topImageView.hidden = false;
    _changeButton.hidden = YES;
    [topImageBgView removeGestureRecognizer:_tap];
    
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

// 实况
- (IBAction)clickVideo:(id)sender {
    
//    VideoViewController *v = [[VideoViewController alloc] init];
//    [self.navigationController pushViewController:v animated:YES];
//    return;
    
    
    if (!session) {
        NSError *error = nil;
        session = [[AVCaptureSession alloc] init];//负责输入和输出设置之间的数据传递
        session.sessionPreset = AVCaptureSessionPresetHigh;//设置分辨率
        AVCaptureDevice *device = [AVCaptureDevice
                                   defaultDeviceWithMediaType:AVMediaTypeVideo];//这里默认是使用后置摄像头，你可以改成前置摄像头
        input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        
        float frameRate = 15;
        for(AVCaptureDeviceFormat *vFormat in [device formats] ) {
            CMFormatDescriptionRef description= vFormat.formatDescription;
            float maxRate = ((AVFrameRateRange*) [vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
            if (maxRate > frameRate - 1 && CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                if ([device lockForConfiguration:nil]) {
                    device.activeFormat = vFormat;
                    [device setActiveVideoMinFrameDuration:CMTimeMake(10, frameRate * 10)];
                    [device setActiveVideoMaxFrameDuration:CMTimeMake(10, frameRate * 10)];
                    [device unlockForConfiguration];
                    break;
                }
            }
        }
        [session addInput:input];
        
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];//创建一个视频数据输出流
        [session addOutput:output];
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        [output setSampleBufferDelegate:self queue:queue];
        //    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
        //                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
        //                            [NSNumber numberWithInt: 375], (id)kCVPixelBufferWidthKey,
        //                            [NSNumber numberWithInt: 375], (id)kCVPixelBufferHeightKey,
        //                            nil];
        output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                nil];
        preLayer = [AVCaptureVideoPreviewLayer layerWithSession: session];//相机拍摄预览图层
        preLayer.frame = topImageBgView.bounds;
        preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    [topImageBgView.layer addSublayer:preLayer];
    [session startRunning];
    _changeButton.hidden = NO;
    topImageView.hidden = YES;
    [topImageBgView addGestureRecognizer:_tap];
}

#pragma mark - 摄像头处理
- (IBAction)swapFrontAndBackCameras:(id)sender {
    
    NSArray *inputs = session.inputs;
    for (AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera =nil;
            AVCaptureDeviceInput *newInput =nil;
            
            if (position ==AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            [session beginConfiguration];
            [session removeInput:input];
            [session addInput:newInput];
            [session commitConfiguration];
            break;
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)clickBgView:(UITapGestureRecognizer *)tap {
    CGPoint p = [tap locationInView:topImageBgView];
    [self cameraDidSelected:p];
}

//更改设备属性前一定要锁上
-(void)changeDevicePropertySafety:(void (^)(AVCaptureDevice *captureDevice))propertyChange{
    //也可以直接用_videoDevice,但是下面这种更好
    AVCaptureDevice *captureDevice= [input device];
    //AVCaptureDevice *captureDevice= self.device;
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁,意义是---进行修改期间,先锁定,防止多处同时修改
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        NSLog(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
    }else{
        [session beginConfiguration];
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        [session commitConfiguration];
    }
}

// 点击屏幕，触发聚焦
- (void)cameraDidSelected:(CGPoint)point {
    
    // 当设置完成之后，需要回调到上面那个方法⬆️
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        
        // 触摸屏幕的坐标点需要转换成0-1，设置聚焦点
        CGPoint cameraPoint= [self->preLayer captureDevicePointOfInterestForPoint:point];
        
        /*****必须先设定聚焦位置，在设定聚焦方式******/
        //聚焦点的位置
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:cameraPoint];
        }
        
        // 聚焦模式
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }else{
            NSLog(@"聚焦模式修改失败");
        }
        
        //曝光点的位置
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:cameraPoint];
        }
        
        //曝光模式
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }else{
            NSLog(@"曝光模式修改失败");
        }
        
    }];
    
}


#pragma mark - UIImagePickerController delegate
//选择了一个照片、拍完一个照照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //1.关闭相册控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if (img == nil)
        img = [info objectForKey:UIImagePickerControllerOriginalImage];

    topImageView.image = img;
    topImageView.hidden = NO;
    topDefaultImageView.hidden = YES;
    topTipsLabel.hidden = YES;
    topImageBgView.backgroundColor = [UIColor clearColor];
    
    if ([self.model.ID isEqual:@"57"] || [self.model.ID isEqual:@"63"]) {
        [self dettectFaceWithImage:img isShow:YES];
    }
    else {
        [self recognitionImage:img isShowHUD:YES];
    }
    
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    if (isRequest) {
        return;
    }
    isRequest = YES;
    
    UIImage *oldImage = [self imageFromSampleBuffer:sampleBuffer];
    
    CGFloat x = (oldImage.size.height - oldImage.size.width) / 2;
    CGRect frame = CGRectMake(x, 0, oldImage.size.width, oldImage.size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect(oldImage.CGImage, frame);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:oldImage.scale orientation:oldImage.imageOrientation];
    CGImageRelease(imageRef);
    
    if ([self.model.ID isEqual:@"57"] || [self.model.ID isEqual:@"63"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dettectFaceWithImage:newImage isShow:NO];
        });
    }
    else {
        [self recognitionImage:newImage isShowHUD:NO];
    }
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIImageView *imgV = (UIImageView *)[self.view viewWithTag:111];
//        if (!imgV) {
//            imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 500, 100, 100)];
//            imgV.tag = 111;
//            imgV.contentMode = UIViewContentModeScaleAspectFit;
//            imgV.backgroundColor = [UIColor redColor];
//            [self.view addSubview:imgV];
//        }
//        imgV.image = newImage;
//    });
    
}


#pragma mark - 图片处理
- (void)recognitionImage:(UIImage *)image isShowHUD:(BOOL)isShowHUD {
    
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
    NSData *data = [NSData dataWithBytes:bitmap length:224*224*3];
    free(bitmap);
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    
//    NSMutableString * path = [[NSMutableString alloc]initWithString:documentsDirectory];
//    [path appendString:@"/fuck"];
//    
//    [data writeToFile:path atomically:YES];
//
//    return;
    
    NSArray *a = [self.model.modelName componentsSeparatedByString:@"_v"];
    if (isShowHUD) {
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showHUDAddedTo:self.view animated:true];
            });
        }
        else {
            [MBProgressHUD showHUDAddedTo:self.view animated:true];
        }
    }
    __weak ViewController *weakSelf = self;
    [ImageHelper postImage:data modelName:a.firstObject name:nil callback:^(BOOL success, NSDictionary *dic, NSError *error) {
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf handleData:dic success:success];
            });
        }
        else {
            [weakSelf handleData:dic success:success];
        }
    }];
    
}

- (void)handleData:(NSDictionary *)dic success:(BOOL)success {
    if (success) {
        FLog(@"%@",dic);
        NSString *name = @"";
        NSArray *nameArray = [dic[@"name"] componentsSeparatedByString:@" "];
        if (nameArray.count >= 2) {
            name = nameArray[1];
        } else if (nameArray.count == 1) {
            name = nameArray[0];
        }
        
        self->resultLabel.text = name;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:VOICEKEY]) {
            XTSoundPlayer *player = [XTSoundPlayer standardSoundPlayer];
            [player play:name];
        }
        
        if ([self.model.ID isEqual:@"63"]) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", name]];
            if (!image) {
                image = [UIImage imageNamed:@"pic-icon"];
            }
            self->bottomImageView.image = image;
            if (self->bottomImageViewHeigth.constant != self->bottomImageView.width) {
                self->bottomImageViewHeigth.constant = self->bottomImageView.width;
                self->containerHeight.constant = self->containerHeight.constant + self->bottomImageView.width;
            }
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
    }
    else {
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        [self showTool:@"图片识别失败" view:self.navigationController.view];
    }
    self->isRequest = NO;
    
}

- (NSData *)dataFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    //    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    size_t width = 224;
    size_t height = 224;
    size_t bytesPerRow = width * 4;
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    //    // Create a Quartz image from the pixel data in the bitmap graphics context
    //    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    //    // Unlock the pixel buffer
    //    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    //
    //    // Free up the context and color space
    //    CGContextRelease(context);
    //    CGColorSpaceRelease(colorSpace);
    //
    //    // Create an image object from the Quartz image
    //    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    //
    //    // Release the Quartz image
    //    CGImageRelease(quartzImage);
    //
    //    return (image);
    
    
    if(!context) {
        return NULL;
    }
    
    //    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    //    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
    
    //    for (int i=0; i<100*4; i++) {
    //        NSLog(@"%u",bitmapData[i]);
    //    }
    
    // Copy the data and release the memory (return memory allocated with new)
    //    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;
    
    unsigned char *newBitmap = NULL;
    
    if(bitmapData) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * 224*224*3);
        
        if(newBitmap) {    // Copy the data
            for(int i = 0; i < bufferLength / 4; ++i) {
                newBitmap[i] = bitmapData[i*4+2];
                newBitmap[i+50176] = bitmapData[i*4+1];
                newBitmap[i+100352] = bitmapData[i*4];
                NSLog(@"%u==%u==%u",bitmapData[i*4],bitmapData[i*4+1],bitmapData[i*4+2]);
            }
        }
        
        //        free(bitmapData);
        
    } else {
        NSLog(@"Error getting bitmap pixel data\n");
    }
    
    CGContextRelease(context);
    
    NSData *data = [NSData dataWithBytes:newBitmap length:224*224*3];
    
    return data;
}


// Create a UIImage from sample buffer data
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    //    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(quartzImage);
    
    return (image);
}

// 人脸识别
-(void)dettectFaceWithImage:(UIImage *)faceImage isShow:(BOOL)isShow {
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    CIImage *ciimage = [CIImage imageWithCGImage:faceImage.CGImage];
    NSArray *featrues = [detector featuresInImage:ciimage];
    
    if(featrues.count > 0) {
        CIFaceFeature *face = [featrues firstObject];
        FLog(@"=====%@====%@", NSStringFromCGSize(faceImage.size),NSStringFromCGRect(face.bounds));
        CGFloat scale = MIN(topImageView.width / faceImage.size.width, topImageView.height / faceImage.size.height);
        CGFloat offsetX = (topImageView.width - faceImage.size.width * scale) / 2;
        CGFloat offsetY = (topImageView.height - faceImage.size.height * scale) / 2;
        CGFloat y = faceImage.size.height - face.bounds.size.height - face.bounds.origin.y;
        CGRect frame = CGRectMake(face.bounds.origin.x * scale + offsetX, y * scale + offsetY, face.bounds.size.width * scale, face.bounds.size.height * scale);
        if (!rahmenView) {
            rahmenView = [[CALayer alloc] init];
            rahmenView.borderColor = [UIColor redColor].CGColor;
            rahmenView.borderWidth = 2.0f;
        }
        if (preLayer.superlayer) {
            [preLayer addSublayer:rahmenView];
        }
        else {
            [topImageView.layer addSublayer:rahmenView];
        }
        rahmenView.hidden = NO;
        rahmenView.frame = frame;
        
        UIImage *newImage = [self cropImg:faceImage rect:face.bounds];
        [self recognitionImage:newImage isShowHUD:isShow];
    }
    else {
        rahmenView.hidden = YES;
        isRequest = NO;
        
        if (isShow) {
            resultLabel.text = @"";
            bottomImageView.image = nil;
            [self showTool:@"没有识别出人脸" view:self.navigationController.view];
        }
        else {
//            [self showTool:@"没有识别出人脸" view:self.navigationController.view];
        }
    }
    
}

-(UIImage *)cropImg:(UIImage *)image rect:(CGRect)rect {
    CGFloat y = image.size.height - rect.origin.y - rect.size.height;
    CGRect frame = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, frame);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return newImage;
    
}

@end
