//
//  OOvatarContacts.h
//  BizaarWOW-iOS-Client
//
//  Created by Joe Barbour on 26/01/2019.
//  Copyright © 2019 BizaarWOW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ContactsUI/ContactsUI.h>
#import <UIKit/UIKit.h>

#import "OOvatar.h"

@interface OOvatarContacts : NSObject <OOvatarDelegate>

-(void)contactFromQuery:(NSString *)query completion:(void (^)(NSDictionary *user))completion;
-(void)contactUpload;

@property (nonatomic, strong) NSMutableArray *uploading;
@property (nonatomic, strong) OOvatar *ovatar;

@end
