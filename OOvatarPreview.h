//
//  OOvatarPreview.h
//  Ovatar
//
//  Created by Joe Barbour on 11/06/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OOvatar.h"

@interface OOvatarPreview : UIView <UIGestureRecognizerDelegate> {
    UIView *container;
    UIPanGestureRecognizer *gesture;
    UIImageView *ovatar;
    UIButton *logo;
    CGRect oframe;
    CGPoint oposition;

}

-(void)previewPresent:(UIImageView *)icon caption:(NSString *)caption;
-(void)previewUpdate:(UIImage *)image;

@property (nonatomic, strong) id customicon;
@property (nonatomic, assign) float rounded;

@property (nonatomic, strong) OOvatar *ovatar;

@end
