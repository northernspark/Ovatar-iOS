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
        OOvatar *ovatar = [[OOvatar alloc] init];
        ovatar.gravatar = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_gravatar"] boolValue];
        ovatar.debug =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_debugging"] boolValue];
        ovatar.privatearchive =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"ovatar_private_archive"] boolValue];
        ovatar.cacheexpiry = 60*60*3;

        return ovatar;
        
    }
    
}

-(void)returnOvatarIconWithKey:(NSString *)key completion:(void (^)(NSError *error, id output))completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:key forKey:@"id"];
    
    if (key.length > 2) {
        [self requestOvatarImageWithParameters:params completion:^(NSError *error, id output) {
            completion(error, output);

        }];
        
    }
    
}

-(void)returnOvatarIconWithQuery:(NSString *)query completion:(void (^)(NSError *error, id output))completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:query forKey:@"query"];
    
    if (query.length > 2) {
        [self requestOvatarImageWithParameters:params completion:^(NSError *error, id output) {
            completion(error, output);
            
        }];
        
    }

}

-(void)requestOvatarImageWithParameters:(NSDictionary *)params completion:(void (^)(NSError *error, id output))completion {
    NSMutableString *buildendpoint = [[NSMutableString alloc] init];
    [buildendpoint appendString:OVATAR_HOST];
    [buildendpoint appendString:@"ovatar.php"];
    [buildendpoint appendString:@"?"];
    [buildendpoint appendString:[NSString stringWithFormat:@"fallback=%@&" ,self.gravatar?@"true":@"false"]];

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
                    UIImage *output = [UIImage imageWithData:data];
                    NSError *err = [NSError errorWithDomain:@"" code:(int)status.statusCode userInfo:nil];
                    
                    completion(err ,output);
                    
                }
                
            }
            else {
                NSError *err = [self requestErrorHandle:(int)status.statusCode message:error.domain error:error endpoint:buildendpoint];

                completion(err ,nil);

            }
            
        }];
            
    }];
    
    if (self.debug) NSLog(@"\n\nOVATAR LOADING: ✍️ GET: %@\n\n", buildendpoint);
    
    [task resume];
    
}

-(void)uploadOvatar:(NSData *)image user:(NSString *)user  {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.qualityOfService = NSQualityOfServiceUtility;
    
    NSMutableString *buildendpoint = [[NSMutableString alloc] init];
    [buildendpoint appendString:OVATAR_HOST];
    [buildendpoint appendString:@"upload.php"];
    
    NSMutableString *formatdata = [[NSMutableString alloc] init];
    [formatdata appendString:[image base64EncodedStringWithOptions:0]];
    
    NSMutableDictionary *endpointparams = [[NSMutableDictionary alloc] init];
    [endpointparams setValue:formatdata forKey:@"ovatar"];
    [endpointparams setValue:@(self.privatearchive) forKey:@"private"];
    [endpointparams setValue:user forKey:@"user"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:buildendpoint] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request addValue:token forHTTPHeaderField:@"oappkey"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:endpointparams options:NSJSONWritingPrettyPrinted error:nil]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionUploadTask *task = [session uploadTaskWithStreamedRequest:request];

    if (self.debug) NSLog(@"\n\nOVATAR LOADING: ✍️ POST: %@\n\n", buildendpoint);

    [task resume];
    
}

-(NSError *)requestErrorHandle:(int)code message:(NSString *)message error:(NSError *)error endpoint:(NSString *)endpoint {
    NSError *err;
    if (error) err = [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    else if (message == nil && error == nil) err = [NSError errorWithDomain:@"unknown error" code:600 userInfo:nil];
    else if (message == nil && error.localizedDescription != nil) [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    else err = [NSError errorWithDomain:message code:code userInfo:nil];
    
    if (err == nil || err.code == 200) {
        if (self.debug) NSLog(@"\n\nOVATAR SUCSESS: %d 🎉 %@\n\n" ,code ,endpoint);
        
    }
    else if (self.debug) NSLog(@"\n\nOVATAR ERROR: %d 🎉 %@\n\n" ,code ,message);
    
    return err;
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent
   totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        CGFloat progress = (float)totalBytesSent/totalBytesExpectedToSend;
        if (self.debug) NSLog(@"\n\nOVATAR IMAGE UPLOAD PROGRESS: %f%%\n\n" ,progress * 100);
        
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
            
            if ([type isEqualToString:@"email"]) [self setEmail:[output objectForKey:@"user"]];
            else [self setPhoneNumber:[output objectForKey:@"user"]];
            
            if ([self.odelegate respondsToSelector:@selector(ovatarIconWasUpdatedSucsessfully:)]) {
                [self.odelegate ovatarIconWasUpdatedSucsessfully:[output objectForKey:@"output"]];
                
            }
            
            if (self.debug) NSLog(@"\n\nOVATAR IMAGE UPLOAD SUCSESS: %@\n\n" ,[output objectForKey:@"output"]);
            
        }
        else {
            NSError *error = [NSError errorWithDomain:[output objectForKey:@"status"] code:[[output objectForKey:@"error_code"] intValue] userInfo:nil];
            if ([self.odelegate respondsToSelector:@selector(ovatarIconUploadFailedWithErrors:)]) {
                [self.odelegate ovatarIconUploadFailedWithErrors:error];
                
            }
            
            if (self.debug) NSLog(@"\n\nOVATAR IMAGE UPLOAD FAILED: %d %@\n\n" ,(int)error.code ,error.domain);
            
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

-(void)setKey:(NSString *)key {
    if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_EMAIL] evaluateWithObject:key] && ![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_PHONE] evaluateWithObject:key]) {
        [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"ovatar_key"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.debug) NSLog(@"\n\nOVATAR KEY SAVED: %@" ,key);
        
    }
    else if (self.debug) NSLog(@"\n\nOVATAR KEY INVALID");

}

