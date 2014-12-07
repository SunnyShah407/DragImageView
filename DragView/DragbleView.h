//
//  DragbleView.h
//
//  Created by Seonghyun Kim on 5/29/13.
//  Copyright (c) 2013 scipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderView.h"

typedef enum {
    DragbleView_BUTTON_NULL,
    DragbleView_BUTTON_DEL,
    DragbleView_BUTTON_RESIZE,
    DragbleView_BUTTON_CUSTOM,
    DragbleView_BUTTON_MAX
} DragbleView_BUTTONS;

@protocol DragbleViewDelegate;

@interface DragbleView : UIView
{
    BorderView *borderView;
}

@property (assign, nonatomic) UIView *contentView;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) BOOL preventsCustomButton; //default = YES
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) BOOL isEditing;
@property(nonatomic, readonly, strong) UIView *cloneView;

@property (strong, nonatomic) id <DragbleViewDelegate> delegate;

- (void)hideDelHandle;
- (void)showDelHandle;
-(void)editingchange;
-(void)startEditing;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustomHandle;
- (void)hideCustomHandle;
- (void)setButton:(DragbleView_BUTTONS)type image:(UIImage*)image;

@end

@protocol DragbleViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(DragbleView *)sticker;
- (void)stickerViewDidEndEditing:(DragbleView *)sticker;
- (void)stickerViewDidCancelEditing:(DragbleView *)sticker;
- (void)stickerViewDidClose:(DragbleView *)sticker;
#ifdef DragbleView_LONGPRESS
- (void)stickerViewDidLongPressed:(DragbleView *)sticker;
#endif
- (void)stickerViewDidCustomButtonTap:(DragbleView *)sticker;
@end

@interface CloneView : UIView
@property(nonatomic, weak) UIView *srcView;
- (id)initWithView:(UIView *)src;
@end
