//
//  XTSoundPlayer.h
//  AI
//
//  Created by xuting on 2018/9/6.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface XTSoundPlayer : NSObject<AVSpeechSynthesizerDelegate>

@property (nonatomic, assign) CGFloat rate;   //语速
@property (nonatomic, assign) CGFloat volume; //音量
@property (nonatomic, assign) CGFloat pitchMultiplier;  //音调
@property (nonatomic, assign) BOOL  autoPlay;  //自动播放

//类方法实例出对象
+ (XTSoundPlayer *)standardSoundPlayer;

//基础设置
- (void)setDefaultWithVolume:(float)aVolume rate:(CGFloat)aRate pitchMultiplier:(CGFloat)aPitchMultiplier;

//播放并给出文字
- (void)play:(NSString *)string;

@end
