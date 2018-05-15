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
    self.ovatar.size = [self imageSize:self.bounds];
    self.ovatar.odelegate = self;

    self.animated = true;
    self.presentpicker = true;
    self.contentMode = UIViewContentModeScaleToFill;

    if (![self.subviews containsObject:self.container]) {
        self.container = [[UIImageView alloc] initWithFrame:self.bounds];
        self.container.backgroundColor = [UIColor clearColor];
        self.container.contentMode = self.contentMode;
        self.container.image = self.placeholder;
        self.container.userInteractionEnabled = true;
        [self addSubview:self.container];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTappedWithGesture:)];
        gesture.delegate = self;
        gesture.enabled = self.hasaction;
        [self.container addGestureRecognizer:gesture];
        
    }
    
    if (self.hasaction) {
        if (self.ovatar.ovatarKey != nil && self.ovatar.ovatarKey.length > 0) {
            if ([self.ovatar imageFromCache:self.ovatar.ovatarKey] == nil) {
                [self.ovatar returnOvatarIconWithKey:self.ovatar.ovatarKey completion:^(NSError *error, id output) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if (error.code == 200) {
                            if ([output isKindOfClass:[UIImage class]]) {
                                [self imageSet:(UIImage *)output animated:self.animated];
                                [self.ovatar imageSaveToCache:(UIImage *)output identifyer:self.ovatar.ovatarKey];

                            }
                            
                        }
                        else if (error.code == 404) {
                            if ([output isKindOfClass:[UIImage class]] && self.placeholder == nil) {
                                [self imageSet:(UIImage *)output animated:self.animated];
                                [self.ovatar imageSaveToCache:(UIImage *)output identifyer:self.ovatar.ovatarKey];
                                
                            }
                            else {
                                [self imageSet:self.placeholder animated:self.animated];
                                [self.ovatar imageSaveToCache:self.placeholder identifyer:self.ovatar.ovatarKey];
                            }

                        }
                        else {
                            [self imageSet:[self.ovatar imageFromCache:self.ovatar.ovatarKey] animated:self.animated];
                            
                        }
                        
                    }];
                    
                }];
                
            }
            else [self imageSet:[self.ovatar imageFromCache:self.ovatar.ovatarKey] animated:self.animated];
            
        }
        else if ((self.ovatar.ovatarEmail != nil && self.ovatar.ovatarEmail.length > 0) || (self.ovatar.ovatarPhoneNumber != nil && self.ovatar.ovatarPhoneNumber.length > 0)) {
            NSString *user;
            if (self.ovatar.ovatarEmail != nil) user = self.ovatar.ovatarEmail;
            else user = self.ovatar.ovatarPhoneNumber;

            if ([self.ovatar imageFromCache:user] == nil) {
                [self.ovatar returnOvatarIconWithQuery:user completion:^(NSError *error, id output) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if (error.code == 200) {
                            if ([output isKindOfClass:[UIImage class]]) {
                                [self imageSet:(UIImage *)output animated:self.animated];
                                [self.ovatar imageSaveToCache:(UIImage *)output identifyer:user];
                                
                            }
                            
                        }
                        else if (error.code == 404) {
                            if ([output isKindOfClass:[UIImage class]] && self.placeholder == nil) {
                                [self imageSet:(UIImage *)output animated:self.animated];
                                [self.ovatar imageSaveToCache:(UIImage *)output identifyer:self.ovatar.ovatarKey];
                                
                            }
                            else {
                                [self imageSet:self.placeholder animated:self.animated];
                                [self.ovatar imageSaveToCache:self.placeholder identifyer:self.ovatar.ovatarKey];
                            }
                            
                        }
                        else {
                            [self imageSet:[self.ovatar imageFromCache:user] animated:self.animated];
                            
                        }
                        
                    }];
                    
                }];
                
            }
            else [self imageSet:[self.ovatar imageFromCache:user] animated:self.animated];

        }
        else [self imageSet:self.placeholder animated:self.animated];
        
    }
    
}

-(void)imageTappedWithGesture:(UITapGestureRecognizer *)gesture {
    if (self.hasaction) {
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
            if ([self.ovatar ovatarEmail] != nil || [self.ovatar ovatarPhoneNumber] != nil) {
                NSString *plistfile = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
                NSDictionary *plistdata = [[NSDictionary alloc] initWithContentsOfFile:plistfile];
                
                if ([plistdata valueForKey:@"NSPhotoLibraryUsageDescription"] == nil) {
                    NSLog(@"\n\nOVATAR ERROR: The 'NSPhotoLibraryUsageDescription' key is missing from the Info.plist file. Please add the key with a description about how your app uses the Photo Gallery. Does your app only require photo access just for Ovatar? Use this description - '%@ requires photo access to allow you to set/change your profile picture via Ovatar.io'\n\n" ,[plistdata valueForKey:@"CFBundleName"]);
                    
                }
                else {
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
                        NSLog(@"\n\nOVATAR ERROR: Photo access has been disabled/revoked by the user\n\n");
                        if ([self.oicondelegate respondsToSelector:@selector(ovatarIconUploadFailedWithErrors:)]) {
                            [self.oicondelegate ovatarIconUploadFailedWithErrors:[NSError errorWithDomain:@"Photo access has been disabled/revoked by the user" code:401 userInfo:nil]];
                            
                        }
                        
                    }
                    
                }
                
            }
            else NSLog(@"\n\nOVATAR ERROR: You need to set a or email or phone number\n\n");
            
        }
        else {
            if ([self.oicondelegate respondsToSelector:@selector(ovatarIconWasTappedWithGesture:)]) {
                [self.oicondelegate ovatarIconWasTappedWithGesture:gesture];
                
            }
            
        }
        
    }
    
}

