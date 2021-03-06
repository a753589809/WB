//
//  ViewController.m
//  AI
//
//  Created by xuting on 2018/8/31.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "ViewController.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ImageHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "XTSoundPlayer.h"

#define kCreateAlert(title) UIAlertView *_alertView11 = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];\
[_alertView11 show];

@interface ViewController()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate> {

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
    
    XTSoundPlayer *player;
    NSTimer *_timer;
    
    BOOL isRequest;
    BOOL isUploadImage;
    
    NSArray *_faceArray;
    
    UIView *_v;
}

@end

@implementation ViewController

- (void)dealloc
{
    [player stop];
    player = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isUploadImage = YES;
    typeLabel.text = self.model.title;
    topImageView.hidden = YES;
    _changeButton.hidden = YES;
    containerHeight.constant = kScreenWidth - 80 + 60;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBgView:)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([_timer isValid] == YES ) {
        [_timer invalidate];
        _timer = nil ;
    }
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
    if ([_timer isValid] == YES ) {
        [_timer invalidate];
        _timer = nil ;
    }
}

// 拍照
- (IBAction)clickTakePhotos:(id)sender {
    if ([_timer isValid] == YES ) {
        [_timer invalidate];
        _timer = nil ;
    }
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
        
        AVCaptureMetadataOutput *metaOutput = [[AVCaptureMetadataOutput alloc] init];//创建一个视频数据输出流
        dispatch_queue_t queue1 = dispatch_queue_create("myQueue1", NULL);
        [metaOutput setMetadataObjectsDelegate:self queue:queue1];
        //        metaOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
        //        rectOfInterest 需要设置这个
#warning xt_gg
        
        
        
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];//创建一个视频数据输出流
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        [output setSampleBufferDelegate:self queue:queue];
        output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                nil];
        
        
        
        
        session = [[AVCaptureSession alloc] init];//负责输入和输出设置之间的数据传递
        session.sessionPreset = AVCaptureSessionPresetHigh;//设置分辨率
        
        [session beginConfiguration];
        [session addInput:input];
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
        if ([session canAddOutput:metaOutput]) {
            [session addOutput:metaOutput];
        }
        [session commitConfiguration];
        
        metaOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
        
        preLayer = [AVCaptureVideoPreviewLayer layerWithSession: session];//相机拍摄预览图层
        preLayer.frame = topImageBgView.bounds;
