//
//  OOvatar.h
//  Ovatar
//
//  Created by Joe Barbour on 13/01/2017.
//  Copyright © 2017 Ovatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol OOvatarDelegate;
@interface OOvatar : NSObject <NSURLSessionTaskDelegate>

typedef NS_ENUM(NSInteger, OImageSize) {
    OImageSizeLarge,
    OImageSizeMedium,
    OImageSizeSmall

};

typedef NS_ENUM(NSInteger, OOutputType) {
    OOutputTypeJSON,
    OOutputType404,
    OOutputTypeDefault,
    
};

@property (weak, nonatomic) id <OOvatarDelegate> odelegate;
@property (nonatomic ,assign) OImageSize size;
@property (nonatomic ,assign) OOutputType output;
@property (nonatomic ,assign) UIImage *placeholder;
@property (nonatomic ,assign) BOOL gravatar;
@property (nonatomic ,assign) BOOL debug;
@property (nonatomic ,assign) BOOL backgroundupload;
@property (nonatomic ,assign) BOOL privatearchive;

+(OOvatar *)sharedInstance;
+(void)sharedInstanceWithAppKey:(NSString *)appKey;

-(void)setEmail:(NSString *)email;
-(void)setPhoneNumber:(NSString *)phone;
-(void)setKey:(NSString *)key;

-(NSString *)ovatarEmail;
-(NSString *)ovatarPhoneNumber;
-(NSString *)ovatarKey;

-(void)returnOvatarIconWithQuery:(NSString *)query completion:(void (^)(NSError *error, id output))completion;
-(void)returnOvatarIconWithKey:(NSString *)key completion:(void (^)(NSError *error, id output))completion;

-(void)uploadOvatar:(NSData *)image user:(NSString *)user;

@end

@protocol OOvatarDelegate <NSObject>

-(void)ovatarIconWasUpdatedSucsessfully:(NSDictionary *)output;
-(void)ovatarIconUploadFailedWithErrors:(NSError *)error;
-(void)ovatarIconUploadingWithProgress:(float)progress;

@end
