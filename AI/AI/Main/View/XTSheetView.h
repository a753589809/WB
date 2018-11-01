//
//  XTSheetView.h
//  AI
//
//  Created by xuting on 2018/9/8.
//  Copyright © 2018年 xuting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XTSheetView;

@protocol XTSheetViewDelegat<NSObject>
- (void)clickSheetView:(XTSheetView *)sheetView index:(NSInteger)index;
@end

@interface XTSheetView : UIView

@property (nonatomic, weak) id<XTSheetViewDelegat> delegate;

- (void)setTitleArray:(NSArray *)titleArray subTitle:(NSArray *)subArray;

@end