//        preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        preLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    
    [topImageBgView.layer addSublayer:preLayer];
    [session startRunning];
    _changeButton.hidden = NO;
    topImageView.hidden = YES;
    [topImageBgView addGestureRecognizer:_tap];
    
    if ([_timer isValid] == YES ) {
        [_timer invalidate];
        _timer = nil ;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(uploadImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
}

- (void)uploadImage {
    isUploadImage = YES;
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
    
    // 当设置完成之后，需要回调到上面那个方法
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
    if (isRequest || [player isSpeaking] || !isUploadImage) {
//        return;
    }
    isRequest = YES;
    isUploadImage = NO;
    
    UIImage *oldImage = [self imageFromSampleBuffer:sampleBuffer];
    
//    CGFloat x = (oldImage.size.height - oldImage.size.width) / 2;
//    CGRect frame = CGRectMake(x, 0, oldImage.size.width, oldImage.size.width);
//    CGImageRef imageRef = CGImageCreateWithImageInRect(oldImage.CGImage, frame);
//    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:oldImage.scale orientation:oldImage.imageOrientation];
//    CGImageRelease(imageRef);
    
//    if ([self.model.ID isEqual:@"57"] || [self.model.ID isEqual:@"63"]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self dettectFaceWithImage:newImage isShow:NO];
//        });
//    }
//    else {
//        [self recognitionImage:newImage isShowHUD:NO];
//    }
    
    
    if (_faceArray.count > 0) {
        for (AVMetadataFaceObject *obj in _faceArray) {
            if ([obj isKindOfClass:[AVMetadataFaceObject class]]) {
                AVMetadataObject *data = [captureOutput transformedMetadataObjectForMetadataObject:obj connection:connection];
//                NSLog(@"%@", NSStringFromCGRect(data.bounds));
                
//                CGFloat scale = MIN(topImageView.width / oldImage.size.width, topImageView.height / oldImage.size.height);
//                CGFloat offsetX = (topImageView.width - oldImage.size.width * scale) / 2;
//                CGFloat offsetY = (topImageView.height - oldImage.size.height * scale) / 2;
//                CGFloat y = oldImage.size.height - data.bounds.size.height - data.bounds.origin.y;
//                CGRect frame = CGRectMake(data.bounds.origin.x * scale + offsetX, y * scale + offsetY, data.bounds.size.width * scale, data.bounds.size.height * scale);
                
//                CGFloat scale1 = MIN(topImageView.width / oldImage.size.width, topImageView.height / oldImage.size.height);
//                CGFloat offsetX = (topImageView.width - oldImage.size.width * scale1) / 2;
//                CGFloat offsetY = (topImageView.height - oldImage.size.height * scale1) / 2;
                
                
                CGFloat scale = oldImage.size.height / preLayer.bounds.size.height;
                CGFloat offsetX = (topImageView.width - oldImage.size.width / scale) / 2;
                CGFloat w = data.bounds.size.height / scale;
                CGFloat h = data.bounds.size.width / scale;
                CGFloat x = (oldImage.size.width - data.bounds.size.height - data.bounds.origin.y) / scale + offsetX;
//                CGFloat y = (oldImage.size.height - data.bounds.size.width - data.bounds.origin.x) / scale;
//                CGFloat x = data.bounds.origin.y / scale + offsetX;
                CGFloat y = data.bounds.origin.x / scale;
                CGRect frame = CGRectMake(x, y, w, h);
//                NSLog(@"%@===%@", NSStringFromCGRect(frame),NSStringFromCGRect(data.bounds));
                
                
                if (data.bounds.origin.x < 0 || data.bounds.origin.y < 0) {
                    NSLog(@"%@", NSStringFromCGRect(data.bounds));
                }
                
                
//                if (!rahmenView) {
//                    rahmenView = [[CALayer alloc] init];
//                    rahmenView.borderColor = [UIColor redColor].CGColor;
//                    rahmenView.borderWidth = 2.0f;
//                    [topImageBgView.layer insertSublayer:rahmenView above:preLayer];
//                    rahmenView.frame = frame;
//                }
                
//                NSLog(@"%@===%@", NSStringFromCGSize(oldImage.size), NSStringFromCGRect(data.bounds));
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (!self->_v) {
//                        self->_v = [[UIView alloc] init];
//                        self->_v.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
//                        [self->topImageView addSubview:self->_v];
//                    }
//                    self->_v.frame = frame;
                    
                    if (!self->rahmenView) {
                        self->rahmenView = [[CALayer alloc] init];
                        self->rahmenView.borderColor = [UIColor redColor].CGColor;
                        self->rahmenView.borderWidth = 2.0f;
                        [self->topImageBgView.layer insertSublayer:self->rahmenView above:self->preLayer];
                    }
                    self->rahmenView.hidden = NO;
                    self->rahmenView.frame = frame;
                });
                
                break;
            }
        }
        _faceArray = nil;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->rahmenView.hidden = YES;
        });
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


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    _faceArray = metadataObjects;
}


#pragma mark - 图片处理
- (void)recognitionImage:(UIImage *)image isShowHUD:(BOOL)isShowHUD {
//    image = [self rotateWithImage:image];
    image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
    
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
    NSData *data = [NSData dataWithBytes:bitmap length:224*224*3];
    free(bitmap);
    
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
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIImageView *imgV = (UIImageView *)[self.view viewWithTag:111];
//        if (!imgV) {
//            imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 500, 100, 100)];
//            imgV.tag = 111;
//            imgV.contentMode = UIViewContentModeScaleAspectFit;
//            imgV.backgroundColor = [UIColor redColor];
//            [self.view addSubview:imgV];
//        }
//        imgV.image = image;
//    });
    
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
            if (!player) {
                player = [XTSoundPlayer standardSoundPlayer];
            }
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
    
    
    //CIImage -> CGImageRef -> UIImage
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);  //拿到缓冲区帧数据
//    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];            //创建CIImage对象
//    CIContext *temporaryContext = [CIContext contextWithOptions:nil];           //创建上下文
//    CGImageRef cgImageRef = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
//    UIImage *result = [[UIImage alloc] initWithCGImage:cgImageRef scale:1.0 orientation:UIImageOrientationLeftMirrored];  //创建UIImage对象
//    CGImageRelease(cgImageRef);  //释放上下文 
//    return result;
    
    
}

// 人脸识别
-(void)dettectFaceWithImage:(UIImage *)faceImage isShow:(BOOL)isShow {
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    CIImage *ciimage = [CIImage imageWithCGImage:faceImage.CGImage];
    NSArray *featrues = [detector featuresInImage:ciimage];
    
    if(featrues.count > 0) {
        CIFaceFeature *face = [featrues firstObject];
        FLog(@"=====%@====%@", NSStringFromCGSize([ciimage extent].size),NSStringFromCGRect(face.bounds));
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

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)rotateWithImage:(UIImage *)aImage {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
