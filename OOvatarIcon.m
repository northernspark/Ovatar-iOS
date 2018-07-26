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
    
    self.opreview = [[OOvatarPreview alloc] init];
    self.opreview.backgroundColor = [UIColor clearColor];

    self.crossfade = 0.6;
    self.preview = false;
    self.animated = true;
    self.presentpicker = true;
    self.progressloader = false;
    self.contentMode = UIViewContentModeScaleAspectFill;

    if (![self.subviews containsObject:self.container]) {
        self.container = [[UIImageView alloc] initWithFrame:self.bounds];
        self.container.backgroundColor = [UIColor clearColor];
        self.container.contentMode = self.contentMode;
        self.container.image = self.placeholder;
        self.container.userInteractionEnabled = true;
        [self addSubview:self.container];
        
        loadercontainer = [[UIView alloc] initWithFrame:self.container.bounds];
        loadercontainer.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:154.0/255.0 blue:214.0/255.0 alpha:0.6];
        loadercontainer.hidden = !self.progressloader;
        loadercontainer.transform = CGAffineTransformMakeScale(1.08, 1.08);
        loadercontainer.alpha = 0.0;
        loadercontainer.userInteractionEnabled = false;
        //[self.container addSubview:loadercontainer];
        
        loader = [CAShapeLayer layer];
        loader.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(6.0, 6.0, loadercontainer.bounds.size.width - 24.0, loadercontainer.bounds.size.height - (24.0)) cornerRadius:loadercontainer.bounds.size.width].CGPath;
        loader.position = CGPointMake(6.0, 6.0);
        loader.fillColor = [UIColor clearColor].CGColor;
        loader.strokeColor = [UIColor whiteColor].CGColor;
        loader.lineWidth = 3;
        loader.lineCap = kCALineCapRound;
        //[loadercontainer.layer addSublayer:loader];
        
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTappedWithGesture:)];
        gesture.delegate = self;
        gesture.enabled = true;
        [self.container addGestureRecognizer:gesture];
        
        [self imageLoader:OImageLoaderDownloading progress:1];
        
    }
    
    if (self.hasaction) {
        if (self.ovatar.ovatarKey != nil && self.ovatar.ovatarKey.length > 0) {
            if ([self.ovatar imageFromCache:self.ovatar.ovatarKey expired:false] == nil) {
                [self imageSet:[self.ovatar imageFromCache:self.ovatar.ovatarKey expired:true] animated:self.animated];
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
                            [self imageSet:[self.ovatar imageFromCache:self.ovatar.ovatarKey expired:false] animated:self.animated];
                            
                        }
                        
                    }];
                    
                }];
                
            }
            else [self imageSet:[self.ovatar imageFromCache:self.ovatar.ovatarKey expired:false] animated:self.animated];
            
        }
        else if ((self.ovatar.ovatarEmail != nil && self.ovatar.ovatarEmail.length > 0) || (self.ovatar.ovatarPhoneNumber != nil && self.ovatar.ovatarPhoneNumber.length > 0)) {
            NSString *user;
            if (self.ovatar.ovatarEmail != nil) user = self.ovatar.ovatarEmail;
            else user = self.ovatar.ovatarPhoneNumber;

            if ([self.ovatar imageFromCache:user expired:false] == nil) {
                [self imageSet:[self.ovatar imageFromCache:user expired:true] animated:self.animated];
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
                                
                            }
                            else {
                                [self imageSet:self.placeholder animated:self.animated];
                                [self.ovatar imageSaveToCache:self.placeholder identifyer:self.ovatar.ovatarKey];
                            }
                            
                        }
                        else {
                            [self imageSet:[self.ovatar imageFromCache:user expired:false] animated:self.animated];
                            
                        }
                        
                    }];
                    
                }];
                
            }
            else [self imageSet:[self.ovatar imageFromCache:user expired:false] animated:self.animated];

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
    else {
        if (self.preview) {
            [self.opreview previewPresent:self.container caption:self.previewcaption];
            NSLog(@"present preview");
        }
        
    }
    
    NSLog(@"present preview: %@" ,self.preview?@"yes":@"no");

    
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
        
        if (self.onlyfaces) {
            if ([self.ovatar imageDetectFace:output] > 0) {
                NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:info];
                [append setObject:@([self.ovatar imageDetectFace:output]) forKey:@"faces"];
                
                [self imageUpdateWithImage:UIImageJPEGRepresentation(output, 0.8) info:append];
                
            }
            else {
                NSLog(@"\n\nOVATAR ERROR: Image does not contain any human faces\n\n");
                if ([self.oicondelegate respondsToSelector:@selector(ovatarIconUploadFailedWithErrors:)]) {
                    [self ovatarIconUploadFailedWithErrors:[NSError errorWithDomain:@"Image does not contain any human faces" code:415 userInfo:nil]];
                    
                }
                
            }
        }
        else [self imageUpdateWithImage:UIImageJPEGRepresentation(output, 0.8) info:info];
        
    }];
    
}

