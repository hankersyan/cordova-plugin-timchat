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

@interface CDVTIMChat(ChatDelegate)
@end

@implementation CDVTIMChat

long SDKAPPID = 0;
long BUSIID = 0;

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
    
    [[TIMChatDelegate sharedDelegate] initTIM:SDKAPPID userId:userId userSig:userSig busiId:BUSIID deviceToken:deviceToken completion:^(int code, NSString * _Nonnull msg) {
        NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
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

-(void)didChatClosed:(NSString*)convId
{
    NSLog(@"CDVTIMChat::didChatClosed, %@", convId);
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"didChatClosed('%@')", convId]];
}

- (void)didChatMoreMenuClicked:(NSString*)menuTitle params:(NSDictionary*)params {
    NSLog(@"CDVTIMChat::didChatMoreMenuClicked %@, %@", menuTitle, params);
    NSError *error;
    NSString *jsonString = @"";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    }
    NSString *jsStr = [NSString stringWithFormat:@"didChatMoreMenuClicked('%@', '%@')", menuTitle, jsonString];
    [self.commandDelegate evalJs:jsStr];
}

@end
