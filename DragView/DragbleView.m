//
//  ZDStickerView.m
//
//  Created by Seonghyun Kim on 5/29/13.
//  Copyright (c) 2013 scipi. All rights reserved.
//

#import "DragbleView.h"
#import <QuartzCore/QuartzCore.h>

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewInteractiveBorderSize 10.0
#define kZDStickerViewControlSize 30.0


@interface DragbleView ()

@property (strong, nonatomic) UIImageView *resizingControl;
@property (strong, nonatomic) UIImageView *deleteControl;
@property (strong, nonatomic) UIImageView *customControl;

@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;

@end

@implementation DragbleView
@synthesize contentView, touchStart;

@synthesize prevPoint;
@synthesize deltaAngle, startTransform; //rotation
@synthesize resizingControl, deleteControl, customControl;
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;
@synthesize preventsCustomButton;
@synthesize minWidth, minHeight;
@synthesize cloneView;

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#ifdef ZDSTICKERVIEW_LONGPRESS
-(void)longPress:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if([_delegate respondsToSelector:@selector(stickerViewDidLongPressed:)]) {
            [_delegate stickerViewDidLongPressed:self];
        }
    }
}
#endif

-(void)singleTap:(UIPanGestureRecognizer *)recognizer
{
    if (NO == self.preventsDeleting) {
        UIView * close = (UIView *)[recognizer view];
        [close.superview removeFromSuperview];
    }
    
    if([_delegate respondsToSelector:@selector(stickerViewDidClose:)]) {
        [_delegate stickerViewDidClose:self];
    }
}

-(void)customTap:(UIPanGestureRecognizer *)recognizer
{
    if (NO == self.preventsCustomButton) {
        if([_delegate respondsToSelector:@selector(stickerViewDidCustomButtonTap:)]) {
            [_delegate stickerViewDidCustomButtonTap:self];
        }
    }
}

-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < minWidth || self.bounds.size.height < minHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     minWidth+1,
                                     minHeight+1);
            resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                              self.bounds.size.height-kZDStickerViewControlSize,
                                              kZDStickerViewControlSize,
                                              kZDStickerViewControlSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
            customControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                            0,
                                            kZDStickerViewControlSize,
                                            kZDStickerViewControlSize);
            prevPoint = [recognizer locationInView:self];
            
        } else {
            CGPoint point = [recognizer locationInView:self];
            
            float wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            float wRatioChange = (wChange/(float)self.bounds.size.width);
            
            hChange = wRatioChange * self.bounds.size.height;
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
                prevPoint = [recognizer locationInView:self];
                return;
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                     self.bounds.size.width + (wChange),
                                     self.bounds.size.height + (hChange));
            resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                              self.bounds.size.height-kZDStickerViewControlSize,
                                              kZDStickerViewControlSize, kZDStickerViewControlSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
            customControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                            0,
                                            kZDStickerViewControlSize,
                                            kZDStickerViewControlSize);
            prevPoint = [recognizer locationInView:self];
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        float angleDiff = deltaAngle - ang;
        if (NO == preventsResizing) {
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
        }
        NSLog(@"%f",angleDiff);
        borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        [borderView setNeedsDisplay];
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    [cloneView setNeedsDisplay];
}

