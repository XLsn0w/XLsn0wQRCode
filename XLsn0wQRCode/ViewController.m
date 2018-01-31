//
//  ViewController.m
//  XLsn0wQRCode
//
//  Created by ginlong on 2018/1/9.
//  Copyright © 2018年 ginlong. All rights reserved.
//

#import "ViewController.h"
#import "XLsn0wQRcodeScaner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    XLsn0wQRcodeScaner *scaner = [XLsn0wQRcodeScaner new];
    [self.navigationController pushViewController:scaner animated:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
