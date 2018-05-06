//
//  OOvatarIcon.m
//  Ovatar
//
//  Created by Joe Barbour on 13/01/2017.
//  Copyright © 2017 Ovatar. All rights reserved.
//

#import "OOvatarIcon.h"

@implementation OOvatarIcon

-(void)drawRect:(CGRect)rect {
    self.ovatar = [OOvatar sharedInstance];
    self.ovatar.placeholder = self.placeholder;
    self.ovatar.output = self.placeholder==nil?OOutputTypeDefault:OOutputType404;
    self.ovatar.debug = true;
    self.ovatar.size = [self imageSize:self.bounds];
    self.ovatar.odelegate = self;

    self.animated = true;
    self.presentpicker = true;
    self.cacheexpiry = 60 * 60;
    
    if (![self.subviews containsObject:self.container]) {
        self.container = [[UIImageView alloc] initWithFrame:self.bounds];
        self.container.backgroundColor = [UIColor clearColor];
        self.container.contentMode = UIViewContentModeScaleAspectFill;
        self.container.image = self.placeholder;
        self.container.userInteractionEnabled = true;
        [self addSubview:self.container];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTappedWithGesture:)];
        gesture.delegate = self;
        [self.container addGestureRecognizer:gesture];
        
    }
    
    if (self.ovatar.ovatarKey != nil && self.ovatar.ovatarKey.length > 0) {
        if ([self imageFromCache:self.ovatar.ovatarKey] == nil) {
            [self.ovatar returnOvatarIconWithKey:self.ovatar.ovatarKey completion:^(NSError *error, id output) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (error.code == 200) {
                        if ([output isKindOfClass:[UIImage class]]) {
                            [self imageSet:(UIImage *)output animated:self.animated];
                            [self imageSaveToCache:(UIImage *)output identifyer:self.ovatar.ovatarKey];

                        }
                        
                    }
                    else if (error.code == 404) {
                        [self imageSet:self.placeholder animated:self.animated];
                        
                    }
                    else {
                        [self imageSet:[self imageFromCache:self.ovatar.ovatarKey] animated:self.animated];
                        
                    }
                    
                }];
                
            }];
            
        }
        else [self imageSet:[self imageFromCache:self.ovatar.ovatarKey] animated:self.animated];
        
    }
    
    if ((self.ovatar.ovatarEmail != nil && self.ovatar.ovatarEmail.length > 0) || (self.ovatar.ovatarPhoneNumber != nil && self.ovatar.ovatarPhoneNumber.length > 0)) {
        NSString *user;
        if (self.ovatar.ovatarEmail != nil) user = self.ovatar.ovatarEmail;
        else user = self.ovatar.ovatarPhoneNumber;
        
        if ([self imageFromCache:user] == nil) {
            [self.ovatar returnOvatarIconWithQuery:user completion:^(NSError *error, id output) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (error.code == 200) {
                        if ([output isKindOfClass:[UIImage class]]) {
                            [self imageSet:(UIImage *)output animated:self.animated];
                            [self imageSaveToCache:(UIImage *)output identifyer:user];
                            
                        }
                        
                    }
                    else if (error.code == 404) {
                        [self imageSet:self.placeholder animated:self.animated];
                        
                    }
                    else {
                        [self imageSet:[self imageFromCache:user] animated:self.animated];
                        
                    }
                    
                }];
                
            }];
            
        }
        else [self imageSet:[self imageFromCache:user] animated:self.animated];

    }
    
}

