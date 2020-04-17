//
//  AppDelegate+TIMChat.h
//  TIMChat
//
//  Created by hankers on 2018/12/7.
//  Copyright © 2018年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define Key_UserInfo_Appid @"Key_UserInfo_Appid"
#define Key_UserInfo_User  @"Key_UserInfo_User"
#define Key_UserInfo_Pwd   @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig   @"Key_UserInfo_Sig"

#define sdkBusiId         12742
#define BUGLY_APP_ID      @"e965e5d928"

@protocol ChatDelegate<NSObject>
- (void)didChatClosed:(NSString*)convId;
- (void)didChatMoreMenuClicked:(NSString*)menuTitle params:(NSDictionary*)params;
- (void)didCustomMessageSelected:(NSDictionary*)params;
- (void)receivingNewCustomMessage:(NSDictionary*)params;
- (void)didLogout;
@end

@interface TIMChatDelegate : NSObject
{
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSData *deviceToken;
- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;

@property (nonatomic, strong) NSString *integratedLoginParam;
@property (nonatomic, strong) NSString *groupProfileUrl;
@property (nonatomic, strong) NSString *userProfileUrl;

+ (instancetype)sharedDelegate;

- (void)initTIM:(int)appId userId:(NSString*)userId userSig:(NSString*)userSig busiId:(int)busiId deviceToken:(NSData*)deviceToken completion:(void(^)(int code, NSString* msg))completion;
//- (void)didEnterBackground;
//- (void)didBecomeActive;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (BOOL)handleOpenURL:(NSURL *)url;
- (NSString*)getLoginUser;
- (void)autoLogin:(NSString*)userId completion:(void(^)(int code, NSString* msg))completion;
- (NSArray*)getConversationSummaries;

//进入登录界面
//- (void)enterLoginUI;

// 进入主界面逻辑
- (void)enterMainUI;

- (NSString *)generateUserSigForTest:(NSString *)identifier secretKey:(NSString*)secretKey sdkAppId:(int)sdkAppId;

// 代码中尽量改用以下方式去push/pop/present界面
//- (UINavigationController *)navigationViewController;

//- (UIViewController *)topViewController;

//- (void)pushViewController:(UIViewController *)viewController;

//- (NSArray *)popToViewController:(UIViewController *)viewController;

//- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)title;
//- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)title backAction:(CommonVoidBlock)action;

//- (UIViewController *)popViewController;

//- (NSArray *)popToRootViewController;

- (void)presentVC:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissVC:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;

//- (void)pushToChatViewControllerWith:(IMAUser *)user;
//- (void)pushToChatViewControllerWith:(id)user;
- (void)chatWithUserId:(NSString*)userId remark:(NSString*)remark avatar:(NSString*)avatar;
- (void)chatWithGroupId:(NSString*)groupId;
- (void)setChatDelegate:(id)chatDelegate;
- (void)configChatMoreMenus:(NSDictionary*)title2IconDics;
- (void)sendCustomMessage:(NSString*)conversationId message:(NSString*)msg type:(int)type pushNotificationForAndroid:(NSString*)pushNotificationForAndroid pushNotificationForIOS:(NSString*)pushNotificationForIOS;
- (void)sendTextMessage:(NSString*)conversationId message:(NSString*)msg;
- (void)confirm:(NSString*)description okCallback:(void (^)(void))okCallback;

@end

NS_ASSUME_NONNULL_END
