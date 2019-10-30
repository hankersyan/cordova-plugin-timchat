//
//  CDVBaiduOcr.h
//  myTestCordova
//
//  Created by mac on 2018/6/4.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface CDVTIMChat : CDVPlugin

- (void)initTIM:(CDVInvokedUrlCommand *)command;
- (void)chatWithUserId:(CDVInvokedUrlCommand *)command;
- (void)chatWithGroupId:(CDVInvokedUrlCommand *)command;

@end
