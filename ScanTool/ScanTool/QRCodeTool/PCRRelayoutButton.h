//
//  PCRRelayoutButton.h
//  PCRRelayoutButton
//
//  Created by Artron_LQQ on 18/6/25.
//  Copyright © 2018年 Artup. All rights reserved.
//自定义按钮样式

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,PCRRelayoutButtonType) {
    PCRRelayoutButtonTypeNomal  = 0,//默认
    PCRRelayoutButtonTypeLeft   = 1,//标题在左
    PCRRelayoutButtonTypeBottom = 2,//标题在下
};

@interface PCRRelayoutButton : UIButton

//图片大小
@property (assign,nonatomic)IBInspectable CGSize imageSize;
//图片相对于 top/right 的 offset
@property (assign,nonatomic)IBInspectable CGFloat offset;
//按钮显示类型
@property (assign,nonatomic)IBInspectable PCRRelayoutButtonType lzType;

@end

