//
//  OOvatarContacts.m
//  BizaarWOW-iOS-Client
//
//  Created by Joe Barbour on 26/01/2019.
//  Copyright © 2019 BizaarWOW. All rights reserved.
//

#import "OOvatarContacts.h"

@implementation OOvatarContacts

-(instancetype)init {
    self = [super init];
    if (self) {
        self.ovatar = [OOvatar sharedInstance];
        self.ovatar.odelegate = self;
        
    }
    return self;
    
}

-(void)contactFromQuery:(NSString *)query completion:(void (^)(NSDictionary *user))completion {
    [self contactsReturn:^(NSArray *contacts, int count) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@ || phone == %@" ,query, query];
        NSDictionary *output = [[contacts filteredArrayUsingPredicate:predicate] lastObject];
        
        completion(output);
        
    }];
    
}

-(void)contactUpload {
    [self contactsGrantAccess:^(bool granted, NSError *error) {
        if (granted) {
            if (self.uploading == nil) {
                [self contactsReturn:^(NSArray *contacts, int count) {
                    self.uploading = [[NSMutableArray alloc] initWithArray:contacts];

                    [self contactUpload];
                    
                }];
                
            }
            
            if ([self.uploading count] > 0) {
                if (![self.contactsProcessed containsObject:[self.uploading.lastObject objectForKey:@"id"]]) {
                    NSMutableArray *user = [[NSMutableArray alloc] init];
                    [user addObjectsFromArray:[self.uploading.lastObject objectForKey:@"email"]];
                    [user addObjectsFromArray:[self.uploading.lastObject objectForKey:@"phone"]];

                    NSString *userdata = [user componentsJoinedByString:@"|"];
                
                    NSLog(@"uploading %@" ,self.uploading.lastObject);
                    if ([[self.uploading.lastObject objectForKey:@"thumbnail"] length] > 20) {
                        [[OOvatar sharedInstance] uploadOvatar:[self.uploading.lastObject objectForKey:@"thumbnail"] metadata:nil user:userdata background:false];

                    }
                    else {
                        [self.contactsProcessed addObject:[self.uploading.lastObject objectForKey:@"id"]];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:self.contactsProcessed forKey:@"ovatar_contact_processed"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [self.uploading removeLastObject];
                        [self contactUpload];
                        
                    }
                
                }
            
            }
            
        }
        
    }];
    
}

-(NSMutableArray *)contactsProcessed {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_contact_processed"] count] == 0) return [[NSMutableArray alloc] init];
    else return [[[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_contact_processed"] mutableCopy];
    
}

-(BOOL)contactsAuthorized {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        return true;
        
    }
    else return false;
    
}

-(void)contactsGrantAccess:(void (^)(bool granted, NSError *error))completion {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        completion(true, nil);
        
    }
    else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            completion(granted, error);
            
        }];
        
    }
    else completion(false, [NSError errorWithDomain:@"not authorized" code:403 userInfo:nil]);
    
}

-(NSArray *)contactRequestKeys {
    return @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
             CNContactEmailAddressesKey,
             CNContactPhoneNumbersKey,
             CNContactThumbnailImageDataKey,
             CNContactOrganizationNameKey,
             CNContactBirthdayKey];
    
}

-(void)contactsReturn:(void (^)(NSArray *contacts, int count))completion {
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    CNContactStore *store = [[CNContactStore alloc] init];
    CNContactFetchRequest *fetch = [[CNContactFetchRequest alloc] initWithKeysToFetch:[self contactRequestKeys]];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [store containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers:@[store.defaultContainerIdentifier]] error:nil];
        [store enumerateContactsWithFetchRequest:fetch error:nil usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
            [contacts addObject:@{@"id":contact.identifier,
                                  @"email":[self contactsFormatEmail:contact],
                                  @"phone":[self contactsFormatPhone:contact],
                                  @"thumbnail":contact.thumbnailImageData==nil?[NSData data]:contact.thumbnailImageData}];
            
            
            
        }];
        
        completion(contacts, (int)contacts.count);
        
    });
    
}

-(NSArray *)contactsFormatEmail:(CNContact *)contact {
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    for (CNLabeledValue *email in contact.emailAddresses) {
        NSString *formatted = [email valueForKey:@"value"];
        
        [emails addObject:formatted];
        
    }
    
    return emails;
    
}

-(NSArray *)contactsFormatPhone:(CNContact *)contact {
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for (CNLabeledValue *phone in contact.phoneNumbers) {
        CNPhoneNumber *digits = phone.value;
        NSCharacterSet *characters = [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet];
        NSString *number = [[digits.stringValue componentsSeparatedByCharactersInSet:characters] componentsJoinedByString:@""];
        
        [phones addObject:number];
        
    }
    
    return phones;
    
}

-(void)ovatarIconWasUpdatedSucsessfully:(NSDictionary *)output {
    NSLog(@"ovatarIconWasUpdatedSucsessfully %@" ,output);
    
    [self.contactsProcessed addObject:[self.uploading.lastObject objectForKey:@"id"]];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.contactsProcessed forKey:@"ovatar_contact_processed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.uploading removeLastObject];
    [self contactUpload];
    
}

-(void)ovatarIconUploadFailedWithErrors:(NSError *)error {
    NSLog(@"ovatarIconUploadFailedWithErrors %@" ,error);

}


@end