-(void)imageSet:(UIImage *)image animated:(BOOL)animated {
    [self imageLoader:OImageLoaderDownloading progress:0];
    if (animated) {
        [UIView transitionWithView:self.container duration:self.crossfade options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (image.CGImage != NULL && image.CGImage != nil) {
                [self.container setImage:image];
                
            }
            
        } completion:nil];
        
    }
    else [self.container setImage:image];

}

-(void)imageDownloadWithQuery:(NSString *)query {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
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
                if ([self.ovatar imageFromCache:query expired:false]) {
                    [self imageSet:[self.ovatar imageFromCache:query expired:true] animated:self.animated];

                }
                else {
                    [self imageSet:[self.ovatar imageFromCache:query expired:true] animated:self.animated];
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
        
    }];

}

-(void)imageDownloadWithQuery:(NSString *)query name:(NSString *)name {
    [self.ovatar setName:name];
    [self imageDownloadWithQuery:query];
    
}

-(void)imageUpdateWithImage:(NSData *)image info:(NSDictionary *)info {
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    PHAsset *asset = fetchResult.firstObject;
    
    NSString *type;
    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoPanorama) type = @"panorama";
    else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoScreenshot) type = @"screencapture";
    else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = @"livephoto";
    else type = @"livephoto";
    
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    [metadata setObject:@((float)asset.location.coordinate.latitude) forKey:@"latitude"];
    [metadata setObject:@((float)asset.location.coordinate.longitude) forKey:@"longitude"];
    [metadata setObject:type forKey:@"type"];

    NSString *user;
    if (self.ovatar.ovatarEmail != nil && self.ovatar.ovatarPhoneNumber == nil) user = self.ovatar.ovatarEmail;
    else if (self.ovatar.ovatarEmail == nil && self.ovatar.ovatarPhoneNumber != nil) user = self.ovatar.ovatarPhoneNumber;
    else if (self.ovatar.ovatarEmail != nil && self.ovatar.ovatarPhoneNumber != nil) {
        user = [NSString stringWithFormat:@"%@|%@" ,self.ovatar.ovatarEmail, self.ovatar.ovatarPhoneNumber];
        
    }
    
    [self.ovatar uploadOvatar:image metadata:metadata user:user background:false];
    [self.ovatar imageSaveToCache:[UIImage imageWithData:image] identifyer:user];
    
}

-(OImageSize)imageSize:(CGRect)rect {
    if (rect.size.width <= (30.0)) return OImageSizeSmall;
    else if (rect.size.width >= (120 / 2) && rect.size.width <= (350 / 2)) return OImageSizeMedium;
    else return OImageSizeLarge;

}

-(void)imageLoader:(OImageLoader)type progress:(float)progress {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.byValue = [NSNumber numberWithFloat:2.0f*M_PI];
    rotate.duration = 2;
    rotate.repeatCount = MAXFLOAT;
    
    if (type == OImageLoaderProgress) {
        [loader setStrokeEnd:0.0];
        [loader setStrokeEnd:progress * 3.6];
        
    }
    else {
        [loader setStrokeEnd:0.0];
        [loader setStrokeEnd:280.0];
    }
    
    if ([loader animationForKey:@"circle"]) {
        [loadercontainer.layer addAnimation:rotate forKey:@"rotate"];

    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (progress > 0 && progress <= 1) {
            [loadercontainer setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [loadercontainer setAlpha:1.0];
            
        }
        else {
            [loadercontainer setTransform:CGAffineTransformMakeScale(1.08, 1.08)];
            [loadercontainer setAlpha:0.0];
            
        }
        
    } completion:nil];
    
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
    
    if (self.progressloader) {
        [self imageLoader:OImageLoaderProgress progress:progress];
        
    }
    
}

@end
