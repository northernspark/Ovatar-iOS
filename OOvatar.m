//
//  OOvatar.m
//  Ovatar
//
//  Created by Joe Barbour on 13/01/2017.
//  Copyright © 2017 Ovatar. All rights reserved.
//

#import "OOvatar.h"

@implementation OOvatar

static NSString *token;

+(void)sharedInstanceWithAppKey:(NSString *)appKey {
    token = appKey;
    
}

+(OOvatar *)sharedInstance {
    if (![token containsString:@"app"]) {
        NSLog(@"\n\nOVATAR ERROR: App key required. If you do not have an app key please signup to Ovatar at https://ovatar.io\n\n");
        return nil;
        
    }
    else {
        return [[OOvatar alloc] init];;

    }
    
}

-(void)returnOvatarAppInformation:(void (^)(NSDictionary *app, NSError *error))completion {
    NSString *url = [NSString stringWithFormat:@"%@app/info" ,OVATAR_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request addValue:token forHTTPHeaderField:@"oappkey"];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSDictionary *output = [[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject] objectForKey:@"output"];
            for (NSString *key in output.allKeys) {
                if (key != nil) {
                    [[NSUserDefaults standardUserDefaults] setObject:[output objectForKey:key] forKey:[NSString stringWithFormat:@"ovatar_app_%@" ,key]];
                    
                }
                
            }

            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ovatar_app_queried"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }];
        
    }];
    
    [task resume];
    
}

-(void)returnOvatarCelebrityIconWithQuery:(NSString *)query completion:(void (^)(NSError *error, id output))completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:query forKey:@"query"];
    
    if ([query length] > 2) {
        [self requestOvatarImageWithParameters:params endpoint:OEndpointCelebrity completion:^(NSError *error, id output) {
            completion(error, output);
            
        }];
        
    }
    
}

-(void)returnOvatarIconWithKey:(NSString *)key completion:(void (^)(NSError *error, id output))completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:key forKey:@"id"];

    if (self.ovatarAppInformation == nil) {
        [self returnOvatarAppInformation:^(NSDictionary *app, NSError *error) {
            
        }];
        
    }
    
    if (key.length > 2) {
        [self requestOvatarImageWithParameters:params endpoint:OEndpointUser completion:^(NSError *error, id output) {
            completion(error, output);

        }];
        
    }
    
    self.okey = key;

    
}

-(void)returnOvatarIconWithQuery:(NSString *)query completion:(void (^)(NSError *error, id output))completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:query forKey:@"query"];
    
    if (self.ovatarAppInformation == nil) {
        [self returnOvatarAppInformation:^(NSDictionary *app, NSError *error) {
            
        }];
        
    }
    
    if (query.length > 2) {
        [self requestOvatarImageWithParameters:params endpoint:OEndpointUser completion:^(NSError *error, id output) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completion(error, output);
                
            }];
            
        }];
        
    }
    
    self.oquery = query;

}

