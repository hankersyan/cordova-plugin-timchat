//
//  CDVTIMChat.m
//  TIM01
//
//  Created by hankers on 2019/11/4.
//

#import <Cordova/CDV.h>
#import "CDVTIMChat.h"
#import <objc/runtime.h>
#import <timc/TIMChatDelegate.h>
#import "AppDelegate.h"
#import "CDVTIMWeb.h"

#ifdef QNRTCHeader_h
#import "QRDRTCViewController.h"
#endif

@interface CDVTIMChat(ChatDelegate)
@end

@implementation CDVTIMChat

long SDKAPPID = 0;
long BUSIID = 0;
NSString* pushNotificationForAndroid = @"";
NSString* pushNotificationForIOS = @"";
NSString* qnTokenUrl = @"";
NSString* qnAppID = @"";
NSString *roomnameUrl = @"";

- (void)pluginInitialize {
    // Key
    NSDictionary* dic = [self.commandDelegate settings];
    SDKAPPID = [[dic objectForKey:@"sdkappid"] integerValue];
    BUSIID = [[dic objectForKey:@"ios_busiid"] integerValue];
}

- (void)initTIM:(CDVInvokedUrlCommand *)command {

    NSDictionary *params = [command argumentAtIndex:0];
    
    NSString *userId = params[@"userId"];
    NSString *userSig = params[@"userSig"];

    NSData *deviceToken = [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceToken];
    if (deviceToken == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"deviceToken is nil" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    [[TIMChatDelegate sharedDelegate] setChatDelegate:self];
    
    if ([[params allKeys] containsObject:@"chatMoreMenus"]) {
    		[[TIMChatDelegate sharedDelegate] configChatMoreMenus:params[@"chatMoreMenus"]];
    }
    
    if ([[params allKeys] containsObject:@"groupProfileUrl"]) {
            [[TIMChatDelegate sharedDelegate] setGroupProfileUrl:params[@"groupProfileUrl"]];
    }
    
    if ([[params allKeys] containsObject:@"userProfileUrl"]) {
            [[TIMChatDelegate sharedDelegate] setUserProfileUrl:params[@"userProfileUrl"]];
    }
    
    if ([[params allKeys] containsObject:@"roomnameUrl"]) {
            roomnameUrl = params[@"roomnameUrl"];
    }

    if ([[params allKeys] containsObject:@"pushNotificationForAndroid"]) {
            pushNotificationForAndroid = params[@"pushNotificationForAndroid"];
    }
    
    if ([[params allKeys] containsObject:@"pushNotificationForIOS"]) {
            pushNotificationForIOS = params[@"pushNotificationForIOS"];
    }

    if ([[params allKeys] containsObject:@"qnTokenUrl"]) {
            qnTokenUrl = params[@"qnTokenUrl"];
    }
    
    if ([[params allKeys] containsObject:@"qnAppID"]) {
            qnAppID = params[@"qnAppID"];
    }

    NSString* loginUser = [[TIMChatDelegate sharedDelegate] getLoginUser];
    if ([loginUser isEqualToString:userId]) {
        [[TIMChatDelegate sharedDelegate] autoLogin:loginUser completion:^(int code, NSString * _Nonnull msg) {
            NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        [[TIMChatDelegate sharedDelegate] initTIM:SDKAPPID userId:userId userSig:userSig busiId:BUSIID deviceToken:deviceToken completion:^(int code, NSString * _Nonnull msg) {
            NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

- (void)chatWithUserId:(CDVInvokedUrlCommand *)command {

    NSDictionary *params = [command argumentAtIndex:0];
    
    NSString *userId = params[@"userId"];//@"hankers.yan"
    //NSString *nickname = params[@"nickname"];
    NSString *remark = params[@"remark"];
    NSString *avatar = params[@"avatar"];

    [[TIMChatDelegate sharedDelegate] chatWithUserId:userId remark:remark avatar:avatar];

    NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)chatWithGroupId:(CDVInvokedUrlCommand *)command {

    NSDictionary *params = [command argumentAtIndex:0];
    
    NSString *groupId = params[@"groupId"];//@"@TLS#144115197359891626"

    [[TIMChatDelegate sharedDelegate] chatWithGroupId:groupId];

    NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendCustomMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command argumentAtIndex:0];
    
    NSString *conversationId = params[@"conversation"];
    NSString *msg = params[@"message"];
    int type = [params[@"type"] integerValue];
    NSString *pushNotificationForAndroid = params[@"pushNotificationForAndroid"];
    NSString *pushNotificationForIOS = params[@"pushNotificationForIOS"];

    [[TIMChatDelegate sharedDelegate] sendCustomMessage:conversationId message:msg type:type 
    		pushNotificationForAndroid:pushNotificationForAndroid 
    			pushNotificationForIOS:pushNotificationForIOS];

    NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendTextMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command argumentAtIndex:0];
    
    NSString *conversationId = params[@"conversation"];
    NSString *msg = params[@"message"];

    [[TIMChatDelegate sharedDelegate] sendTextMessage:conversationId message:msg];

    NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)confirm:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command argumentAtIndex:0];
    
    NSString *desc = params[@"description"];
    
    __weak CDVTIMChat* that = self;

    [[TIMChatDelegate sharedDelegate] confirm:desc okCallback:^{
        NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];

        [that.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getLoginUser:(CDVInvokedUrlCommand *)command {
    __weak CDVTIMChat* that = self;

    NSString *userId = [[TIMChatDelegate sharedDelegate] getLoginUser];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:userId];

    [that.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)autoLogin:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command argumentAtIndex:0];
    
    NSString *userId = params[@"userId"];
    
    __weak CDVTIMChat* that = self;

    [[TIMChatDelegate sharedDelegate] autoLogin:userId completion:^(int code, NSString * _Nonnull msg) {
        NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];
        [resultDic setObject:[NSString stringWithFormat:@"%d", code] forKey:@"code"];
        if (msg)
            [resultDic setObject:msg forKey:@"msg"];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        
        [that.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getConversations:(CDVInvokedUrlCommand *)command {
    NSArray* convs = [[TIMChatDelegate sharedDelegate] getConversationSummaries];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:convs];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)dismiss:(CDVInvokedUrlCommand *)command {
	UIViewController *topVC = [self topMostController];
	if ([topVC isKindOfClass:[UINavigationController class]]) {
		[topVC dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)alert:(CDVInvokedUrlCommand *)command {
    NSString* msg = [command argumentAtIndex:0];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)showToast:(CDVInvokedUrlCommand *)command {
    NSString* msg = [command argumentAtIndex:0];
    [TIMChatDelegate showToast:msg];
}

-(void)didChatClosed:(NSString*)convId
{
    NSLog(@"CDVTIMChat::didChatClosed, %@", convId);
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"didChatClosed('%@')", convId]];
}

- (void)didChatMoreMenuClicked:(NSString*)menuTitle params:(NSDictionary*)params {
    NSLog(@"CDVTIMChat::didChatMoreMenuClicked %@, %@", menuTitle, params);

#ifdef QNRTCHeader_h
    if ([menuTitle isEqualToString:@"会议"]) {
        NSString* convId = [params objectForKey:@"conversation"];
        [self videoCall:convId];
    }
#endif
}

- (void)didCustomMessageSelected:(NSDictionary*)params {
    NSLog(@"CDVTIMChat::didCustomMessageSelected %@", params);

#ifdef QNRTCHeader_h
    long type = [[params objectForKey:@"type"] intValue];
    if (type == 1) {
        NSString *convId = [params objectForKey:@"conversation"];
        NSString *userId = [[TIMChatDelegate sharedDelegate] getLoginUser];
        [self startQNRtc:convId userId:userId];
    }
#endif
}

- (void)receivingNewCustomMessage:(NSDictionary*)params {
    NSLog(@"CDVTIMChat::receivingNewCustomMessage %@", params);

#ifdef QNRTCHeader_h
    NSString *desc = [params objectForKey:@"text"];
    __weak CDVTIMChat* that = self;
    [[TIMChatDelegate sharedDelegate] confirm:desc okCallback:^{
        NSString *convId = [params objectForKey:@"conversation"];
        NSString *userId = [[TIMChatDelegate sharedDelegate] getLoginUser];
        [that startQNRtc:convId userId:userId];
    }];
#endif

}

-(void)didLogout
{
    NSLog(@"CDVTIMChat::didLogout");
    [self.commandDelegate evalJs:@"didLogout()"];
}

- (void)willOpenGroupProfile:(NSString*)groupId
{
    NSString* prefix = [[TIMChatDelegate sharedDelegate] groupProfileUrl];
    NSString* question = [prefix containsString:@"?"] ? @"" : @"?";
    
    CDVTIMWeb* webvc = [CDVTIMWeb new];
    webvc.startPage = [NSString stringWithFormat:@"%@%@&id=%@", prefix, question, [groupId  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@", webvc.startPage);
    
    [self presentVC:webvc animated:YES completion:nil];
}

- (void)willOpenUserProfile:(NSString*)userId
{
    NSString* prefix = [[TIMChatDelegate sharedDelegate] userProfileUrl];
    NSString* question = [prefix containsString:@"?"] ? @"" : @"?";
    
    CDVTIMWeb* webvc = [CDVTIMWeb new];
    webvc.startPage = [NSString stringWithFormat:@"%@%@&id=%@", prefix, question, [userId  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@", webvc.startPage);

    [self presentVC:webvc animated:YES completion:nil];
}

- (void)evalJs:(NSString*)functionName params:(NSDictionary*)params {
    NSError *error;
    NSString *jsonString = @"";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    }
    NSString *jsStr = [NSString stringWithFormat:@"%@('%@')", functionName, jsonString];
    [self.commandDelegate evalJs:jsStr];
}

#ifdef QNRTCHeader_h

- (void) startQNRtc:(NSString*)conversationId userId:(NSString*)userId {
    [TIMChatDelegate showToast:@"正在连接..."];
    if ([roomnameUrl length] > 0) {
        NSString *url = [roomnameUrl stringByReplacingOccurrencesOfString:@"<GROUP_ID>" withString:[conversationId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        
        __weak CDVTIMChat* that = self;

        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *roomName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"roomName = %@", roomName);
            [that startQiniuRtc:roomName userId:userId];
        }] resume];
    } else {
        NSString *roomName = [[[[[conversationId stringByReplacingOccurrencesOfString:@"@" withString:@""] stringByReplacingOccurrencesOfString:@"#" withString:@""] stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"%" withString:@""] stringByReplacingOccurrencesOfString:@"&" withString:@""];
        [self startQiniuRtc:roomName userId:userId];
    }
}

- (void)startQiniuRtc:(NSString*)roomName userId:(NSString*) userId {
    NSString *url = [[qnTokenUrl stringByReplacingOccurrencesOfString:@"<ROOM>" withString:roomName] stringByReplacingOccurrencesOfString:@"<USER>" withString:userId];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    __weak CDVTIMChat* that = self;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"responseToken = %@", responseToken);
        [that openConferenceRoom:roomName userId:userId token:responseToken];
    }] resume];
}

- (void) openConferenceRoom:(NSString*)roomName userId:(NSString*)userId token:(NSString*)token {
    [self.commandDelegate runInBackground:^{
        NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:QN_SET_CONFIG_KEY];
        if (!configDic) {
            configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@20};
//            configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(720, 1280)), @"FrameRate":@20};
        }

        QRDRTCViewController *rtcVC = [[QRDRTCViewController alloc] init];
        rtcVC.roomName = roomName;
        rtcVC.userId = userId;
        rtcVC.roomToken = token;
        rtcVC.appId = qnAppID;
        rtcVC.configDic = configDic;
//        rtcVC.videoEnabled = YES;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentVC:rtcVC animated:YES completion:nil];
        }];
    }];
}

- (void) videoCall:(NSString*)conversationId {
    NSString *msg = @"加入视频会议";
    int type = 1;
    
    [[TIMChatDelegate sharedDelegate] sendCustomMessage:conversationId message:msg type:type
            pushNotificationForAndroid:pushNotificationForAndroid
                pushNotificationForIOS:pushNotificationForIOS];

    NSString *userId = [[TIMChatDelegate sharedDelegate] getLoginUser];
    
    [self startQNRtc:conversationId userId:userId];
}

#endif

- (void)presentVC:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIViewController* topVC = [self topMostController];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc];
    nav2.navigationBarHidden = YES;
    nav2.modalPresentationStyle = UIModalPresentationFullScreen;
    [topVC presentViewController:nav2 animated:YES completion:nil];
}

- (UIViewController*)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}

@end
