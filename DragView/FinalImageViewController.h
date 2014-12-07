//
//  FinalImageViewController.h
//  WaterMark
//
//  Created by fab3 on 29/11/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinalImageViewController : UIViewController{
    
    IBOutlet UIImageView *imgView;
}

@property(nonatomic,retain) UIImage *finalImage;
@end