-(void)imageTappedWithGesture:(UITapGestureRecognizer *)gesture {
    if (self.animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animation.autoreverses = true;
        animation.repeatCount = 1;
        animation.toValue = [NSNumber numberWithFloat:0.95];
        [self.container.layer addAnimation:animation forKey:nil];

        UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
        [generator notificationOccurred:UINotificationFeedbackTypeWarning];
        [generator prepare];
        
    }
    
    if (self.presentpicker) {
        if (self.ovatar.ovatarEmail != nil || self.ovatar.ovatarPhoneNumber != nil) {
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if (status == PHAuthorizationStatusAuthorized) {
                            [self imagePickerPresent];
                            
                        }
                        
                    }];
                    
                }];
                
            }
            else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                [self imagePickerPresent];
                
            }
            else {
                NSLog(@"\n\nOVATAR ERROR: Photo access has been disabled/revoked by the user");
                
            }
            
        }
        else NSLog(@"\n\nOVATAR ERROR: You need to set a or email or phone number");
        
    }
    else {
        if ([self.odelegate respondsToSelector:@selector(ovatarIconWasTappedWithGesture:)]) {
            [self.odelegate ovatarIconWasTappedWithGesture:gesture];
            
        }
        
    }
    
}

-(void)imagePickerPresent {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [picker setAllowsEditing:self.allowsediting];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UINavigationController *root = (UINavigationController  *)self.window.rootViewController;

        [picker setDelegate:self];
        [root presentViewController:picker animated:true completion:^{
            
        }];
        
    }
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:true completion:^{
        UIImage *output;
        if (self.allowsediting) output = [info objectForKey:UIImagePickerControllerEditedImage];
        else output = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self imageUpdateWithImage:UIImagePNGRepresentation(output)];
        
    }];
    
}

-(void)imageSet:(UIImage *)image animated:(BOOL)animated {
    if (animated) {
        [UIView transitionWithView:self duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (image.CGImage != NULL && image.CGImage != nil) {
                [self.container setImage:image];
                
                
            }
            
        } completion:nil];
        
    }
    else [self.container setImage:image];

}

-(void)imageSetWithKey:(NSString *)key {
    if (![self.ovatar.ovatarKey isEqualToString:key]) {
        self.ovatar.key = key;
        
        [self setNeedsDisplay];
        
    }
    
}

-(void)imageUpdateWithImage:(NSData *)image {
    NSString *user;
    if (self.ovatar.ovatarEmail != nil) user = self.ovatar.ovatarEmail;
    else user = self.ovatar.ovatarPhoneNumber;
    
    [self.ovatar uploadOvatar:image user:user];
    [self imageSaveToCache:[UIImage imageWithData:image] identifyer:user];
    
}

-(OImageSize)imageSize:(CGRect)rect {
    if (rect.size.width <= (30.0)) return OImageSizeSmall;
    else if (rect.size.width >= (120 / 2) && rect.size.width <= (350 / 2)) return OImageSizeMedium;
    else return OImageSizeLarge;

}

-(void)imageSaveToCache:(UIImage *)image identifyer:(NSString *)identifyer {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    if (image != nil) {
        [cache setObject:UIImagePNGRepresentation(image) forKey:[NSString stringWithFormat:@"ovatar_data_%@" ,identifyer]];
        [cache setObject:[NSDate dateWithTimeIntervalSinceNow:self.cacheexpiry] forKey:[NSString stringWithFormat:@"ovatar_expiry_%@" ,identifyer]];
        
    }
    else {
        [cache removeObjectForKey:[NSString stringWithFormat:@"ovatar_data_%@" ,identifyer]];
        [cache removeObjectForKey:[NSString stringWithFormat:@"ovatar_expiry_%@" ,identifyer]];
        
    }
    
    [cache synchronize];

}

-(UIImage *)imageFromCache:(NSString *)identifyer {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSDate *expiry = [cache objectForKey:[NSString stringWithFormat:@"ovatar_expiry_%@" ,identifyer]];
    NSData *output = [cache objectForKey:[NSString stringWithFormat:@"ovatar_data_%@" ,identifyer]];

    if ([[NSDate date] compare:expiry] == NSOrderedDescending || expiry == nil) return nil;
    else if ([cache objectForKey:[NSString stringWithFormat:@"cache_%@" ,identifyer]] == nil) return nil;
    else return [UIImage imageWithData:output];

}

@end
