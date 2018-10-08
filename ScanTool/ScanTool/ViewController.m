//
//  ViewController.m
//  ScanTool
//
//  Created by admin on 2018/9/11.
//  Copyright © 2018年 CM. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    [back setTitle:@"扫描" forState:UIControlStateNormal];
    [back setBackgroundColor:[UIColor greenColor]];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}


- (void)back{
    ScanViewController *scan = [[ScanViewController alloc] init];
    [self presentViewController:scan animated:YES completion:nil];
}


@end
