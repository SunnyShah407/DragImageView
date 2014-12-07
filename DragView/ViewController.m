//
//  ViewController.m
//  WaterMark
//
//  Created by fab3 on 29/11/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "ViewController.h"
#import "DragbleView.h"
#import "FinalImageViewController.h"
@interface ViewController () <UITextFieldDelegate , DragbleViewDelegate>{
    CGPoint preCenter;
    CGAffineTransform preTranform;
    UITextField *textField;
    DragbleView *dragView;
    
}
@end

@implementation ViewController
- (CGSize)getRotatedViewSize
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    float max = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
    float min = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    
    return (isPortrait ?
            CGSizeMake(min, max) :
            CGSizeMake(max, min));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDragbleView];
    
    CGSize size=[self getRotatedViewSize];
    CGRect bound=CGRectMake(0, 64, size.width, 505 );
    
    CGSize imageSize = imgView.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(bound)/imageSize.width, CGRectGetHeight(bound)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(roundf(0.5f*(CGRectGetWidth(bound)-scaledImageSize.width)), 64+roundf(0.5f*(CGRectGetHeight(bound)-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
    [imgView setFrame:imageFrame];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setDragbleView{
    
    textField= [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 200, 80)];
    textField.text = @"Copyright";
    textField.delegate=self;
    [textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    textField.font=[UIFont systemFontOfSize:150.0f];
    textField.minimumFontSize = 10.0f;
    [textField setTextAlignment:NSTextAlignmentCenter];
    textField.adjustsFontSizeToFitWidth=YES;
    [textField setTextColor:[UIColor colorWithRed:238.0f/255.0f green:89.0f/255 blue:254.0f/255.0f alpha:1.0]];
    [textField sizeToFit];
    
    textField.clipsToBounds=YES;
    dragView = [[DragbleView alloc] initWithFrame:CGRectMake(10, 200, 200, 90)];
    dragView.tag = 0;
    dragView.delegate = self;
    dragView.contentView = textField;//contentView;
    dragView.preventsPositionOutsideSuperview = NO;
    [dragView showEditingHandles];
    dragView.transform = CGAffineTransformMakeRotation (-0.663247);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [textField.superview addGestureRecognizer:tapGesture];
    [self.view addSubview:dragView];
}
- (void)didRecognizeTapGesture:(UITapGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (CGRectContainsPoint(textField.frame, point))
        {
            [textField becomeFirstResponder];
            [dragView startEditing];
        }
        
        
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    preCenter = dragView.center;
    preTranform = dragView.transform;
    [UIView animateWithDuration: 0.2 delay: 0 options: UIViewAnimationOptionCurveLinear animations:^{
        dragView.transform = CGAffineTransformMakeRotation (0);
        dragView.center =CGPointMake(self.view.center.x, self.view.center.y-60);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration: 0.7 delay: 0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        } completion: nil];
    }];
}


-(void)textDidChangeVa:(UITextField *)textField1{
    
    
    //use this for system font
    CGFloat actualFontSize;
    CGSize  size = [textField.text sizeWithFont:textField.font minFontSize:10 actualFontSize:&actualFontSize forWidth:dragView.frame.size.width lineBreakMode:NSLineBreakByTruncatingHead];
    
    
    
    CGFloat width = [textField1.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:actualFontSize]}].width+20;
    
    if (width <self.view.frame.size.width+100) {
        dragView.frame = CGRectMake(dragView.frame.origin.x, dragView.frame.origin.y, width, dragView.frame.size.height);
    }
    dragView.center =CGPointMake(self.view.center.x, self.view.center.y-60);
    // dragView.frame = CGRectMake(point.x, point.y, width,height);
}
-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode  {
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    
    
    CGRect textRect = [text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    //Contains both width & height ... Needed: The height
    return textRect.size;
}
#pragma mark - delegate functions
- (void)stickerViewDidBeginEditing:(DragbleView *)sticker{
    [textField becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField1{
    [textField resignFirstResponder];
    
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration: 0.2 delay: 0 options: UIViewAnimationOptionCurveLinear animations:^{
        
        
        dragView.transform = preTranform;
        dragView.center =preCenter;
    } completion:^(BOOL finished) {
        [dragView editingchange];;
        
    }];
}

-(IBAction)btnSaveClicked{
    [dragView startEditing];
    [dragView setNeedsDisplay];
    
    UIImage *dragImage = [self imageWithView:dragView];
    UIGraphicsBeginImageContextWithOptions(imgView.image.size, NO, 0.0);
    
    
    UIImage *mainImage = [self imageWithView:imgView];
    [mainImage drawInRect:CGRectMake(0, 0, imgView.image.size.width, imgView.image.size.height)];
    [dragImage drawAtPoint:CGPointMake(dragView.center.x, dragView.center.y - imgView.frame.origin.y)];
    [dragView editingchange];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    FinalImageViewController *objVc =[[FinalImageViewController alloc]init];
    objVc.finalImage =newImage;
    [self.navigationController pushViewController:objVc animated:YES];
    
    
}
- (UIImage *) imageWithView:(UIView *)view
{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
    
}
@end
