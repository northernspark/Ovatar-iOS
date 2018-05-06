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

#define OVATAR_HOST @"https://ovatar.io/api/"
#define OVATAR_REGEX_PHONE @"(\\+)[0-9\\+\\-]{6,19}"
#define OVATAR_REGEX_EMAIL @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

+(void)sharedInstanceWithAppKey:(NSString *)appKey {
    token = appKey;
    
}

+(OOvatar *)sharedInstance {
    if (![token containsString:@"app"]) {
        NSLog(@"OVATAR ERROR: App key required. If you do not have an app key please signup to Ovatar at https://ovatar.io\n\n");
        return nil;
        
    }
    else {
        OOvatar *ovatar = [[OOvatar alloc] init];
        ovatar.gravatar = true;
        ovatar.debug = false;

        return ovatar;
        
    }
    
}

-(void)returnOvatarIconWithKey:(NSString *)key completion:(void (^)(NSError *error, id output))completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:key forKey:@"id"];
    
    [self requestOvatarImageWithParameters:params completion:^(NSError *error, id output) {
        completion(error, output);

    }];
    
}

-(void)returnOvatarIconWithQuery:(NSString *)query completion:(void (^)(NSError *error, id output))completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:query forKey:@"query"];
    
    [self requestOvatarImageWithParameters:params completion:^(NSError *error, id output) {
        completion(error, output);
        
    }];
    
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
    
    if (self.debug) NSLog(@"\n\nOVATAR LOADING: ✍️ GET: %@\n\n", buildendpoint);
    
    [task resume];
    
}

-(void)uploadOvatar:(NSData *)image user:(NSString *)user  {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.qualityOfService = self.backgroundupload?NSQualityOfServiceBackground:NSQualityOfServiceUtility;
    
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

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:queue];
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
            if ([self.odelegate respondsToSelector:@selector(ovatarIconWasUpdatedSucsessfully:)]) {
                [self.odelegate ovatarIconWasUpdatedSucsessfully:[output objectForKey:@"output"]];
                
            }
            
            [self setKey:[output objectForKey:@"key"]];
            
            if ([[output objectForKey:@"type"] isEqualToString:@"type"]) [self setEmail:[output objectForKey:@"user"]];
            else [self setPhoneNumber:[output objectForKey:@"user"]];
            
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
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"ovatar_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.debug) NSLog(@"\n\nOVATAR KEY SAVED: %@" ,key);

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

@end