-(void)requestOvatarImageWithParameters:(NSDictionary *)params endpoint:(OEndpoint)endpoint completion:(void (^)(NSError *error, id output))completion {
    NSMutableString *buildendpoint = [[NSMutableString alloc] init];
    [buildendpoint appendString:OVATAR_HOST];
    if (endpoint == OEndpointUser) [buildendpoint appendString:@"ovatar"];
    else if (endpoint == OEndpointUser) [buildendpoint appendString:@"celebrity"];
    [buildendpoint appendString:@"?"];
    [buildendpoint appendString:[NSString stringWithFormat:@"fallback=%@&" ,[[[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_gravatar"] boolValue]?@"true":@"false"]];

    if (self.size == OImageSizeLarge) [buildendpoint appendString:@"size=large&"];
    else if (self.size == OImageSizeMedium) [buildendpoint appendString:@"size=medium&"];
    else if (self.size == OImageSizeSmall) [buildendpoint appendString:@"size=small&"];
    
    if (self.output == OOutputType404) [buildendpoint appendString:@"placeholder=404&"];
    else if (self.output == OOutputTypeJSON) [buildendpoint appendString:@"placeholder=json&"];
    else if (self.output == OOutputTypeDefault) [buildendpoint appendString:@"placeholder=default&"];

    for (NSString *key in params.allKeys) {
        [buildendpoint appendString:[NSString stringWithFormat:@"%@=%@&" ,key ,[params objectForKey:key]]];
        
    }
    
    [buildendpoint setString:[buildendpoint substringWithRange:NSMakeRange(0, buildendpoint.length - 1)]];
        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:buildendpoint] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request addValue:token forHTTPHeaderField:@"oappkey"];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
            if (data.length > 0 && !error) {
                if ([NSJSONSerialization JSONObjectWithData:data options:0 error:nil] != nil) {
                    NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                    NSError *err = [self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:buildendpoint];
                    
                    completion(err ,output);

                }
                else if ([UIImage imageWithData:data] != nil) {
                    NSError *err = [NSError errorWithDomain:@"" code:(int)status.statusCode userInfo:nil];
                    if (status.statusCode == 404) {
                        if (endpoint == OEndpointUser) {
                            if ([self contactsAuthorized] && [params objectForKey:@"query"] != nil) {
                                [self contactFromQuery:[params objectForKey:@"query"] completion:^(NSDictionary *user) {
                                    if ([user objectForKey:@"thumbnail"] != nil) {
                                        NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
                                        NSMutableString *userdata = [[NSMutableString alloc] init];
                                        if ([user objectForKey:@"email"]) {
                                            [userdata appendString:[user objectForKey:@"email"]];
                                            
                                        }
                                        
                                        if ([userdata length] > 0) {
                                            [userdata appendString:@"|"];

                                        }
                                        
                                        if ([user objectForKey:@"phone"]) {
                                            [userdata appendString:[user objectForKey:@"phone"]];
                                            
                                        }
                                  
                                        [self uploadOvatar:[user objectForKey:@"thumbnail"] metadata:metadata user:userdata background:true];
                                        
                                    }
                                    
                                }];
                                
                            }
                            else completion(err ,nil);
                            
                        }
                        else completion(err ,nil);
                        
                    }
                    else {
                        UIImage *output = [UIImage imageWithData:data];
                        
                        completion(err ,output);

                    }
                    
                }
                
            }
            else {
                NSError *err = [self requestErrorHandle:(int)status.statusCode message:error.domain error:error endpoint:buildendpoint];

                completion(err ,nil);

            }
            
        }];
            
    }];
    
    if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR LOADING: ✍️ GET: %@\n\n", buildendpoint);
    
    [task resume];
    
}

-(void)uploadOvatar:(NSData *)image metadata:(NSDictionary *)metadata user:(NSString *)user background:(BOOL)background {
    NSOperationQueue *queue;
    if (background) {
        queue = [[NSOperationQueue alloc] init];
        queue.qualityOfService = NSQualityOfServiceBackground;

    }
    else queue = [NSOperationQueue mainQueue];
    
    NSMutableString *buildendpoint = [[NSMutableString alloc] init];
    [buildendpoint appendString:OVATAR_HOST];
    [buildendpoint appendString:@"upload"];
    
    NSMutableString *formatdata = [[NSMutableString alloc] init];
    [formatdata appendString:[image base64EncodedStringWithOptions:0]];
    
    NSMutableDictionary *endpointparams = [[NSMutableDictionary alloc] init];
    [endpointparams setValue:formatdata forKey:@"ovatar"];
    [endpointparams setValue:@([[[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_private_archive"] boolValue]) forKey:@"private"];
    [endpointparams setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_name"] forKey:@"fullname"];
    [endpointparams setValue:user forKey:@"user"];

    if (metadata != nil) [endpointparams addEntriesFromDictionary:metadata];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:buildendpoint] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request addValue:token forHTTPHeaderField:@"oappkey"];
    [request addValue:[[UIDevice currentDevice] name] forHTTPHeaderField:@"odevice"];
    [request addValue:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] forHTTPHeaderField:@"ocountry"];
    [request addValue:@"ios" forHTTPHeaderField:@"oplatform"];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:endpointparams options:NSJSONWritingPrettyPrinted error:nil]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionUploadTask *task = [session uploadTaskWithStreamedRequest:request];

    if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR LOADING: ✍️ POST: %@\n\n", buildendpoint);

    [task resume];
    
}

-(NSError *)requestErrorHandle:(int)code message:(NSString *)message error:(NSError *)error endpoint:(NSString *)endpoint {
    NSError *err;
    if (error) err = [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    else if (message == nil && error == nil) err = [NSError errorWithDomain:@"unknown error" code:600 userInfo:nil];
    else if (message == nil && error.localizedDescription != nil) [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    else err = [NSError errorWithDomain:message code:code userInfo:nil];
    
    if (err == nil || err.code == 200) {
        if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR SUCSESS: %d 🎉 %@\n\n" ,code ,endpoint);
        
    }
    else if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR ERROR: %d 🎉 %@\n\n" ,code ,message);
    
    return err;
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent
   totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        CGFloat progress = (float)totalBytesSent/totalBytesExpectedToSend;
        if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR IMAGE UPLOAD PROGRESS: %f%%\n\n" ,progress * 100);
        
        if ([self.odelegate respondsToSelector:@selector(ovatarIconUploadingWithProgress:)]) {
            [self.odelegate ovatarIconUploadingWithProgress:progress];
            
        }
        
    }];
    
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
        if ([[output objectForKey:@"error_code"] intValue] == 200) {
            NSDictionary *content = [output objectForKey:@"output"];
            NSString *type = [content objectForKey:@"type"];
            NSString *key = [content objectForKey:@"key"];

            [self setKey:key];
            
            if ([type isEqualToString:@"email"]) [self setEmail:[content objectForKey:@"user"]];
            else [self setPhoneNumber:[content objectForKey:@"user"]];
            
            if ([self.odelegate respondsToSelector:@selector(ovatarIconWasUpdatedSucsessfully:)]) {
                [self.odelegate ovatarIconWasUpdatedSucsessfully:[output objectForKey:@"output"]];
                
            }
            
            if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR IMAGE UPLOAD SUCSESS: %@\n\n" ,[output objectForKey:@"output"]);
            
        }
        else {
            NSError *error = [NSError errorWithDomain:[output objectForKey:@"status"] code:[[output objectForKey:@"error_code"] intValue] userInfo:nil];
            if ([self.odelegate respondsToSelector:@selector(ovatarIconUploadFailedWithErrors:)]) {
                [self.odelegate ovatarIconUploadFailedWithErrors:error];
                
            }
            
            if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR IMAGE UPLOAD FAILED: %d %@\n\n" ,(int)error.code ,error.domain);
            
        }

    }];
    
}

