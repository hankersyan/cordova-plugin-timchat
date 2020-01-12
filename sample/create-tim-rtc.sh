cordova create tim_rtc io.hankers.tim01 TIM01
cd tim_rtc
cordova platform add ios android
cordova plugin add cordova-plugin-device
cordova plugin add cordova-plugin-wkwebview-engine
cordova plugin add cordova-plugin-timchat --searchpath ../.. --variable SDKAPPID=1400145941 --variable IOS_BUSIID=16144 --variable XMPUSH_BUSIID=7685 --variable XMPUSH_APPID=2882303761518228064 --variable XMPUSH_APPKEY=5531822835064 --variable HWPUSH_BUSIID=8594 --variable HWPUSH_APPID=101330759
cordova plugin add cordova-plugin-rtc-qiniu --variable APPID=dmqotunph --searchpath ../../../../cordova/plugins
cp -r ../www .
cp ../config.xml .
cp ../AppDelegate.* ./platforms/ios/TIM01/Classes
cordova prepare
