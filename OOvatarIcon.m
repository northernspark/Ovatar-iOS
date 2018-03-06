//
//  OOvatarIcon.m
//  Ovatar
//
//  Created by Joe Barbour on 13/01/2017.
//  Copyright © 2017 Ovatar. All rights reserved.
//

#import "OOvatarIcon.h"
#import "OOvatar.h"

@implementation OOvatarIcon

-(void)drawRect:(CGRect)rect {
    self.ovatar = [OOvatar sharedInstance];
    self.ovatar.placeholder = self.placeholder;
    self.ovatar.output = self.placeholder==nil?OOutputTypeDefault:OOutputType404;
    self.ovatar.debug = true;
    self.ovatar.size = [self imageSize:self.bounds];
    self.ovatar.odelegate = self;

    self.onlyfaces = false;
    self.animated = true;
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
    
    if (self.key != nil && self.key.length > 0) {
        if ([self imageFromCache:self.key] == nil) {
            [self.ovatar returnOvatarIconWithKey:self.key completion:^(NSError *error, id output) {
                if (error.code == 200) {
                    if ([output isKindOfClass:[UIImage class]]) {
                        [self imageSet:(UIImage *)output animated:self.animated];
                        [self imageSaveToCache:(UIImage *)output identifyer:self.key];

                    }
                    
                }
                else if (error.code == 404) {
                    [self imageSet:self.placeholder animated:self.animated];
                    
                }
                else {
                    [self imageSet:[self imageFromCache:self.key] animated:self.animated];
                    
                }
                
            }];
            
        }
        else [self imageSet:[self imageFromCache:self.key] animated:self.animated];
        
    }
    
    if ((self.email != nil && self.email.length > 0) || (self.phone != nil && self.phone.length > 0)) {
        NSString *user;
        if (self.email != nil) user = self.email;
        else user = self.phone;
        
        if ([self imageFromCache:user] == nil) {
            [self.ovatar returnOvatarIconWithQuery:user completion:^(NSError *error, id output) {
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
            
        }
        else [self imageSet:[self imageFromCache:user] animated:self.animated];

    }
    
}

-(void)imageTappedWithGesture:(UITapGestureRecognizer *)gesture {
    if ([self.odelegate respondsToSelector:@selector(ovatarIconWasTappedWithGesture:)]) {
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
        
        [self.odelegate ovatarIconWasTappedWithGesture:gesture];
        
    }
    
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

-(void)imageUpdateWithImage:(UIImage *)image {
    NSString *user;
    if (self.email != nil) user = self.email;
    else user = self.phone;
    
    [self.ovatar uploadOvatar:image user:user];
    [self imageFromCache:nil];
    
}

-(OImageSize)imageSize:(CGRect)rect {
    if (rect.size.width <= (120 / 2)) return OImageSizeSmall;
    else if (rect.size.width <= (350 / 2)) return OImageSizeMedium;
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
