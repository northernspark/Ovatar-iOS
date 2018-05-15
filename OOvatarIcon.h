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

@property (weak, nonatomic) id <OOvatarIconDelegate> oicondelegate;
@property (nonatomic, strong) UIImage *placeholder;
//Ovatar icon placeholder image.

@property (nonatomic) BOOL hasaction;
//Tapping Ovatar icon will return either 'ovatarIconWasTappedWithGesture' method as delegate, if presentpicker is FALSE or will present Image Picker winder if presentpicker is TRUE. By default this is set to FALSE and will not fire any action

@property (nonatomic) BOOL animated;
//Ovatar animates with crossfade

@property (nonatomic) BOOL presentpicker;
//Present default image picker, if true the 'ovatarIconWasTappedWithGesture' method will not be called. Default is set to TRUE.

@property (nonatomic) BOOL allowsphotoediting;
//Presents default image editor for framing and cropping selected image. Default is set to FALSE.

@property (nonatomic, strong) UIImageView *container;
@property (nonatomic, strong) OOvatar *ovatar;

-(void)imageSet:(UIImage *)image animated:(BOOL)animated;
//Set the Ovatar Icon image manually. Setting animated to TRUE will crossfade from the current image to the new image with a 6 second duration

-(void)imageDownloadWithQuery:(NSString *)query;
//Set an image in the Ovatar Icon. The query variable can be set as an email, phone number or an Ovatar key. This must be called after the OOvatarIcon is initilaized

-(void)imageUpdateWithImage:(NSData *)image;
//Upload an image directly to the server from a NSData object manually for full control. First, you must set at email address or phone number in Ovatar class. Use the delegate methods to handle progress and errors and set the uploaded image manually.

@end

@protocol OOvatarIconDelegate <NSObject>

-(void)ovatarIconWasTappedWithGesture:(UITapGestureRecognizer *)gesture;
//Called if the 'presentpicker' BOOL is set to FALSE (be default it is set to TRUE). Here you can set custom actions for the when the Ovatar Icon is tapped.

-(void)ovatarIconWasUpdatedSucsessfully:(NSDictionary *)output;
//Called if an image is uploaded sucsessfully.

-(void)ovatarIconUploadFailedWithErrors:(NSError *)error;
//Called if an image cannot be uploaded, see the documentation for error codes.

-(void)ovatarIconUploadingWithProgress:(float)progress;
//Called everytime the progress of the upload changes. The progress with displayed as in double value on a 0-100 scale.

@end

