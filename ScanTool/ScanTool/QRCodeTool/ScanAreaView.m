//
//  ScanAreaView.m
//  ScanTool
//
//  Created by admin on 2018/9/12.
//  Copyright © 2018年 CM. All rights reserved.
//

#import "ScanAreaView.h"


@implementation ScanAreaView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO; // 设置为透明的
    }
    return self;
}


- (void)drawRect:(CGRect)rect {

    [self addFourBorder:self.bounds];
}


- (void)addFourBorder:(CGRect)mainRect {
    CGFloat X = mainRect.origin.x;
    CGFloat Y = mainRect.origin.y;
    CGFloat maxX = mainRect.size.width;
    CGFloat maxY = mainRect.size.height;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 5);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
   
    CGPoint upLeftPoints[] = {      //左上角
        CGPointMake(X, Y),
        CGPointMake(X + 20, Y),
        CGPointMake(X, Y),
        CGPointMake(X, Y + 20)};
    CGPoint upRightPoints[] = {     //右上角
        CGPointMake(maxX - 20, Y),
        CGPointMake(maxX, Y),
        CGPointMake(maxX, Y),
        CGPointMake(maxX, Y + 20)};
    CGPoint belowLeftPoints[] = {   //左下角
        CGPointMake(X, maxY),
        CGPointMake(X, maxY - 20),
        CGPointMake(X, maxY),
        CGPointMake(X +20, maxY)};
    CGPoint belowRightPoints[] = {  //右下角
        CGPointMake(maxX - 20, maxY),
        CGPointMake(maxX, maxY),
        CGPointMake(maxX, maxY),
        CGPointMake(maxX, maxY - 20)};
    CGContextStrokeLineSegments(ctx, upLeftPoints, 4);
    CGContextStrokeLineSegments(ctx, upRightPoints, 4);
    CGContextStrokeLineSegments(ctx, belowLeftPoints, 4);
    CGContextStrokeLineSegments(ctx, belowRightPoints, 4);

}


@end
