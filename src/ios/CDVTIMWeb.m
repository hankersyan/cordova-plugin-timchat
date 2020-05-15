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

@end

@implementation CDVTIMWeb

- (void)viewDidLoad {
    SwizzleClassMethod([CDVUserAgentUtil class], @selector(acquireLock:), @selector(acquireLockDummy:));
    
    [super viewDidLoad];

    SwizzleClassMethod([CDVUserAgentUtil class], @selector(acquireLock:), @selector(acquireLockDummy:));
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

@end
