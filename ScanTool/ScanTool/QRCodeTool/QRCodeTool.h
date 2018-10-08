//
//  QRCodeTool.h
//
//
//  Created by Artron_LQQ on 18/6/25.
//  Copyright © 2018年 Artup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeTool : NSObject
/**
 *  生成二维码图片
 *
 *  @param QRString  二维码内容
 *  @param sizeWidth 图片size（正方形）
 *  @param color     填充色
 *
 *  @return  二维码图片
 */
+(UIImage *)createQRimageString:(NSString *)QRString sizeWidth:(CGFloat)sizeWidth fillColor:(UIColor *)color;


/**
 
 生成二维码图片(中间有小图片)
 
 QRStering：所需字符串
 
 centerImage：二维码中间的image对象
 
 */

+ (UIImage *)createImgQRCodeWithString:(NSString *)QRString centerImage:(UIImage *)centerImage;

/**
 *  读取图片中二维码信息
 *
 *  @param image 图片
 *
 *  @return 二维码内容
 */
+(NSString *)readQRCodeFromImage:(UIImage *)image;
@end
