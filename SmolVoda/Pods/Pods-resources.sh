#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookAttachmentFrame.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookAttachmentFrame@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCancelButtonLandscape.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCancelButtonLandscape@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCancelButtonPortrait.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCancelButtonPortrait@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCardAccountLine.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCardAccountLine@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCardBackground.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCardBackground@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCardHeaderLine.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookCardHeaderLine@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookPaperClip.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookPaperClip@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookSendButtonLandscape.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookSendButtonLandscape@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookSendButtonPortrait.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookSendButtonPortrait@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookURLAttachment.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/DEFacebookURLAttachment@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/NavBarLandscape.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/NavBarLandscape1.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/NavBarLandscape@2x.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/Resources/NavBarLandscape@2x1.png"
install_resource "DEFacebookComposeViewController/FacebookComposeViewController/DEFacebookComposeView.xib"
install_resource "Facebook-iOS-SDK/src/FBUserSettingsViewResources.bundle"
install_resource "REActivityViewController/REActivityViewController/REActivityViewController.bundle"
install_resource "REActivityViewController/REActivityViewController/Localizations/de.lproj"
install_resource "REActivityViewController/REActivityViewController/Localizations/en.lproj"
install_resource "REActivityViewController/REActivityViewController/Localizations/fr.lproj"
install_resource "REActivityViewController/REActivityViewController/Localizations/ru.lproj"
install_resource "REActivityViewController/REActivityViewController/Localizations/uk.lproj"
install_resource "REActivityViewController/REActivityViewController/Localizations/zh-Hans.lproj"
install_resource "REComposeViewController/REComposeViewController/REComposeViewController.bundle"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ `xcrun --find actool` ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in 
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;  
  esac 
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
