cordova create tim01 io.hankers.tim01 TIM01
cd tim01
cordova platform add ios
cordova plugin add cordova-plugin-device
cordova plugin add cordova-plugin-timchat --searchpath ../..
cp -r ../www .
cp ../config.xml .
cp ../AppDelegate.* ./platforms/ios/TIM01/Classes
#cp -r ../*.bundle ./platforms/ios/TIM01/Resources
cp -r ../*.bundle .
cordova prepare
cp -r ../*.bundle ./platforms/ios/TIM01/
