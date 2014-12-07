//
//  FinalImageViewController.m
//  WaterMark
//
//  Created by fab3 on 29/11/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "FinalImageViewController.h"

@interface FinalImageViewController ()

@end

@implementation FinalImageViewController
@synthesize finalImage;
- (void)viewDidLoad {
    [super viewDidLoad];
    imgView.image = self.finalImage;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
