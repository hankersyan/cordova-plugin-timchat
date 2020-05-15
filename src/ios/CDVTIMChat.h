//
//  CDVTIMChat.m
//  TIM01
//
//  Created by hankers on 2019/11/4.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface CDVTIMChat : CDVPlugin

- (void)initTIM:(CDVInvokedUrlCommand *)command;
- (void)chatWithUserId:(CDVInvokedUrlCommand *)command;
- (void)chatWithGroupId:(CDVInvokedUrlCommand *)command;
- (void)sendCustomMessage:(CDVInvokedUrlCommand *)command;
- (void)sendTextMessage:(CDVInvokedUrlCommand *)command;
- (void)confirm:(CDVInvokedUrlCommand *)command;
- (void)getLoginUser:(CDVInvokedUrlCommand *)command;
- (void)autoLogin:(CDVInvokedUrlCommand *)command;
- (void)getConversations:(CDVInvokedUrlCommand *)command;
- (void)dismiss:(CDVInvokedUrlCommand *)command;
- (void)alert:(CDVInvokedUrlCommand *)command;
- (void)showToast:(CDVInvokedUrlCommand *)command;

@end
