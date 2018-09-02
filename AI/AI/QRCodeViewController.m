//
//  QRCodeViewController.m
//  kaixingou
//
//  Created by xuting on 15/8/4.
//  Copyright (c) 2015年 kaixingou. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIViewExt.h"

#define SCANVIEW_EdgeTop 40.0
#define SCANVIEW_EdgeLeft 50.0
#define TINTCOLOR_ALPHA 0.2 //浅色透明度
#define DARKCOLOR_ALPHA 0.5 //深色透明度
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate> {
    
    UIView *_QrCodeline;
    NSTimer *_timer;
    //设置扫描画面
    UIView *_scanView;
    UIImageView *scanCropView;
    
    NSString *_symbolStr;
    
    BOOL _hasCodeNotHandle;  //是否有二维码没有处理
}

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation QRCodeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _hasCodeNotHandle = NO;
    }
    return self;
}

- ( void )viewDidLoad {
    
    [ super viewDidLoad ];
    
    [self initQRcode];
    
    [self initUI];
    
}

-(UILabel*)createLabelWithFrame:(CGRect)frame font:(UIFont *)font title:(NSString*)title color:(UIColor *)color
{
    
    UILabel*label = [[UILabel alloc]initWithFrame:frame];
    label.numberOfLines  =0;//换几行
    label.text = title;
    label.font = font;
    label.textColor = color;
    
    return label;
}

- (void)initUI {
    
    _scanView = [[UIView alloc] initWithFrame:self.view.bounds];
    _scanView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45];
    [self.view addSubview:_scanView];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [path appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(50, 100, self.view.frame.size.width-100, self.view.frame.size.width-100)] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [_scanView.layer setMask:shapeLayer];
    
    
    //返回按钮
    UIButton *backBt = [UIButton buttonWithType:UIButtonTypeCustom];
    backBt.frame = CGRectMake(0, 64 - 44, 40, 40);
    [backBt setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    [backBt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backBt addTarget:self action:@selector(backBt) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBt];
    
    //    //用于开关灯操作的button
    //    UIButton *openButton=[[UIButton alloc] initWithFrame:CGRectMake (kScreenWidth-50 ,20 ,40 ,40 )];
    ////    openButton.backgroundColor = DARK_GRAY_COLOR;
    //    [openButton setImage:[UIImage imageNamed:@"code_light_off"] forState:UIControlStateNormal];
    //    [openButton setImage:[UIImage imageNamed:@"code_light_on"] forState:UIControlStateSelected];
    //    openButton.titleLabel.textAlignment = NSTextAlignmentCenter ;
    //    [openButton addTarget:self action:@selector(openLight:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview :openButton];
    
    //中间扫描区域
    scanCropView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width-100, self.view.frame.size.width-100)];
    scanCropView.layer.borderColor = [UIColor orangeColor].CGColor;
    scanCropView.layer.borderWidth = 2.0 ;
    scanCropView.backgroundColor = [UIColor clearColor];
    [self.view addSubview :scanCropView];
    
    //画中间的基准线
    _QrCodeline = [[UIView alloc] initWithFrame:CGRectMake(scanCropView.left ,scanCropView.top ,scanCropView.height, 2)];
    _QrCodeline.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_QrCodeline];
    
}

- (void)initQRcode {
    
    // 1. 实例化拍摄设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error;
    // 2. 设置输入设备
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!input) {
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        NSString *message;
        NSString *title;
        
        if(authStatus == AVAuthorizationStatusDenied){
            title = @"NoAutoCamera";
            message = @"OpenAuthorityCamera";
        }
        else {
            title = @"";
            message = @"CanNotUseCamera";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Know" otherButtonTitles:nil, nil];
        alert.tag = 2016;
        [alert show];
        
        return;
        
    }
    
    // 3. 设置元数据输出
    // 3.1 实例化拍摄元数据输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 3.3 设置输出数据代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 3.4 设置扫描区域
//    [output setRectOfInterest:CGRectMake (100/self.view.frame.size.height, 50/self.view.frame.size.width, (self.view.frame.size.width - 100)/self.view.frame.size.height, (self.view.frame.size.width - 100)/self.view.frame.size.width)];
    
    // 4. 添加拍摄会话
    // 4.1 实例化拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 4.2 添加会话输入
    [session addInput:input];
    // 4.3 添加会话输出
    [session addOutput:output];
    [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    // 4.3 设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
//    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    output.metadataObjectTypes = output.availableMetadataObjectTypes;
    self.session = session;
    
    // 5. 视频预览图层
    // 5.1 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.bounds;
    // 5.2 将图层插入当前视图
    [self.view.layer insertSublayer:preview atIndex:100];
    
    self.previewLayer = preview;
    
    // 6. 启动会话
//    [_session startRunning];
    
}

- ( void )viewWillDisappear:( BOOL )animated {

    [ super viewWillDisappear :animated];
    [self stopTimer];
    _hasCodeNotHandle = YES;
    [_session stopRunning];
    
}

- ( void )viewWillAppear:( BOOL )animated {

    [super viewWillAppear:animated];
    
    _hasCodeNotHandle = NO;
    [_session startRunning];
    [self createTimer];
    
}


#pragma mark - 事件 -
//返回
- (void)backBt {
    [self.navigationController popViewControllerAnimated:YES];
}


//二维码的横线移动
- ( void )moveUpAndDownLine {
    
    _QrCodeline.top = scanCropView.top;
    [UIView animateWithDuration:1.9 animations:^{
        self->_QrCodeline.top = self->scanCropView.bottom-2;
    }];
    
}

- ( void )createTimer {
    
    [self moveUpAndDownLine];
    //创建一个时间计数
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats:YES];
    
}

- ( void )stopTimer {
    
    if ([_timer isValid] == YES ) {
        [_timer invalidate];
        _timer = nil ;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
//    if (buttonIndex == 1) {
//
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_symbolStr]];
//        [self performSelector:@selector(setHasCodeNotHandle) withObject:nil afterDelay:0.3];
//
//    }
//    else {
//        if (alertView.tag == 2016) {
//            [self backBt];
//        }
        _hasCodeNotHandle = NO;
//    }
    
}

- (void)setHasCodeNotHandle {
    _hasCodeNotHandle = NO;
}

#pragma mark -- ZBarReaderViewDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSLog(@"==============");
    if (_hasCodeNotHandle) {
        return;
    }
    
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0) {
            
            _hasCodeNotHandle = YES;
            
            _symbolStr = obj.stringValue;
            
            NSString *s = [_symbolStr stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            
            NSLog(@"%@",s);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:s delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            //{"ssid":"BOJINGnet-B1787","password":"12345678"}
            
        }
        
    }
    
}


@end
