//
//  CDVTIMWeb.m
//  TIM01
//
//  Created by apple on 2020/5/7.
//

#import "CDVTIMWeb.h"
#import <Cordova/CDVUserAgentUtil.h>
#import <objc/runtime.h>
#import <Webkit/Webkit.h>
#import "WebViewJavascriptBridge.h"
#import <timc/TIMChatDelegate.h>

@interface CDVUserAgentUtil (Swizzle)
+ (void)acquireLockDummy:(void (^)(NSInteger lockToken))block;
@end

@implementation CDVUserAgentUtil (Swizzle)

+ (void)acquireLockDummy:(void (^)(NSInteger lockToken))block
{
    NSLog(@"acquireLockDuuuuuuuuummy");
    block(0);
}

@end

@interface CDVTIMWeb ()
@property WebViewJavascriptBridge* bridge;
@end

@implementation CDVTIMWeb

- (void)viewDidLoad {
    SwizzleClassMethod([CDVUserAgentUtil class], @selector(acquireLock:), @selector(acquireLockDummy:));
    
    [super viewDidLoad];

    SwizzleClassMethod([CDVUserAgentUtil class], @selector(acquireLock:), @selector(acquireLockDummy:));
    
    // Do any additional setup after loading the view from its nib.
    [self registerNativeMethods];
    [self loadJSMethods];
}

//---------------------------------------------------------
// To avoid the deadlock caused by CDVUserAgentUtil::acquireLock
// using CDVViewController duplicately, we swizzle it via dummy
// https://ikalaica.com/overriding-methods-in-objective-c/
//---------------------------------------------------------
void SwizzleClassMethod(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);

    c = object_getClass((id)c);

    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

-(void)registerNativeMethods {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge registerHandler:@"__nativeAlert" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"nativeAlert: %@", data);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSDictionary* dic = (NSDictionary*)data;
            NSString* msg = [dic objectForKey:@"msg"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
        responseCallback(data);
    }];
    [self.bridge registerHandler:@"__nativeShowToast" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"nativeShowToast: %@", data);
        NSDictionary* dic = (NSDictionary*)data;
        NSString* msg = [dic objectForKey:@"msg"];
        [TIMChatDelegate showToast:msg];
        responseCallback(data);
    }];
    [self.bridge registerHandler:@"__nativeBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"nativeBack: %@", data);
        responseCallback(data);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)loadJSMethods {
    
    NSString* strJS = @"console.log('loadNativeMethods::1');"
    "    var __nativeAlert;"
    "    var __nativeShowToast;"
    "    var __nativeBack;"
    "    function jsbridgingAlert(msg) {"
    "        if (typeof Android != \"undefined\") {"
    "            Android.alert(msg);"
    "        } else {"
    "            __nativeAlert(msg);"
    "        }"
    "    }"
    "    console.log('loadNativeMethods::2');"
    "    function jsbridgingShowToast(msg) {"
    "        if (typeof Android != \"undefined\") {"
    "            Android.showToast(msg);"
    "        } else {"
    "            __nativeShowToast(msg);"
    "        }"
    "    }"
    "    console.log('loadNativeMethods::3');"
    "    function jsbridgingBack() {"
    "        if (typeof Android != \"undefined\") {"
    "            Android.back();"
    "        } else {"
    "            __nativeBack();"
    "        }"
    "    }"
    "    console.log('loadNativeMethods::4');"
    "    function setupWebViewJavascriptBridge(callback) {"
    "        if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }"
    "        if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }"
    "        window.WVJBCallbacks = [callback];"
    "        var WVJBIframe = document.createElement('iframe');"
    "        WVJBIframe.style.display = 'none';"
    "        WVJBIframe.src = 'https://__bridge_loaded__';"
    "        document.documentElement.appendChild(WVJBIframe);"
    "        setTimeout(function () { document.documentElement.removeChild(WVJBIframe) }, 0)"
    "    }"
    "    console.log('loadNativeMethods::5');"
    "    setupWebViewJavascriptBridge(function (bridge) {"
    "        /* Initialize your app here */"
    "        __nativeAlert = function (msg) {"
    "            bridge.callHandler('__nativeAlert', { 'msg': msg }, function responseCallback(responseData) {"
    "                console.log(\"JS __nativeAlert received response:\", responseData)"
    "            })"
    "        };"
    "        __nativeShowToast = function (msg) {"
    "            bridge.callHandler('__nativeShowToast', { 'msg': msg }, function responseCallback(responseData) {"
    "                console.log(\"JS __nativeShowToast received response:\", responseData)"
    "            })"
    "        };"
    "        __nativeBack = function (msg) {"
    "            bridge.callHandler('__nativeBack', {}, function responseCallback(responseData) {"
    "                console.log(\"JS __nativeBack received response:\", responseData)"
    "            })"
    "        };"
    "    });"
    "    console.log('loadNativeMethods::END');";

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Do some work");
        [self.webViewEngine evaluateJavaScript:strJS completionHandler:nil];
    });
}

@end
