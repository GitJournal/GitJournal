#!/bin/bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

usage()
{
    # Display Help

   echo "*********************************************************************************************************************************************************"
   echo "  MacOS Application Notarization Script"
   echo "*********************************************************************************************************************************************************"
   echo
   echo "   Requirements"
   echo "    - XCode Installed"
   echo "    - Apple Id Account app-specific Password (https://support.apple.com/en-us/HT204397)"
   echo "    - Apple Developer ID Application Certificate created and installed in keychain (https://developer.apple.com/support/developer-id/)"
   echo
   echo "   Instructions"
   echo "    1. Run notarize option to code sign application and create notarization request"
   echo "    2. Run check option with the request UUID of the previous step to check the notarization status"
   echo "    3. Run staple option only if the notarization status was successful and package was approved"
   echo "    4. You are now ready to distribute, if you want to create an installer you can use this option https://github.com/sindresorhus/create-dmg."
   echo "       Note that if you distribute your app in a .dmg, follow these steps:"
   echo
   echo "      - Add your notarized and stapled app to the DMG."
   echo "      - Notarize your .dmg file."
   echo "             Example: sh $0 --notarize -a MyApp.dmg  -b com.company.myapp  -u myappleaccount@gmail.com -p aaaa-aaaa-aaaa-aaa -v FFFFFFFF)"
   echo "      - Staple the notarization to the .dmg file: xcrun stapler staple MyApp.dmg."
   echo "             Example: sh $0 --staple --file MyApp.dmg"
   echo "________________________________________________________________________________________________________________________________________________________"
   echo
   echo "  Usage"
   echo "   $0 [-n|s|c] [ -a APP_NAME ] [ -i SIGNING_IDENTITY ] [ -e ENTITLEMENTS ]  [ -b BUNDLE_ID ] [ -u USERNAME ] [ -p PASSWORD ] [ -v PROVIDER ] [ -k UUID ]"
   echo
   echo "________________________________________________________________________________________________________________________________________________________"
   echo
   echo "  Options:"
   echo
   notarizeHelp
   checkHelp
   stapleHelp

  return
}
notarizeHelp()
{
   echo "    ======================================================================="
   echo "    -n | --notarize  Notarize file"
   echo "    ======================================================================="
   echo "    Syntax:"
   echo "              [ -n | --notarize ] [ -a | --file APP_NAME ] [ -i SIGNING_IDENTITY ] [ -e ENTITLEMENTS ]  [ -b BUNDLE_ID ] [ -u USERNAME ] [ -p PASSWORD ] [ -v PROVIDER ]"
   echo "    Parameters:"
   echo "              [ -a | --file  ]        - File name"
   echo "              [ -i ]                  - Apple Signing identity"
   echo "              [ -e ]                  - Application entitlements file"
   echo "              [ -b ]                  - Application Bundle identifier"
   echo "              [ -u ]                  - Apple Developer ID Username"
   echo "              [ -p ]                  - Application Specific password"
   echo "              [ -v ]                  - Access Provider"
   echo "    Example:"
   echo "       .app   sh $0 --notarize -a MyApp.app  -b com.company.myapp  -u myappleaccount@gmail.com -p aaaa-aaaa-aaaa-aaa -v FFFFFFFF -e App.entitlements -i \"Developer ID Application: COMPANY\""
   echo "       .zip   sh $0 --notarize -a MyApp.app.zip  -b com.company.myapp  -u myappleaccount@gmail.com -p aaaa-aaaa-aaaa-aaa -v FFFFFFFF"
   echo "       .dmg   sh $0 --notarize -a MyApp.dmg  -b com.company.myapp  -u myappleaccount@gmail.com -p aaaa-aaaa-aaaa-aaa -v FFFFFFFF"
   echo
}
checkHelp()
{
   echo "    ======================================================================="
   echo "    -c | --check     Check notarization status"
   echo "    ======================================================================="
   echo "    Syntax:"
   echo "              [ -c | --check ] [ -u USERNAME ] [ -p PASSWORD ] [ -k UUID ]"
   echo "    Parameters:"
   echo "              [ -u ]                  - Apple Developer ID Username"
   echo "              [ -p ]                  - Application Specific password"
   echo "              [ -k ]                  - Notarization Request UUID"
   echo "    Example:"
   echo "              sh $0 --check  -u myappleaccount@gmail.com -p aaaa-aaaa-aaaa-aaa -k ffff-ffffff-ffffff-ffffffffff"
   echo
}
stapleHelp()
{
   echo "    ======================================================================="
   echo "    -s | --staple    Staple file"
   echo "    ======================================================================="
   echo "    Syntax:"
   echo "              [ -s | --staple ] [ -a | --file APP_NAME ]"
   echo "    Parameters:"
   echo "              [ -a | --file  ]        - File name"
   echo "    Example:"
   echo "              sh $0 --staple --file MyApp.app"
   echo
}

#Help Dictionary 
helpFunction()
{

   echo ""
   usage
   exit 1 
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--notarize") set -- "$@" "-n" ;;
    "--staple")   set -- "$@" "-s" ;;
    "--check")    set -- "$@" "-c" ;;
    "--file")     set -- "$@" "-a" ;;
    *)            set -- "$@" "$arg"
  esac
done


