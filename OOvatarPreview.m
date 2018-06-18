//
//  OOvatarPreview.m
//  Ovatar
//
//  Created by Joe Barbour on 11/06/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OOvatarPreview.h"

@implementation OOvatarPreview

-(void)previewPresent:(UIImageView *)icon caption:(NSString *)caption {
    UIApplication *application = [UIApplication sharedApplication];
    oframe = [self.superview convertRect:icon.frame fromView:self];

    if (self.rounded == 0) self.rounded = 2.0;
    
    if (![container isDescendantOfView:application.delegate.window.superview]) {
        container = [[UIView alloc] initWithFrame:application.delegate.window.bounds];
        container.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
        
        profile = [[UIImageView alloc] initWithFrame:oframe];
        profile.backgroundColor = [UIColor clearColor];
        profile.clipsToBounds = true;
        profile.image = icon.image;
        profile.userInteractionEnabled = true;
        profile.layer.cornerRadius = icon.layer.cornerRadius;
        
        [application.delegate.window setWindowLevel:UIWindowLevelNormal];
        [application.delegate.window addSubview:container];
        [application.delegate.window addSubview:profile];
        
        gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        gesture.enabled = true;
        gesture.delegate = self;
        [profile addGestureRecognizer:gesture];
        
        logo = [[UIButton alloc] initWithFrame:CGRectMake(container.bounds.size.width - 48.0, container.bounds.size.height - 48.0, 20.0, 20.0)];
        logo.backgroundColor = [UIColor clearColor];
        logo.layer.cornerRadius = 4.0;
        [logo.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [logo addTarget:self action:@selector(details) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:logo];
        
        CGFloat aspectwidth = container.bounds.size.width / icon.image.size.width;
        CGFloat aspectheight = container.bounds.size.height;
        CGFloat aspectratio = MIN(aspectwidth, aspectheight);
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if (container.bounds.size.width > 0 && container.bounds.size.height > 0) {
                [profile.layer setCornerRadius:self.rounded];
                [profile setFrame:CGRectMake
                    (5.0 + (container.bounds.size.width / 2) - ((icon.image.size.width * aspectratio) / 2),
                    (5.0 + container.bounds.size.height / 2) - ((icon.image.size.height * aspectratio) / 2),
                    ((icon.image.size.width * aspectratio) - 10.0),
                    ((icon.image.size.height * aspectratio) - 10.0))];
                
            }
            
        } completion:^(BOOL finished) {
            [self icon];
            
        }];
        
    }
    
}

-(void)previewUpdate:(UIImage *)image {
    [profile setImage:image];
    
}

-(void)gesture:(UIPanGestureRecognizer *)gesture {
    oposition = [gesture translationInView:container.superview];
    if (gesture.state == UIGestureRecognizerStateChanged) {
        [profile setCenter:CGPointMake(container.bounds.size.width / 2, container.center.y + (oposition.y / 4))];
        [container setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85 - ((fabs(oposition.y) / 1000.0))]];
        
    }
    else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded) {
        if (oposition.y < -240.0 || oposition.y > 240.0) {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [profile setFrame:oframe];

            } completion:^(BOOL finished) {
                [container removeFromSuperview];
                [profile removeFromSuperview];
                [self removeFromSuperview];

            }];

        }
        else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [profile setFrame:CGRectMake(5.0, (container.bounds.size.height / 2) - (profile.bounds.size.height / 2), profile.bounds.size.width, profile.bounds.size.height)];
                
            } completion:nil];
            
        }

    }

}

-(void)icon {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    if ([cache objectForKey:@"ovatar_logo_action"] != nil) {
        [logo setImage:[UIImage imageWithData:[cache objectForKey:@"ovatar_logo_action"]] forState:UIControlStateNormal];

    }
    else {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://ovatar.io/assets/LogoIcon.png"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([UIImage imageWithData:data] != nil) {
                    [cache setObject:data forKey:@"ovatar_logo_action"];
                    [logo setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                    
                }
                
            }];
            
        }];
        
        [task resume];
        
    }
    
}

-(void)details {
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://ovatar.io/"]];
    if (@available(iOS 11.0, *)) {
        safari.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleDone;
        
    }
    safari.delegate = self;
    
    [(UINavigationController  *)self.window.rootViewController presentViewController:safari animated:true completion:^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
        
    }];
    
}

@end
