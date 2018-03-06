//
//  OOvatarIcon.h
//  Ovatar
//
//  Created by Joe Barbour on 13/01/2017.
//  Copyright © 2017 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OOvatar.h"

@protocol OOvatarIconDelegate;
@interface OOvatarIcon : UIView <UIGestureRecognizerDelegate, OOvatarDelegate>

@property (weak, nonatomic) id <OOvatarIconDelegate> odelegate;
@property (nonatomic, strong) UIImage *placeholder;//set placeholder image
@property (nonatomic) BOOL onlyfaces;//only accept images with faces
@property (nonatomic) BOOL animated;
@property (nonatomic) int cacheexpiry;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong) UIImageView *container;
@property (nonatomic, strong) OOvatar *ovatar;

-(void)imageSet:(UIImage *)image animated:(BOOL)animated;
-(void)imageUpdateWithImage:(UIImage *)image;

@end

@protocol OOvatarIconDelegate <NSObject>

-(void)ovatarIconWasTappedWithGesture:(UITapGestureRecognizer *)gesture;
-(void)ovatarIconWasUpdatedSucsessfully:(UIImage *)icon;
-(void)ovatarIconUploadFailedWithErrors:(NSError *)error;
-(void)ovatarIconUploadingWithProgress:(NSInteger *)progress;

@end