-(NSString *)ovatarEmail {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_email"];
    
}

-(NSString *)ovatarPhoneNumber {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_phone"];

}

-(NSString *)ovatarKey {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_key"];

}

-(NSDictionary *)ovatarAppInformation {
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    NSDate *queried = [data objectForKey:@"ovatar_app_queried"];
    if ([[NSDate dateWithTimeIntervalSinceNow:60*60*24] compare:queried] == NSOrderedAscending || queried == nil) return nil;
    else if (queried == nil) return nil;
    else return [data objectForKey:@"ovatar_app"];
    
}

-(void)setKey:(NSString *)key {
    if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_EMAIL] evaluateWithObject:key] && ![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_PHONE] evaluateWithObject:key]) {
        [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"ovatar_key"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR KEY SAVED: %@" ,key);
        
    }
    else if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR KEY INVALID");

}

-(void)setName:(NSString *)name {
    if ([[name componentsSeparatedByString:@" "] count] > 1) {
        [[NSUserDefaults standardUserDefaults] setObject:name.capitalizedString forKey:@"ovatar_name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR NAME SAVED: %@" ,name);
        
    }
    else if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR NAME INVALID");
    
}

-(void)setEmail:(NSString *)email {
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_EMAIL] evaluateWithObject:email]) {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"ovatar_email"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR EMAIL SAVED: %@" ,email);
        
    }
    else if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR EMAIL INVALID");
    
}

-(void)setPhoneNumber:(NSString *)phone {
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_PHONE] evaluateWithObject:phone]) {        
        [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"ovatar_phone"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR PHONE NUMBER SAVED: %@" ,phone);

    }
    else if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR PHONE NUMBER INVALID");

}

-(void)setDebugging:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:@"ovatar_debugging"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.ovatarAppInformation != nil) {
        NSLog(@"\n\nOVATAR APP INFORMATION");
        for (NSString *key in self.ovatarAppInformation) {
            NSLog(@"\n%@: %@" ,[key uppercaseString] ,[self.ovatarAppInformation objectForKey:key]);

        }
        
    }

    NSLog(@"\n\nOVATAR DEBUGGING %@" ,enabled?@"ENABLED":@"DISABLED");
    
}

-(void)setPrivateArchive:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:@"ovatar_private_archive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"\n\nOVATAR PRIVATE ARCHIVE %@" ,enabled?@"ENABLED":@"DISABLED");

}

-(void)setGravatarFallback:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:@"ovatar_gravatar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"\n\nOVATAR GRAVATAR FALLBACK %@" ,enabled?@"ENABLED":@"DISABLED");

}

-(void)setCacheExpirySeconds:(int)seconds {
    if (seconds > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@(seconds) forKey:@"ovatar_expiry"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"\n\nOVATAR CACHE EXPIRY CHANGED TO %d" ,seconds);
        
    }
    
}