while getopts "nsca:i:e:b:v:u:k:p:" option
do
case "${option}"
in
n) ACTION=NOTARIZE;;
s) ACTION=STAPLE;;
c) ACTION=CHECK;;
a) APP_NAME=${OPTARG};;
i) SIGNING_IDENTITY=${OPTARG};;
e) ENTITLEMENTS=${OPTARG};;
b) BUNDLE_ID=${OPTARG};;
p) PASSWORD=${OPTARG};;
v) PROVIDER=${OPTARG};;
u) USERNAME=${OPTARG};;
k) UUID=${OPTARG};;
?) helpFunction ;;
esac
done


do_check()
{
	echo "$UUID"
	if [ -z "${UUID}" ]; then
	    echo "[Error] Didn't specify notarization request UUID";
	fi
	
	if [ -z "${USERNAME}" ]; then
	    echo "[Error] Apple ID username is required";
	fi
	
	if [ -z "${PASSWORD}" ]; then
	    echo "[Error] App Specific password is required";
	fi
	
	if [ -z "${UUID}" ] || [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ]; then
		echo
		checkHelp
		exit 1 
	fi
    echo "[INFO] Checking Notarization status for $UUID"
	xcrun altool --notarization-info "$UUID" -u "$USERNAME" -p "$PASSWORD" --output-format xml

	exit 1
}



sign()
{
	if [ -z "${APP_NAME}" ]; then
	    echo "[Error] Didn't specify a filename";
	fi
    if [ -z "${SIGNING_IDENTITY}" ]; then
	    echo "[Error] Didn't specify signing identity";
	fi
	if [ -z "${ENTITLEMENTS}" ]; then
	    echo "[Error] Didn't specify entitlements file";
	fi
	if [ -z "${BUNDLE_ID}" ]; then
	    echo "[Error] Didn't specify bundle identifier";
	fi
	if [ -z "${PROVIDER}" ]; then
	    echo "[Error] Didn't specify access provider";
	fi
	if [ -z "${USERNAME}" ]; then
	    echo "[Error] Apple ID username is required";
	fi
	if [ -z "${PASSWORD}" ]; then
	    echo "[Error] App Specific password is required";
	fi

	if  [ -z "${APP_NAME}" ] || [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ] || [ -z "${PROVIDER}" ]  || [ -z "${ENTITLEMENTS}" ] || [ -z "${SIGNING_IDENTITY}" ]; then
		echo
		notarizeHelp
		exit 1 
	fi

	echo "[INFO] Signing app contents"
	find "$APP_NAME/Contents"|while read fname; do
		if [[ -f $fname ]]; then
			echo "[INFO] Signing $fname"
			codesign --force --timestamp --options=runtime --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" $fname
		fi
	done

	echo "[INFO] Signing app file"


	codesign --force --timestamp --options=runtime --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$APP_NAME"

	echo "[INFO] Verifying Code Sign"

	codesign --verify --verbose "$APP_NAME"

	echo "[INFO] Zipping $APP_NAME to ${APP_NAME}.zip"

	ditto -c -k --rsrc --keepParent "$APP_NAME" "${APP_NAME}.zip"

	#echo "[INFO] Uploading $APP_NAME for notarization"

	#xcrun altool --notarize-app -t osx -f "${APP_NAME}.zip" --primary-bundle-id "$BUNDLE_ID" -u "$USERNAME" -p "$PASSWORD" --asc-provider "$PROVIDER"  --output-format xml

    notarizationUpload "${APP_NAME}.zip"
}

notarize()
{

	if [ -z "${APP_NAME}" ]; then
	    echo "[Error] Didn't specify a filename";
	fi
	if [ -z "${BUNDLE_ID}" ]; then
	    echo "[Error] Didn't specify bundle identifier";
	fi
	if [ -z "${PROVIDER}" ]; then
	    echo "[Error] Didn't specify access provider";
	fi
	if [ -z "${USERNAME}" ]; then
	    echo "[Error] Apple ID username is required";
	fi
	if [ -z "${PASSWORD}" ]; then
	    echo "[Error] App Specific password is required";
	fi

	if  [ -z "${APP_NAME}" ] || [ -z "${USERNAME}" ] || [ -z "${BUNDLE_ID}" ] || [ -z "${PASSWORD}" ] || [ -z "${PROVIDER}" ]; then
		echo
		notarizeHelp
		exit 1 
	fi


case "$APP_NAME" in
    *.app)  sign;;
    *.zip)  notarizationUpload "$APP_NAME";;
    *.dmg)  notarizationUpload "$APP_NAME";;
esac

 
}

notarizationUpload()
{
	echo "[INFO] Uploading $APP_NAME for notarization"
	xcrun altool --notarize-app -t osx -f "$1" --primary-bundle-id "$BUNDLE_ID" -u "$USERNAME" -p "$PASSWORD" --asc-provider "$PROVIDER"  --output-format xml | tee /tmp/app_notarizer

}

do_staple()
{

	if [ -z "${APP_NAME}" ]; then
	    echo "[Error] Didn't specify a filename";
	    echo
		stapleHelp
		exit 1 
	fi

	echo "[INFO] Stapling $APP_NAME"
	xcrun stapler staple "$APP_NAME"
	echo "[INFO] Validating Staple for $APP_NAME"
    xcrun stapler validate "$APP_NAME"
}



#Excute Action base on the option  -s -n -c
case $ACTION in
STAPLE) do_staple;;
CHECK) do_check;;
NOTARIZE) notarize;;
*) helpFunction;
esac



unset APP_NAME ACTION SIGNING_IDENTITY BUNDLE_ID ENTITLEMENTS USERNAME PASSWORD PROVIDER UUID