//
//  OOvatar.h
//  Ovatar
//
//  Created by Joe Barbour on 13/01/2017.
//  Copyright © 2017 Ovatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#define OVATAR_HOST @"https://ovatar.io/api/"
#define OVATAR_REGEX_PHONE @"(\\+)[0-9\\+\\-]{6,19}"
#define OVATAR_REGEX_EMAIL @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

@protocol OOvatarDelegate;
@interface OOvatar : NSObject <NSURLSessionDataDelegate, NSURLSessionDelegate>
typedef NS_ENUM(NSInteger, OImageSize) {
    OImageSizeLarge,
    OImageSizeMedium,
    OImageSizeSmall

};

typedef NS_ENUM(NSInteger, OImageLoader) {
    OImageLoaderProgress,
    OImageLoaderDownloading
};


typedef NS_ENUM(NSInteger, OOutputType) {
    OOutputTypeJSON,
    OOutputType404,
    OOutputTypeDefault,
    
};

typedef NS_ENUM(NSInteger, OEndpoint) {
    OEndpointUser,
    OEndpointCelebrity,
    
};

@property (weak, nonatomic) id <OOvatarDelegate> odelegate;
@property (nonatomic ,assign) OImageSize size;
@property (nonatomic ,assign) OOutputType output;
@property (nonatomic ,assign) UIImage *placeholder;

@property (nonatomic ,weak) NSString *okey;
@property (nonatomic ,weak) NSString *oquery;

+(OOvatar *)sharedInstance;
+(void)sharedInstanceWithAppKey:(NSString *)appKey;
//Must be added to the app delegate with application key which can be found at http://ovatar.io

-(void)setOvatarImage:(NSString *)email phonenumber:(NSString *)phone fullname:(NSString *)name key:(NSString *)key originalImage:(NSURL *)image;
-(void)setEmail:(NSString *)email;
-(void)setPhoneNumber:(NSString *)phone;
-(void)setName:(NSString *)name;
-(void)setKey:(NSString *)key;
-(void)setDebugging:(BOOL)enabled;
-(void)setPrivateArchive:(BOOL)enabled;
-(void)setGravatarFallback:(BOOL)enabled;
-(void)setCacheExpirySeconds:(int)seconds;

-(NSString *)ovatarEmail;
-(NSString *)ovatarPhoneNumber;
-(NSString *)ovatarKey;
-(NSURL *)ovatarMigrationURL;

-(NSDictionary *)ovatarAppInformation;

-(void)returnOvatarIconWithQuery:(NSString *)query completion:(void (^)(NSError *error, id output))completion;
-(void)returnOvatarIconWithKey:(NSString *)key completion:(void (^)(NSError *error, id output))completion;
-(void)returnOvatarCelebrityIconWithQuery:(NSString *)query completion:(void (^)(NSError *error, id output))completion;
-(void)returnOvatarAppInformation:(void (^)(NSDictionary *app, NSError *error))completion;

-(void)uploadOvatar:(NSData *)image metadata:(NSDictionary *)metadata user:(NSString *)user background:(BOOL)background;

-(void)imageCacheDestroy:(NSString *)item;
-(void)imageSaveToCache:(UIImage *)image identifyer:(NSString *)identifyer;
-(UIImage *)imageFromCache:(NSString *)identifyer expired:(BOOL)show;
-(int)imageDetectFace:(UIImage *)image;
-(NSArray *)imageTypes:(PHAsset *)asset image:(UIImage *)image;

@end

@protocol OOvatarDelegate <NSObject>

-(void)ovatarIconWasUpdatedSucsessfully:(NSDictionary *)output;
-(void)ovatarIconUploadFailedWithErrors:(NSError *)error;
-(void)ovatarIconUploadingWithProgress:(float)progress;

@end