- (UIView *)cloneView {
    if (!cloneView) {
        cloneView = [[CloneView alloc] initWithView:self];
    }
    return cloneView;
}
- (void)setupDefaultAttributes {
    borderView = [[BorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    [borderView setHidden:YES];
    [self addSubview:borderView];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }
    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    self.preventsCustomButton = YES;
#ifdef ZDSTICKERVIEW_LONGPRESS
    UILongPressGestureRecognizer* longpress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(longPress:)];
    [self addGestureRecognizer:longpress];
#endif
    deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                 kZDStickerViewControlSize, kZDStickerViewControlSize)];
    deleteControl.backgroundColor = [UIColor clearColor];
    deleteControl.image = [UIImage imageNamed:@"close.png" ];
    deleteControl.userInteractionEnabled = YES;
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(singleTap:)];
    [deleteControl addGestureRecognizer:singleTap];
    [self addSubview:deleteControl];
    
    resizingControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                                                   self.frame.size.height-kZDStickerViewControlSize,
                                                                   kZDStickerViewControlSize, kZDStickerViewControlSize)];
    resizingControl.backgroundColor = [UIColor clearColor];
    resizingControl.userInteractionEnabled = YES;
    resizingControl.image = [UIImage imageNamed:@"resize.png" ];
    UIPanGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [resizingControl addGestureRecognizer:panResizeGesture];
    [self addSubview:resizingControl];
    
    customControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                                                 0,
                                                                 kZDStickerViewControlSize, kZDStickerViewControlSize)];
    customControl.backgroundColor = [UIColor clearColor];
    customControl.userInteractionEnabled = YES;
    customControl.image = nil;
    UITapGestureRecognizer * customTapGesture = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(customTap:)];
    [customControl addGestureRecognizer:customTapGesture];
    [self addSubview:customControl];
    
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}
-(void)editingchange;{
    [deleteControl setHidden:false];
    [resizingControl setHidden:false];
    self.isEditing = false;
}
- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    
    for (UIView* subview in [contentView subviews]) {
        [subview setFrame:CGRectMake(0, 0,
                                     contentView.frame.size.width,
                                     contentView.frame.size.height)];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    [self bringSubviewToFront:borderView];
    [self bringSubviewToFront:resizingControl];
    [self bringSubviewToFront:deleteControl];
    [self bringSubviewToFront:customControl];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    for (UIView* subview in [contentView subviews]) {
        [subview setFrame:CGRectMake(0, 0,
                                     contentView.frame.size.width,
                                     contentView.frame.size.height)];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    borderView.frame = CGRectInset(self.bounds,
                                   kSPUserResizableViewGlobalInset,
                                   kSPUserResizableViewGlobalInset);
    resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                      self.bounds.size.height-kZDStickerViewControlSize,
                                      kZDStickerViewControlSize,
                                      kZDStickerViewControlSize);
    deleteControl.frame = CGRectMake(0, 0,
                                     kZDStickerViewControlSize, kZDStickerViewControlSize);
    customControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                    0,
                                    kZDStickerViewControlSize,
                                    kZDStickerViewControlSize);
    [borderView setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEditing) {
        return;
    }
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
    if (touch.view == resizingControl)
    {
        NSLog(@"Yes");
        
    }
    else{
        
    }
    //    if([_delegate respondsToSelector:@selector(stickerViewDidBeginEditing:)]) {
    //      [_delegate stickerViewDidBeginEditing:self];
    // }
}
-(void)startEditing{
    self.isEditing =TRUE;
    [deleteControl setHidden:TRUE];
    [resizingControl setHidden:TRUE];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEditing) {
        return;
    }
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidEndEditing:)]) {
        [_delegate stickerViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEditing) {
        return;
    }
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidCancelEditing:)]) {
        [_delegate stickerViewDidCancelEditing:self];
    }
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEditing) {
        return;
    }
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(resizingControl.frame, touchLocation)) {
        return;
    }
    
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
}

- (void)hideDelHandle
{
    deleteControl.hidden = YES;
}

- (void)showDelHandle
{
    deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    resizingControl.hidden = YES;
    deleteControl.hidden = YES;
    customControl.hidden = YES;
    [borderView setHidden:YES];
}

- (void)showEditingHandles
{
    if (NO == preventsCustomButton) {
        customControl.hidden = NO;
    } else {
        customControl.hidden = YES;
    }
    if (NO == preventsDeleting) {
        deleteControl.hidden = NO;
    } else {
        deleteControl.hidden = YES;
    }
    if (NO == preventsResizing) {
        resizingControl.hidden = NO;
    } else {
        resizingControl.hidden = YES;
    }
    [borderView setHidden:NO];
}

- (void)showCustomHandle
{
    customControl.hidden = NO;
}

- (void)hideCustomHandle
{
    customControl.hidden = YES;
}

- (void)setButton:(DragbleView_BUTTONS)type image:(UIImage*)image
{
    switch (type) {
        case DragbleView_BUTTON_RESIZE:
            resizingControl.image = image;
            break;
        case DragbleView_BUTTON_DEL:
            deleteControl.image = image;
            break;
        case DragbleView_BUTTON_CUSTOM:
            customControl.image = image;
            break;
            
        default:
            break;
    }
}

@end
@implementation CloneView
@synthesize srcView;

- (id)initWithView:(UIView *)src {
    self = [super initWithFrame:src.frame];
    if (self) {
        srcView = src;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [srcView.layer renderInContext:UIGraphicsGetCurrentContext()];
}

@end