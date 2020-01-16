//
//  QTalkAuth.m
//  STChatIphone
//
//  Created by wangyu.wang on 16/4/5.
//
//

#import "Login.h"

@implementation Login

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getLoginInfo:(RCTResponseSenderBlock)success:(RCTResponseSenderBlock)error) {
    
    NSString *getLoginInfo = @"getLoginInfo";
    NSLog(getLoginInfo);
    
    NSString *userName = [STIMKit getLastUserName];
    userName = userName.length ? userName : @"";
    NSString *qtalkToken = [[STIMKit sharedInstance] myRemotelogginKey];
    qtalkToken = qtalkToken.length ? qtalkToken : @"";
    
    NSString *key = [[STIMKit sharedInstance] thirdpartKeywithValue];
    key = key.length ? key : @"";

    NSString *httpHost = [[STIMKit sharedInstance] qimNav_HttpHost];
    httpHost = httpHost.length ? httpHost : @"";

    if ([userName.lowercaseString isEqualToString:@"appstore"] == NO) {
        NSDictionary *responseData = @{@"userid" : userName, @"q_auth" : qtalkToken, @"c_key" : key, @"checkUserKeyHost" : httpHost, @"showOA":@([[STIMKit sharedInstance] qimNav_ShowOA])};
        STIMVerboseLog(@"%@ 登录骆驼帮OA : %@", userName.lowercaseString, responseData);
        success(@[responseData]);
    }
}

RCT_EXPORT_METHOD(updateCkey:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSString *updateCkey = @"updateCkey";
    NSLog(updateCkey);
    
    NSNumber *is_ok = @NO;
    NSString *errorMsg = @"";
    
    @try {
        [[STIMKit sharedInstance] updateRemoteLoginKey];
        is_ok = @YES;
    } @catch (NSException *exception) {
        is_ok = @NO;
        errorMsg = [exception reason];
    }
    
    NSDictionary *responseData = @{@"is_ok": is_ok, @"msg": errorMsg};
    resolve(responseData);
}

@end
