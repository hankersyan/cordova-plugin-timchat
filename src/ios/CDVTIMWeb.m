//
//  CDVTIMWeb.m
//  TIM01
//
//  Created by apple on 2020/5/7.
//

#import "CDVTIMWeb.h"
#import <Cordova/CDVUserAgentUtil.h>
#import <objc/runtime.h>

@interface CDVTIMWeb ()

@end

@implementation CDVTIMWeb

- (void)viewDidLoad {
    
    Method originalMethod = SwizzleClassMethod([CDVUserAgentUtil class], @selector(acquireLock:), [CDVTIMWeb class], @selector(acquireLockDummy:));
    
    [super viewDidLoad];

    recoverSwizzleClassMethod([CDVUserAgentUtil class], @selector(acquireLock:), originalMethod);

    // Do any additional setup after loading the view from its nib.
}

//---------------------------------------------------------
// To avoid the deadlock caused by CDVUserAgentUtil::acquireLock
// using CDVViewController duplicately, we swizzle it via dummy
// https://ikalaica.com/overriding-methods-in-objective-c/
//---------------------------------------------------------
Method SwizzleClassMethod(Class destClass, SEL destMethodSel, Class srcClass, SEL srcMethodSel) {

    Method origMethod = class_getClassMethod(destClass, destMethodSel);
    Method newMethod = class_getClassMethod(srcClass, srcMethodSel);

    destClass = object_getClass((id)destClass);

    if(class_addMethod(destClass, destMethodSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(destClass, srcMethodSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
    
    return origMethod;
}

void recoverSwizzleClassMethod(Class destClass, SEL destMethodSel, Method origMethod) {

    Method destMethod = class_getClassMethod(destClass, destMethodSel);

    destClass = object_getClass((id)destClass);

    if(class_addMethod(destClass, destMethodSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod)))
        class_replaceMethod(destClass, destMethodSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(destMethod, origMethod);
}

+ (void)acquireLockDummy:(void (^)(NSInteger lockToken))block
{
    block(1);
}

@end
