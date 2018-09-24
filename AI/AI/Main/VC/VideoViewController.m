//
//  VideoViewController.m
//  AI
//
//  Created by xuting on 2018/9/2.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ImageHelper.h"
#import <AFNetworking.h>

@interface VideoViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate> {
    BOOL isRequest;
    __weak IBOutlet UILabel *msgLabel;
    __weak IBOutlet UIImageView *imageVIew;
}

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCaptureSession];
}

- (void)setupCaptureSession {
    NSError *error = nil;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];//负责输入和输出设置之间的数据传递
    session.sessionPreset = AVCaptureSessionPresetHigh;//设置分辨率
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];//这里默认是使用后置摄像头，你可以改成前置摄像头
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    
    float frameRate = 15;
    for(AVCaptureDeviceFormat *vFormat in [device formats] ) {
        CMFormatDescriptionRef description= vFormat.formatDescription;
        float maxRate = ((AVFrameRateRange*) [vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
        if (maxRate > frameRate - 1 &&
            CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            if ([device lockForConfiguration:nil]) {
                device.activeFormat = vFormat;
                [device setActiveVideoMinFrameDuration:CMTimeMake(10, frameRate * 10)];
                [device setActiveVideoMaxFrameDuration:CMTimeMake(10, frameRate * 10)];
                [device unlockForConfiguration];
                break;
            }
        }
    }
    
    if (!input) {
        
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
    AVCaptureVideoPreviewLayer* preLayer = [AVCaptureVideoPreviewLayer layerWithSession: session];//相机拍摄预览图层
    preLayer.frame = CGRectMake(0, 64, 100, 100);
    preLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:preLayer];
    
//    output.minFrameDuration = CMTimeMake(1, 30);
    
    [session startRunning];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    if (isRequest) {
        return;
    }
    isRequest = YES;
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->imageVIew.image = image;
    });
    
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
    NSData *data = [NSData dataWithBytes:bitmap length:224*224*3];
    free(bitmap);
    
    [ImageHelper postImage:data name:nil callback:^(BOOL success, NSDictionary *dic, NSError *error) {
        if (success) {
            NSLog(@"%@",dic);
            self->msgLabel.text = dic[@"name"];
        }
        else {
            NSLog(@"%@",error);
        }
        self->isRequest = NO;
    }];
    
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

@end
