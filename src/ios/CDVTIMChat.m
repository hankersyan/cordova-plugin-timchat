//
//  CDVBaiduOcr.m
//  myTestCordova
//
//  Created by mac on 2018/6/4.
//

#import <Cordova/CDV.h>
#import "CDVTIMChat.h"
#import <objc/runtime.h>
#import <timc/TIMChatDelegate.h>
#import "AppDelegate.h"

@implementation CDVTIMChat

- (void)initTIM:(CDVInvokedUrlCommand *)command {

    NSDictionary *params = [command argumentAtIndex:0];
    
    int sdkAppId = [params[@"sdkAppId"] integerValue];
    int busiId = [params[@"busiId"] integerValue];
    NSString *userId = params[@"userId"];
    NSString *userSig = params[@"userSig"];
    NSData *deviceToken = [(AppDelegate*)[[UIApplication sharedApplication] delegate] deviceToken];
    
    [[TIMChatDelegate sharedDelegate] initTIM:sdkAppId userId:userId userSig:userSig busiId:busiId deviceToken:deviceToken completion:^(int code, NSString * _Nonnull msg) {
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

@end