-(void)imagePickerPresent {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [picker setAllowsEditing:self.allowsphotoediting];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [picker setDelegate:self];
        [(UINavigationController  *)self.window.rootViewController presentViewController:picker animated:true completion:^{
            
        }];
        
    }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:true completion:^{
        UIImage *output;
        if (self.allowsphotoediting) output = [info objectForKey:UIImagePickerControllerEditedImage];
        else output = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self imageUpdateWithImage:UIImageJPEGRepresentation(output, 0.8)];
        
    }];
    
}

-(void)imageSet:(UIImage *)image animated:(BOOL)animated {
    if (animated) {
        [UIView transitionWithView:self.container duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (image.CGImage != NULL && image.CGImage != nil) {
                [self.container setImage:image];
                
            }
            
        } completion:nil];
        
    }
    else [self.container setImage:image];

}

-(void)imageDownloadWithQuery:(NSString *)query {
    if (query.length > 1) {
        if (self.hasaction) {
            if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_EMAIL] evaluateWithObject:query]) {
                [self.ovatar setEmail:query];
                [self setNeedsDisplay];

            }
            else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_PHONE] evaluateWithObject:query]) {
                [self.ovatar setPhoneNumber:query];
                [self setNeedsDisplay];

            }
            else {
                [self.ovatar setKey:query];
                [self setNeedsDisplay];

            }

        }
        else {
            if ([self.ovatar imageFromCache:query]) {
                [self imageSet:[self.ovatar imageFromCache:query] animated:self.animated];

            }
            else {
                if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_EMAIL] evaluateWithObject:query] || [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_PHONE] evaluateWithObject:query]) {
                    [self.ovatar returnOvatarIconWithQuery:query completion:^(NSError *error, id output) {
                        if ([output isKindOfClass:[UIImage class]]) {
                            [self imageSet:(UIImage *)output animated:self.animated];
                            [self.ovatar imageSaveToCache:(UIImage *)output identifyer:query];

                        }
                        
                    }];

                }
                else {
                    [self.ovatar returnOvatarIconWithKey:query completion:^(NSError *error, id output) {
                        if ([output isKindOfClass:[UIImage class]]) {
                            [self imageSet:(UIImage *)output animated:self.animated];
                            [self.ovatar imageSaveToCache:(UIImage *)output identifyer:query];
                            
                        }
                        
                    }];
                    
                }

            }
        
        }
        
    }
    else [self imageSet:self.placeholder animated:self.animated];

}

-(void)imageUpdateWithImage:(NSData *)image {
    NSString *user;
    if (self.ovatar.ovatarEmail != nil) user = self.ovatar.ovatarEmail;
    else user = self.ovatar.ovatarPhoneNumber;
    
    [self.ovatar uploadOvatar:image user:user];
    [self.ovatar imageSaveToCache:[UIImage imageWithData:image] identifyer:user];
    
}

-(OImageSize)imageSize:(CGRect)rect {
    if (rect.size.width <= (30.0)) return OImageSizeSmall;
    else if (rect.size.width >= (120 / 2) && rect.size.width <= (350 / 2)) return OImageSizeMedium;
    else return OImageSizeLarge;

}

-(void)ovatarIconWasUpdatedSucsessfully:(NSDictionary *)output {
    [self.ovatar imageCacheDestroy];
    [self setNeedsDisplay];
    
    if ([self.oicondelegate respondsToSelector:@selector(ovatarIconWasUpdatedSucsessfully:)]) {
        [self.oicondelegate ovatarIconWasUpdatedSucsessfully:output];
        
    }
    
}

-(void)ovatarIconUploadFailedWithErrors:(NSError *)error {
    if ([self.oicondelegate respondsToSelector:@selector(ovatarIconUploadFailedWithErrors:)]) {
        [self.oicondelegate ovatarIconUploadFailedWithErrors:error];
        
    }
    
}

-(void)ovatarIconUploadingWithProgress:(float)progress {
    if ([self.oicondelegate respondsToSelector:@selector(ovatarIconUploadingWithProgress:)]) {
        [self.oicondelegate ovatarIconUploadingWithProgress:progress];
        
    }
    
}

@end