-(void)setEmail:(NSString *)email {
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_EMAIL] evaluateWithObject:email]) {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"ovatar_email"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.debug) NSLog(@"\n\nOVATAR EMAIL SAVED: %@" ,email);
        
    }
    else if (self.debug) NSLog(@"\n\nOVATAR EMAIL INVALID");
    
}

-(void)setPhoneNumber:(NSString *)phone {
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", OVATAR_REGEX_PHONE] evaluateWithObject:phone]) {        
        [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"ovatar_phone"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.debug) NSLog(@"\n\nOVATAR PHONE NUMBER SAVED: %@" ,phone);

    }
    else if (self.debug) NSLog(@"\n\nOVATAR PHONE NUMBER INVALID");

}

-(void)setDebugging:(BOOL)enabled {
    self.debug = enabled;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:@"ovatar_debugging"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"\n\nOVATAR DEBUGGING %@" ,enabled?@"ENABLED":@"DISABLED");
    
}

-(void)setPrivateArchive:(BOOL)enabled {
    self.privatearchive = enabled;

    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:@"ovatar_private_archive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"\n\nOVATAR PRIVATE ARCHIVE %@" ,enabled?@"ENABLED":@"DISABLED");

}

-(void)setGravatarFallback:(BOOL)enabled {
    self.gravatar = enabled;

    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:@"ovatar_gravatar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"\n\nOVATAR GRAVATAR FALLBACK %@" ,enabled?@"ENABLED":@"DISABLED");

}

-(void)imageCacheDestroy {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    for (NSString *key in cache.dictionaryRepresentation.allKeys) {
        if ([key containsString:@"ovatar"]) {
            [cache removeObjectForKey:key];
            [cache synchronize];
            
        }
        
    }
    
}

-(void)imageSaveToCache:(UIImage *)image identifyer:(NSString *)identifyer {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    if (image != nil) {
        if ([identifyer length] > 2 && ![identifyer isEqual:[NSNull null]]) {
            [cache setObject:UIImagePNGRepresentation(image) forKey:[NSString stringWithFormat:@"ovatar_data_%@" ,identifyer]];
            [cache setObject:[NSDate dateWithTimeIntervalSinceNow:self.cacheexpiry] forKey:[NSString stringWithFormat:@"ovatar_expiry_%@" ,identifyer]];
            
        }
        
    }
    else {
        if ([identifyer length] > 2 && ![identifyer isEqual:[NSNull null]]) {
            [cache removeObjectForKey:[NSString stringWithFormat:@"ovatar_data_%@" ,identifyer]];
            [cache removeObjectForKey:[NSString stringWithFormat:@"ovatar_expiry_%@" ,identifyer]];
            
        }
        
    }
    
    [cache synchronize];
    
}

-(UIImage *)imageFromCache:(NSString *)identifyer {
    if ([identifyer length] > 2 && ![identifyer isEqual:[NSNull null]]) {
        NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
        NSDate *expiry = [cache objectForKey:[NSString stringWithFormat:@"ovatar_expiry_%@" ,identifyer]];
        NSData *output = [cache objectForKey:[NSString stringWithFormat:@"ovatar_data_%@" ,identifyer]];
        
        if ([[NSDate date] compare:expiry] == NSOrderedDescending || expiry == nil) return nil;
        else if ([cache objectForKey:[NSString stringWithFormat:@"ovatar_data_%@" ,identifyer]] == nil) return nil;
        else return [UIImage imageWithData:output];
        
    }
    return nil;
    
}


@end