-(NSInteger)variable:(NSString *)key {
    NSUserDefaults *stored = [NSUserDefaults standardUserDefaults];
    NSString *keyformatted = [NSString stringWithFormat:@"ovatar_%@" ,key];
    if ([key isEqualToString:@"expiry"]) {
        if (![stored.dictionaryRepresentation.allKeys containsObject:keyformatted]) return 60*30;
        else return [[stored objectForKey:keyformatted] intValue];
    
    }
    else if ([key isEqualToString:@"debugging"]) {
        if (![stored.dictionaryRepresentation.allKeys containsObject:keyformatted]) return false;
        else return [[stored objectForKey:keyformatted] boolValue];
        
    }
    else if ([key isEqualToString:@"private_archive"]) {
        if (![stored.dictionaryRepresentation.allKeys containsObject:keyformatted]) return false;
        else return [[stored objectForKey:keyformatted] boolValue];
        
    }
    else return 0;
    
}

-(void)imageCacheDestroy {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    for (NSString *key in cache.dictionaryRepresentation.allKeys) {
        if ([key containsString:@"ovatar"]) {
            [cache removeObjectForKey:key];
            [cache synchronize];
            
        }
        
    }
    
    if ([self variable:@"debugging"]) NSLog(@"\n\nOVATAR IMAGE CACHE DESTROYED");
    
}

-(void)imageSaveToCache:(UIImage *)image identifyer:(NSString *)identifyer {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    if (image != nil) {
        if ([identifyer length] > 2 && ![identifyer isEqual:[NSNull null]]) {
            [cache setObject:UIImagePNGRepresentation(image) forKey:[NSString stringWithFormat:@"ovatar_data_%@_size%d" ,identifyer, (int)self.size]];
            [cache setObject:[NSDate dateWithTimeIntervalSinceNow:(int)[self variable:@"expiry"]] forKey:[NSString stringWithFormat:@"ovatar_expiry_%@_size%d" ,identifyer ,(int)self.size]];
        }
        
    }
    else {
        if ([identifyer length] > 2 && ![identifyer isEqual:[NSNull null]]) {
            [cache removeObjectForKey:[NSString stringWithFormat:@"ovatar_data_%@_size%d" ,identifyer ,(int)self.size]];
            [cache removeObjectForKey:[NSString stringWithFormat:@"ovatar_expiry_%@_size%d" ,identifyer ,(int)self.size]];
            
        }
        
    }
    
    [cache synchronize];
    
}

-(UIImage *)imageFromCache:(NSString *)identifyer expired:(BOOL)show {
    if ([identifyer length] > 2 && ![identifyer isEqual:[NSNull null]]) {
        NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
        NSDate *expiry = [cache objectForKey:[NSString stringWithFormat:@"ovatar_expiry_%@_size%d" ,identifyer ,(int)self.size]];
        NSData *output = [cache objectForKey:[NSString stringWithFormat:@"ovatar_data_%@_size%d" ,identifyer ,(int)self.size]];
        
        if ([[NSDate date] compare:expiry] == NSOrderedDescending || expiry == nil) {
            if (show) return [UIImage imageWithData:output];
            else return nil;
            
        }
        else if ([cache objectForKey:[NSString stringWithFormat:@"ovatar_data_%@_size%d" ,identifyer  ,(int)self.size]] == nil) return nil;
        else return [UIImage imageWithData:output];
        
    }
    return nil;
    
}

-(int)imageDetectFace:(UIImage *)image {
    NSDictionary *options = @{CIDetectorImageOrientation:[NSNumber numberWithInt:(int)[self imageOrentation:image]]};
    CIImage *cimage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:cimage options:options];
    
    return features.count > 0;
    
}

-(NSInteger)imageOrentation:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return 1;
    else if (image.imageOrientation == UIImageOrientationDown) return 3;
    else if (image.imageOrientation == UIImageOrientationLeft) return 8;
    else if (image.imageOrientation == UIImageOrientationRight) return 6;
    else if (image.imageOrientation == UIImageOrientationUpMirrored) return 2;
    else if (image.imageOrientation == UIImageOrientationDownMirrored) return 4;
    else if (image.imageOrientation == UIImageOrientationLeftMirrored) return 5;
    else return 7;

}

-(BOOL)contactsAuthorized {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        return true;
        
    }
    else return false;
    
}

-(NSArray *)contactRequestKeys {
    return @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
             CNContactEmailAddressesKey,
             CNContactPhoneNumbersKey,
             CNContactThumbnailImageDataKey,
             CNContactOrganizationNameKey,
             CNContactBirthdayKey];
    
}

-(void)contactFromQuery:(NSString *)query completion:(void (^)(NSDictionary *user))completion {
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
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@ || phone == %@" ,query, query];
        NSDictionary *output = [[contacts filteredArrayUsingPredicate:predicate] lastObject];
        
        completion(output);
        
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

@end
