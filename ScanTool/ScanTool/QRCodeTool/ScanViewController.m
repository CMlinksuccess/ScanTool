//
//  ScanViewController.m
//  ScanTool
//
//  Created by admin on 2018/9/11.
//  Copyright © 2018年 CM. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ScanAreaView.h"
#import "PCRRelayoutButton.h"
#import "QRCodeTool.h"

#define ScreenWidth   [UIScreen mainScreen].bounds.size.width
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNav_Height  44.f  //导航条高度
#define kNavBarHeight (kNav_Height + kStatusBarHeight) //导航条和状态栏高度

#define kScanWidth  250
#define TOP (ScreenHeight-kScanWidth)/2
#define LEFT (ScreenWidth-kScanWidth)/2

#define kScanRect CGRectMake(LEFT, TOP, kScanWidth, kScanWidth)

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//设备映像输入流
@property (nonatomic, strong) AVCaptureDevice *device;
//滚动线条
@property (nonatomic, strong) UIImageView *line;
//定时器
@property (nonatomic, strong) NSTimer *timer;
//选择相册图片
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation ScanViewController
{
    int num;
    BOOL upOrdown;
    BOOL isOpen;
    AVCaptureSession * session;//输入输出的中间桥梁
    CAShapeLayer *cropLayer;
}

- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self instanceDevice];
    [self setCropRect:kScanRect];
    [self createNaviteView];
    [self createView];
}

- (void)createNaviteView{
    
    UIView *navigate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kNavBarHeight)];
    navigate.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:navigate];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, ScreenWidth, kNav_Height)];
    title.text = @"二维码/条码";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    navigate.userInteractionEnabled = YES;
    [navigate addSubview:title];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kNav_Height, kNav_Height)];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navigate addSubview:back];
    
    UIButton *makeQRCode = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 3 * kNav_Height, kStatusBarHeight,2*kNav_Height, kNav_Height)];
    [makeQRCode setTitle:@"生成二维码" forState:UIControlStateNormal];
    makeQRCode.titleLabel.font = [UIFont systemFontOfSize:12];
    [makeQRCode addTarget:self action:@selector(makeQRCodePicture) forControlEvents:UIControlEventTouchUpInside];
    [navigate addSubview:makeQRCode];
    
    UIButton *picutre = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - kNav_Height, kStatusBarHeight,kNav_Height, kNav_Height)];
    [picutre setTitle:@"相册" forState:UIControlStateNormal];
    [picutre addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    [navigate addSubview:picutre];
    
    UIImageView *QRcode = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 240)/3.0, ScreenHeight - 160, 120, 120)];
    QRcode.tag = 282931;
    [self.view addSubview:QRcode];
    UIImageView *QRcode2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(QRcode.frame) + (ScreenWidth - 240)/3.0, ScreenHeight - 160, 120, 120)];
    QRcode2.tag = 383941;
    [self.view addSubview:QRcode2];
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectImage{
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate  = self;
    _imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePicker.allowsEditing = YES;
    //相册
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)createView{
    
    ScanAreaView *scanArea = [[ScanAreaView alloc] initWithFrame:kScanRect];
    [self.view addSubview:scanArea];
    
    PCRRelayoutButton *flashBtn = [[PCRRelayoutButton alloc] initWithFrame:CGRectMake((kScanWidth - 80)/2.0, kScanWidth - 70, 80, 50)];
    flashBtn.lzType = PCRRelayoutButtonTypeBottom;
    flashBtn.imageSize = CGSizeMake(30, 30);
    [flashBtn setImage:[UIImage imageNamed:@"line.png"] forState:UIControlStateNormal];
    [flashBtn setTitle:@"轻触照亮" forState:UIControlStateNormal];
    [flashBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [flashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    flashBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [flashBtn addTarget:self action:@selector(flashClick) forControlEvents:UIControlEventTouchUpInside];
    [scanArea addSubview:flashBtn];

    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+5, kScanWidth, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.03 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}
- (void)flashClick{
    if (isOpen) {
        
        [self setCaptureDeviceFlashModel:AVCaptureTorchModeOff];
    }else{
        
        [self setCaptureDeviceFlashModel:AVCaptureTorchModeOn];
    }
    isOpen = !isOpen;
}

/**
  设置闪光灯开关

 @param model 开关模式
 */
- (void)setCaptureDeviceFlashModel:(AVCaptureTorchMode)model {
    AVCaptureDevice *captureDevice = self.device;
    NSError *error;
    //改变设备属性前一定先要上锁，设置完之后再解锁。
    if ([captureDevice hasTorch]) { //判断是否有闪光灯
        
        BOOL locked = [captureDevice lockForConfiguration:&error];
        if (locked) {
            if ([captureDevice isTorchModeSupported:model]) { //判断是否支持对应闪光灯模式
                
                captureDevice.torchMode = model;  //设置手电筒模式，其实也是闪光灯
            }
            [captureDevice unlockForConfiguration];
        }else{
            //设置闪光灯失败
        }
    }
}
-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(LEFT, TOP+5+2*num, kScanWidth, 2);
        if (2*num == kScanWidth - 10) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(LEFT, TOP+5+2*num, kScanWidth, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

/**
 *
 *  配置相机属性
 */
- (void)instanceDevice{
    
    //获取摄像设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if (input) {
        [session addInput:input];
    }
    if (output) {
        [session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *a = [[NSMutableArray alloc] init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes=a;
    }
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    
    //设置扫描区域
    CGFloat top = TOP/ScreenHeight;
    CGFloat left = LEFT/ScreenWidth;
    CGFloat width = kScanWidth/ScreenWidth;
    CGFloat height = kScanWidth/ScreenHeight;
    ///top 与 left 互换  width 与 height 互换
    [output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    //开始捕获
    [session startRunning];
}


- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.5];
    
    
    [cropLayer setNeedsDisplay];
    
    [self.view.layer addSublayer:cropLayer];
}

#pragma mark -AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [session stopRunning];
        [self.timer setFireDate:[NSDate distantFuture]];

        NSURL *url=[[NSBundle mainBundle]URLForResource:@"scanSuccess.wav" withExtension:nil];
        //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
        SystemSoundID soundID=8787;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
        //3.播放音效文件
        //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
        AudioServicesPlayAlertSound(soundID);
        AudioServicesPlaySystemSound(8787);
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
        //输出扫描字符串
        NSString *data = metadataObject.stringValue;
       
        NSLog(@"扫描结果：%@",data);
        [self showResult:data];
    }
}

#pragma mark -代理方法
//获取媒体资源
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *result = [QRCodeTool readQRCodeFromImage:image];
        NSLog(@"扫描结果：%@", result);
        [self showResult:result];
    }];
    
}
//扫描结果处理
- (void)showResult:(NSString *)data{
    if ([data hasPrefix:@"http"]) {
        
        NSURL *url = [NSURL URLWithString:data];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }else{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"扫描结果" message:data preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self->session startRunning];
            [self.timer setFireDate:[NSDate distantPast]];
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

//生成w二维码
- (void)makeQRCodePicture{
    UIImage *image = [QRCodeTool createQRimageString:@"http://www.baidu.com" sizeWidth:120 fillColor:[UIColor redColor]];
    UIImageView *QRcode = [self.view viewWithTag:282931];
    QRcode.image = image;
    
    UIImage *image2 = [QRCodeTool createImgQRCodeWithString:@"http://www.baidu.com" centerImage:[UIImage imageNamed:@"head"]];
    UIImageView *QRcode2 = [self.view viewWithTag:383941];
    QRcode2.image = image2;
    
}

@end
