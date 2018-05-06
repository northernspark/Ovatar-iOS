//
//  OOvatarIcon.h
//  Ovatar
//
//  Created by Joe Barbour on 13/01/2017.
//  Copyright © 2017 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "OOvatar.h"

@protocol OOvatarIconDelegate;
@interface OOvatarIcon : UIView <UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, OOvatarDelegate>

@property (weak, nonatomic) id <OOvatarIconDelegate> odelegate;
@property (nonatomic, strong) UIImage *placeholder;
//Ovatar icon placeholder image.

@property (nonatomic) BOOL animated;
//Ovatar animates with crossfade

@property (nonatomic) BOOL presentpicker;
//Present default image picker, if true the 'ovatarIconWasTappedWithGesture' method will not be called. Default is set to TRUE.

@property (nonatomic) BOOL allowsediting;
//Presents default image editor for framing and cropping selected image. Default is set to FALSE.

@property (nonatomic) int cacheexpiry;
//Cache expiry default set to 1 hour. This number is in seconds.

@property (nonatomic, strong) UIImageView *container;
@property (nonatomic, strong) OOvatar *ovatar;

-(void)imageSet:(UIImage *)image animated:(BOOL)animated;
-(void)imageSetWithKey:(NSString *)key;
-(void)imageUpdateWithImage:(NSData *)image;
-(void)imagePickerPresentWithViewController:(UIViewController *)superview;

@end

@protocol OOvatarIconDelegate <NSObject>

-(void)ovatarIconWasTappedWithGesture:(UITapGestureRecognizer *)gesture;
-(void)ovatarIconWasUpdatedSucsessfully:(UIImage *)icon;
-(void)ovatarIconUploadFailedWithErrors:(NSError *)error;
-(void)ovatarIconUploadingWithProgress:(NSInteger *)progress;

@end

