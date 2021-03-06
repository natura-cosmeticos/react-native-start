#!/usr/bin/env bash
# Creates an .env from ENV variables for use with react-native-config
ENV_WHITELIST=${ENV_WHITELIST:-"^RN_"}
printf "Creating an .env file with the following whitelist:\n"
printf "%s\n" $ENV_WHITELIST
set | egrep -e $ENV_WHITELIST | sed 's/^RN_//g' > .env
printf "\n.env created with contents:\n\n"
cat .env

#Config Dynatrace config file
cp $APPCENTER_SOURCE_DIRECTORY/config/dynatrace.config $APPCENTER_SOURCE_DIRECTORY/dynatrace.config

#Config Firebase Android config files
GOOGLE_CONFIG_ANDROID_FILE=$APPCENTER_SOURCE_DIRECTORY/android/app/google-services.json
if [ -e "$GOOGLE_CONFIG_ANDROID_FILE" ]
then
    echo "Updating Google Json"
    echo $GOOGLE_CONFIG_ANDROID | base64 --decode > $GOOGLE_CONFIG_ANDROID_FILE
    sed -i -e 's/\\"/'\"'/g' $GOOGLE_CONFIG_ANDROID_FILE

    echo "File content: $GOOGLE_CONFIG_ANDROID_FILE"
    cat $GOOGLE_CONFIG_ANDROID_FILE
fi

#Config Firebase iOS config files
GOOGLE_CONFIG_IOS_FILE=$APPCENTER_SOURCE_DIRECTORY/ios/GoogleService-Info.plist
if [ -e "$GOOGLE_CONFIG_IOS_FILE" ]
then
    echo "Updating Google Json"
    echo $GOOGLE_CONFIG_IOS | base64 --decode > $GOOGLE_CONFIG_IOS_FILE
    sed -i -e 's/\\"/'\"'/g' $GOOGLE_CONFIG_IOS_FILE

    echo "File content: $GOOGLE_CONFIG_IOS_FILE"
    cat $GOOGLE_CONFIG_IOS_FILE
fi

#Config Google Maps API
GOOGLE_CONFIG_IOS_FILE=$APPCENTER_SOURCE_DIRECTORY/ios/ReactNativeStart/AppDelegate.m
sed -i -e "s/__GOOGLE_MAPS_KEY__/$GOOGLE_MAPS_KEY/" $GOOGLE_CONFIG_IOS_FILE
echo '---------------- GOOGLE MAPS API - iOS'
echo "Google Maps API: File content: $GOOGLE_CONFIG_IOS_FILE"
cat $GOOGLE_CONFIG_IOS_FILE
echo '----------------'

GOOGLE_CONFIG_ANDROID_FILE=$APPCENTER_SOURCE_DIRECTORY/android/app/src/main/AndroidManifest.xml
sed -i -e "s/__GOOGLE_MAPS_KEY__/$GOOGLE_MAPS_KEY/" $GOOGLE_CONFIG_ANDROID_FILE 
echo '---------------- GOOGLE MAPS API - Android'
echo "Google Maps API: File content: $GOOGLE_CONFIG_ANDROID_FILE"
cat $GOOGLE_CONFIG_ANDROID_FILE
echo '----------------'

#Config Codepush 
CODEPUSH_IOS_FILE=$APPCENTER_SOURCE_DIRECTORY/ios/ReactNativeStart/Info.plist
sed -i -e "s/__CODEPUSH_KEY__/$CODEPUSH_KEY/" $CODEPUSH_IOS_FILE 
echo "Codepush Key: File content: $CODEPUSH_IOS_FILE"
cat $CODEPUSH_IOS_FILE
echo '----------------'

CODEPUSH_ANDROID_FILE=$APPCENTER_SOURCE_DIRECTORY/android/app/src/main/res/values/strings.xml
sed -i -e "s/__CODEPUSH_KEY__/$CODEPUSH_KEY/" $CODEPUSH_ANDROID_FILE 
echo "Codepush Key: File content: $CODEPUSH_ANDROID_FILE"
cat $CODEPUSH_ANDROID_FILE
echo '----------------'

#Config Dynatrace
DYNATRACE_IOS_FILE=$APPCENTER_SOURCE_DIRECTORY/ios/ReactNativeStart/Info.plist
sed -i '' -e "s/__DYNATRACE_APP_ID__/$DYNATRACE_APP_ID/" $DYNATRACE_IOS_FILE 
sed -i '' -e "s,__DYNATRACE_IOS_ENVIRONMENT__,$DYNATRACE_IOS_ENVIRONMENT,g" $DYNATRACE_IOS_FILE 
sed -i '' -e "s,__DYNATRACE_IOS_CLUSTER_URL__,$DYNATRACE_IOS_CLUSTER_URL,g" $DYNATRACE_IOS_FILE 
echo "DYNATRACE Key: File content: $DYNATRACE_IOS_FILE"
cat $DYNATRACE_IOS_FILE
echo '----------------'

DYNATRACE_ANDROID_FILE=$APPCENTER_SOURCE_DIRECTORY/android/app/build.gradle
sed -i '' -e "s/__DYNATRACE_APP_ID__/$DYNATRACE_APP_ID/" $DYNATRACE_ANDROID_FILE 
sed -i '' -e "s,__DYNATRACE_ANDROID_BEACON_URL__,$DYNATRACE_ANDROID_BEACON_URL,g" $DYNATRACE_ANDROID_FILE 
echo "DYNATRACE Key: File content: $DYNATRACE_ANDROID_FILE"
cat $DYNATRACE_ANDROID_FILE
echo '----------------'

DYNATRACE_PLUGIN_FILE=$APPCENTER_SOURCE_DIRECTORY/dynatrace.config
sed -i '' -e "s/__DYNATRACE_APP_ID__/$DYNATRACE_APP_ID/g" $DYNATRACE_PLUGIN_FILE 
sed -i '' -e "s,__DYNATRACE_ANDROID_BEACON_URL__,$DYNATRACE_ANDROID_BEACON_URL,g" $DYNATRACE_PLUGIN_FILE 
sed -i '' -e "s,__DYNATRACE_IOS_ENVIRONMENT__,$DYNATRACE_IOS_ENVIRONMENT,g" $DYNATRACE_PLUGIN_FILE 
sed -i '' -e "s,__DYNATRACE_IOS_CLUSTER_URL__,$DYNATRACE_IOS_CLUSTER_URL,g" $DYNATRACE_PLUGIN_FILE 
echo "DYNATRACE Config: File content: $DYNATRACE_PLUGIN_FILE"
cat $DYNATRACE_PLUGIN_FILE
echo '----------------'

#run Jetijy to convert libs to AndroidX. OBS: RN 0.60 run automaticaly on build
if [ "$PLATAFORM_ANDROID" == "true" ]
then
    echo "Running jetify"
    node node_modules/jetifier/bin/jetify
fi

#Dynatrace Instrumentation
echo "Dynatrace instrument..."
node node_modules/@dynatrace/react-native-plugin/scripts/instrument.js