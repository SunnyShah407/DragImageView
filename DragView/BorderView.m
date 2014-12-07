//
//  SPGripViewBorderView.m
//
//  Created by Seonghyun Kim on 6/3/13.
//  Copyright (c) 2013 scipi. All rights reserved.
//

#import "BorderView.h"

@implementation BorderView

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewDefaultMinHeight 48.0
#define kSPUserResizableViewInteractiveBorderSize 10.0

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:238.0f/255.0f green:89.0f/255 blue:254.0f/255.0f alpha:1.0].CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewInteractiveBorderSize/2));
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

@end
