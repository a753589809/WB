/*
 * The MIT License
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ImageHelper.h"
#import <AFNetworking.h>

@implementation ImageHelper


+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image {
	
	CGImageRef imageRef = image.CGImage;
	
	// Create a bitmap context to draw the uiimage into
	CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
	
	if(!context) {
		return NULL;
	}
	
	size_t width = 224;
	size_t height = 224;
	
	CGRect rect = CGRectMake(0, 0, width, height);
	
	// Draw image into the context to get the raw image data
	CGContextDrawImage(context, rect, imageRef);
	
	// Get a pointer to the data	
	unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
	
//    for (int i=0; i<100*4; i++) {
//        NSLog(@"%u",bitmapData[i]);
//    }
    
	// Copy the data and release the memory (return memory allocated with new)
	size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
	size_t bufferLength = bytesPerRow * height;
	
	unsigned char *newBitmap = NULL;
	
	if(bitmapData) {
		newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * 224*224*3);
		
		if(newBitmap) {	// Copy the data
			for(int i = 0; i < bufferLength / 4; ++i) {
				newBitmap[i] = bitmapData[i*4+2];
                newBitmap[i+50176] = bitmapData[i*4+1];
                newBitmap[i+100352] = bitmapData[i*4];
//                NSLog(@"%u==%u==%u",bitmapData[i*4],bitmapData[i*4+1],bitmapData[i*4+2]);
			}
		}
		
		free(bitmapData);
		
	} else {
		NSLog(@"Error getting bitmap pixel data\n");
	}
	
	CGContextRelease(context);
	
	return newBitmap;	
}

+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint32_t *bitmapData;
	
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
	
	size_t width = 224;
	size_t height = 224;
	
	size_t bytesPerRow = width * bytesPerPixel;
	size_t bufferLength = bytesPerRow * height;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if(!colorSpace) {
		NSLog(@"Error allocating color space RGB\n");
		return NULL;
	}
	
	// Allocate memory for image data
	bitmapData = (uint32_t *)malloc(bufferLength);
	
	if(!bitmapData) {
		NSLog(@"Error allocating memory for bitmap\n");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
	
	//Create bitmap context
	context = CGBitmapContextCreate(bitmapData, 
									width, 
									height, 
									bitsPerComponent, 
									bytesPerRow, 
									colorSpace, 
                                    kCGImageAlphaPremultipliedLast);	// RGBA
	
	if(!context) {
		free(bitmapData);
		NSLog(@"Bitmap context not created");
	}
	
	CGColorSpaceRelease(colorSpace);
	
	return context;	
}

+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer 
								withWidth:(int) width
							   withHeight:(int) height {
	
	
	size_t bufferLength = width * height * 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
	size_t bitsPerComponent = 8;
	size_t bitsPerPixel = 32;
	size_t bytesPerRow = 4 * width;
	
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	if(colorSpaceRef == NULL) {
		NSLog(@"Error allocating color space");
		CGDataProviderRelease(provider);
		return nil;
	}
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	CGImageRef iref = CGImageCreate(width, 
									height, 
									bitsPerComponent, 
									bitsPerPixel, 
									bytesPerRow, 
									colorSpaceRef, 
									bitmapInfo, 
									provider,	// data provider
									NULL,		// decode
									YES,			// should interpolate
									renderingIntent);
		
	uint32_t* pixels = (uint32_t*)malloc(bufferLength);
	
	if(pixels == NULL) {
		NSLog(@"Error: Memory not allocated for bitmap");
		CGDataProviderRelease(provider);
		CGColorSpaceRelease(colorSpaceRef);
		CGImageRelease(iref);		
		return nil;
	}
	
	CGContextRef context = CGBitmapContextCreate(pixels, 
												 width, 
												 height, 
												 bitsPerComponent, 
												 bytesPerRow, 
												 colorSpaceRef,
                                                 bitmapInfo);
	
	if(context == NULL) {
		NSLog(@"Error context not created");
		free(pixels);
	}
	
	UIImage *image = nil;
	if(context) {
		
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
		
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
		
		// Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
		if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
			float scale = [[UIScreen mainScreen] scale];
			image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
		} else {
			image = [UIImage imageWithCGImage:imageRef];
		}
		
		CGImageRelease(imageRef);	
		CGContextRelease(context);	
	}
	
	CGColorSpaceRelease(colorSpaceRef);
	CGImageRelease(iref);
	CGDataProviderRelease(provider);
	
	if(pixels) {
		free(pixels);
	}	
	return image;
}

+ (void)postImage:(NSData *)imageData name:(NSString *)name callback:(void(^)(BOOL success, NSDictionary *dic, NSError *error))callback {
    
    NSString *requestUrl = @"http://192.168.8.1:8080";
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:requestUrl parameters:nil error:nil];
    request.timeoutInterval= 30;
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    if (name && name.length > 0) {
        [request setValue:@"face_register" forHTTPHeaderField:@"aitarget"];
        [request setValue:name forHTTPHeaderField:@"namebyface"];
    }
    else {
        [request setValue:@"face_detect" forHTTPHeaderField:@"aitarget"];
    }
    
    // 设置body
    [request setHTTPBody:imageData];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                 @"text/html",
                                                 @"text/json",
                                                 @"text/javascript",
                                                 @"text/plain",
                                                 @"application/octet-stream",
                                                 nil];
    manager.responseSerializer = responseSerializer;
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (responseObject) {
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSMutableDictionary *dic = d.mutableCopy;
            NSString *name = dic[@"name"];
            if ([name isEqual:@"Opencountry"]) {
                name = @"原野";
            }
            else if ([name isEqual:@"street"]) {
                name = @"街道";
            }
            else if ([name isEqual:@"mountain"]) {
                name = @"山岭";
            }
            else if ([name isEqual:@"tallbuilding"]) {
                name = @"高楼";
            }
            else if ([name isEqual:@"inside city"]) {
                name = @"巷道";
            }
            else if ([name isEqual:@"forest"]) {
                name = @"森林";
            }
            else if ([name isEqual:@"highway"]) {
                name = @"高速公路";
            }
            else if ([name isEqual:@"coast"]) {
                name = @"海滨";
            }
            if (name) {
                [dic setObject:name forKey:@"name"];
            }
            callback(true, dic, error);
        }
        else {
            callback(false, nil, error);
        }
    }] resume];
    
}

@end