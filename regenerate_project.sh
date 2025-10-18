#!/bin/bash

set -e

echo "🚀 Regenerating Xcode Project..."

PROJECT_DIR="/Users/vladparau/Documents/GitHub/DontBeLate"
cd "$PROJECT_DIR"

mkdir -p DontBeLate.xcodeproj
mkdir -p DontBeLate.xcodeproj/project.xcworkspace

cat > DontBeLate.xcodeproj/project.xcworkspace/contents.xcworkspacedata <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
EOF

generate_uuid() {
    echo "$1" | md5 | cut -c1-24 | tr '[:lower:]' '[:upper:]'
}

# Groups
MAIN_GROUP=$(generate_uuid "MAIN_GROUP")
PRODUCTS_GROUP=$(generate_uuid "PRODUCTS_GROUP")
APP_GROUP=$(generate_uuid "APP_GROUP")
MODELS_GROUP=$(generate_uuid "MODELS_GROUP")
SERVICES_GROUP=$(generate_uuid "SERVICES_GROUP")
VIEWMODELS_GROUP=$(generate_uuid "VIEWMODELS_GROUP")
VIEWS_GROUP=$(generate_uuid "VIEWS_GROUP")

PROJECT_REF=$(generate_uuid "PROJECT")
TARGET_REF=$(generate_uuid "TARGET")
PRODUCT_REF=$(generate_uuid "PRODUCT")

# All source files
APP_FILE_REF=$(generate_uuid "DontBeLateApp.swift")
CONTENT_FILE_REF=$(generate_uuid "ContentView.swift")
APPSTATE_FILE_REF=$(generate_uuid "AppState.swift")
EVENT_FILE_REF=$(generate_uuid "Event.swift")
SETTINGS_FILE_REF=$(generate_uuid "UserSettings.swift")
EVENTCONFIG_FILE_REF=$(generate_uuid "EventConfiguration.swift")
CALENDAR_FILE_REF=$(generate_uuid "CalendarService.swift")
LOCATION_FILE_REF=$(generate_uuid "LocationService.swift")
NOTIFICATION_FILE_REF=$(generate_uuid "NotificationService.swift")
APPBLOCK_FILE_REF=$(generate_uuid "AppBlockingService.swift")
EVENTMON_FILE_REF=$(generate_uuid "EventMonitor.swift")
BACKGROUND_FILE_REF=$(generate_uuid "BackgroundTaskManager.swift")
HOMEVM_FILE_REF=$(generate_uuid "HomeViewModel.swift")
ONBOARD_FILE_REF=$(generate_uuid "OnboardingView.swift")
HOME_FILE_REF=$(generate_uuid "HomeView.swift")
UPCOMING_FILE_REF=$(generate_uuid "UpcomingEventsView.swift")
SETTINGSV_FILE_REF=$(generate_uuid "SettingsView.swift")
APPSELECTOR_FILE_REF=$(generate_uuid "AppSelectorView.swift")
EVENTDETAIL_FILE_REF=$(generate_uuid "EventDetailView.swift")
LOADING_FILE_REF=$(generate_uuid "LoadingView.swift")
APPBLOCKINFO_FILE_REF=$(generate_uuid "AppBlockingInfoView.swift")
INFO_FILE_REF=$(generate_uuid "Info.plist")

# Build files
APP_BUILD=$(generate_uuid "BUILD_DontBeLateApp.swift")
CONTENT_BUILD=$(generate_uuid "BUILD_ContentView.swift")
APPSTATE_BUILD=$(generate_uuid "BUILD_AppState.swift")
EVENT_BUILD=$(generate_uuid "BUILD_Event.swift")
SETTINGS_BUILD=$(generate_uuid "BUILD_UserSettings.swift")
EVENTCONFIG_BUILD=$(generate_uuid "BUILD_EventConfiguration.swift")
CALENDAR_BUILD=$(generate_uuid "BUILD_CalendarService.swift")
LOCATION_BUILD=$(generate_uuid "BUILD_LocationService.swift")
NOTIFICATION_BUILD=$(generate_uuid "BUILD_NotificationService.swift")
APPBLOCK_BUILD=$(generate_uuid "BUILD_AppBlockingService.swift")
EVENTMON_BUILD=$(generate_uuid "BUILD_EventMonitor.swift")
BACKGROUND_BUILD=$(generate_uuid "BUILD_BackgroundTaskManager.swift")
HOMEVM_BUILD=$(generate_uuid "BUILD_HomeViewModel.swift")
ONBOARD_BUILD=$(generate_uuid "BUILD_OnboardingView.swift")
HOME_BUILD=$(generate_uuid "BUILD_HomeView.swift")
UPCOMING_BUILD=$(generate_uuid "BUILD_UpcomingEventsView.swift")
SETTINGSV_BUILD=$(generate_uuid "BUILD_SettingsView.swift")
APPSELECTOR_BUILD=$(generate_uuid "BUILD_AppSelectorView.swift")
EVENTDETAIL_BUILD=$(generate_uuid "BUILD_EventDetailView.swift")
LOADING_BUILD=$(generate_uuid "BUILD_LoadingView.swift")
APPBLOCKINFO_BUILD=$(generate_uuid "BUILD_AppBlockingInfoView.swift")

SOURCES_PHASE=$(generate_uuid "SOURCES_PHASE")
FRAMEWORKS_PHASE=$(generate_uuid "FRAMEWORKS_PHASE")
RESOURCES_PHASE=$(generate_uuid "RESOURCES_PHASE")

PROJECT_CONFIG_LIST=$(generate_uuid "PROJECT_CONFIG_LIST")
TARGET_CONFIG_LIST=$(generate_uuid "TARGET_CONFIG_LIST")
DEBUG_CONFIG=$(generate_uuid "DEBUG_CONFIG")
RELEASE_CONFIG=$(generate_uuid "RELEASE_CONFIG")
TARGET_DEBUG_CONFIG=$(generate_uuid "TARGET_DEBUG_CONFIG")
TARGET_RELEASE_CONFIG=$(generate_uuid "TARGET_RELEASE_CONFIG")

cat > DontBeLate.xcodeproj/project.pbxproj <<EOF
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		$APP_BUILD /* DontBeLateApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = $APP_FILE_REF /* DontBeLateApp.swift */; };
		$CONTENT_BUILD /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $CONTENT_FILE_REF /* ContentView.swift */; };
		$APPSTATE_BUILD /* AppState.swift in Sources */ = {isa = PBXBuildFile; fileRef = $APPSTATE_FILE_REF /* AppState.swift */; };
		$EVENT_BUILD /* Event.swift in Sources */ = {isa = PBXBuildFile; fileRef = $EVENT_FILE_REF /* Event.swift */; };
		$SETTINGS_BUILD /* UserSettings.swift in Sources */ = {isa = PBXBuildFile; fileRef = $SETTINGS_FILE_REF /* UserSettings.swift */; };
		$EVENTCONFIG_BUILD /* EventConfiguration.swift in Sources */ = {isa = PBXBuildFile; fileRef = $EVENTCONFIG_FILE_REF /* EventConfiguration.swift */; };
		$CALENDAR_BUILD /* CalendarService.swift in Sources */ = {isa = PBXBuildFile; fileRef = $CALENDAR_FILE_REF /* CalendarService.swift */; };
		$LOCATION_BUILD /* LocationService.swift in Sources */ = {isa = PBXBuildFile; fileRef = $LOCATION_FILE_REF /* LocationService.swift */; };
		$NOTIFICATION_BUILD /* NotificationService.swift in Sources */ = {isa = PBXBuildFile; fileRef = $NOTIFICATION_FILE_REF /* NotificationService.swift */; };
		$APPBLOCK_BUILD /* AppBlockingService.swift in Sources */ = {isa = PBXBuildFile; fileRef = $APPBLOCK_FILE_REF /* AppBlockingService.swift */; };
		$EVENTMON_BUILD /* EventMonitor.swift in Sources */ = {isa = PBXBuildFile; fileRef = $EVENTMON_FILE_REF /* EventMonitor.swift */; };
		$BACKGROUND_BUILD /* BackgroundTaskManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = $BACKGROUND_FILE_REF /* BackgroundTaskManager.swift */; };
		$HOMEVM_BUILD /* HomeViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = $HOMEVM_FILE_REF /* HomeViewModel.swift */; };
		$ONBOARD_BUILD /* OnboardingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $ONBOARD_FILE_REF /* OnboardingView.swift */; };
		$HOME_BUILD /* HomeView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $HOME_FILE_REF /* HomeView.swift */; };
		$UPCOMING_BUILD /* UpcomingEventsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $UPCOMING_FILE_REF /* UpcomingEventsView.swift */; };
		$SETTINGSV_BUILD /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $SETTINGSV_FILE_REF /* SettingsView.swift */; };
		$APPSELECTOR_BUILD /* AppSelectorView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $APPSELECTOR_FILE_REF /* AppSelectorView.swift */; };
		$EVENTDETAIL_BUILD /* EventDetailView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $EVENTDETAIL_FILE_REF /* EventDetailView.swift */; };
		$LOADING_BUILD /* LoadingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $LOADING_FILE_REF /* LoadingView.swift */; };
		$APPBLOCKINFO_BUILD /* AppBlockingInfoView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $APPBLOCKINFO_FILE_REF /* AppBlockingInfoView.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		$PRODUCT_REF /* DontBeLate.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = DontBeLate.app; sourceTree = BUILT_PRODUCTS_DIR; };
		$APP_FILE_REF /* DontBeLateApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DontBeLateApp.swift; sourceTree = "<group>"; };
		$CONTENT_FILE_REF /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		$APPSTATE_FILE_REF /* AppState.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppState.swift; sourceTree = "<group>"; };
		$EVENT_FILE_REF /* Event.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Event.swift; sourceTree = "<group>"; };
		$SETTINGS_FILE_REF /* UserSettings.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = UserSettings.swift; sourceTree = "<group>"; };
		$EVENTCONFIG_FILE_REF /* EventConfiguration.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EventConfiguration.swift; sourceTree = "<group>"; };
		$CALENDAR_FILE_REF /* CalendarService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CalendarService.swift; sourceTree = "<group>"; };
		$LOCATION_FILE_REF /* LocationService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LocationService.swift; sourceTree = "<group>"; };
		$NOTIFICATION_FILE_REF /* NotificationService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NotificationService.swift; sourceTree = "<group>"; };
		$APPBLOCK_FILE_REF /* AppBlockingService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppBlockingService.swift; sourceTree = "<group>"; };
		$EVENTMON_FILE_REF /* EventMonitor.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EventMonitor.swift; sourceTree = "<group>"; };
		$BACKGROUND_FILE_REF /* BackgroundTaskManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BackgroundTaskManager.swift; sourceTree = "<group>"; };
		$HOMEVM_FILE_REF /* HomeViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeViewModel.swift; sourceTree = "<group>"; };
		$ONBOARD_FILE_REF /* OnboardingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OnboardingView.swift; sourceTree = "<group>"; };
		$HOME_FILE_REF /* HomeView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeView.swift; sourceTree = "<group>"; };
		$UPCOMING_FILE_REF /* UpcomingEventsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = UpcomingEventsView.swift; sourceTree = "<group>"; };
		$SETTINGSV_FILE_REF /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };
		$APPSELECTOR_FILE_REF /* AppSelectorView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppSelectorView.swift; sourceTree = "<group>"; };
		$EVENTDETAIL_FILE_REF /* EventDetailView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EventDetailView.swift; sourceTree = "<group>"; };
		$LOADING_FILE_REF /* LoadingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LoadingView.swift; sourceTree = "<group>"; };
		$APPBLOCKINFO_FILE_REF /* AppBlockingInfoView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppBlockingInfoView.swift; sourceTree = "<group>"; };
		$INFO_FILE_REF /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		$FRAMEWORKS_PHASE /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		$MAIN_GROUP = {
			isa = PBXGroup;
			children = (
				$APP_GROUP /* DontBeLateApp */,
				$PRODUCTS_GROUP /* Products */,
			);
			sourceTree = "<group>";
		};
		$PRODUCTS_GROUP /* Products */ = {
			isa = PBXGroup;
			children = (
				$PRODUCT_REF /* DontBeLate.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		$APP_GROUP /* DontBeLateApp */ = {
			isa = PBXGroup;
			children = (
				$APP_FILE_REF /* DontBeLateApp.swift */,
				$CONTENT_FILE_REF /* ContentView.swift */,
				$MODELS_GROUP /* Models */,
				$SERVICES_GROUP /* Services */,
				$VIEWMODELS_GROUP /* ViewModels */,
				$VIEWS_GROUP /* Views */,
				$INFO_FILE_REF /* Info.plist */,
			);
			path = DontBeLateApp;
			sourceTree = "<group>";
		};
		$MODELS_GROUP /* Models */ = {
			isa = PBXGroup;
			children = (
				$APPSTATE_FILE_REF /* AppState.swift */,
				$EVENT_FILE_REF /* Event.swift */,
				$SETTINGS_FILE_REF /* UserSettings.swift */,
				$EVENTCONFIG_FILE_REF /* EventConfiguration.swift */,
			);
			path = Models;
			sourceTree = "<group>";
		};
		$SERVICES_GROUP /* Services */ = {
			isa = PBXGroup;
			children = (
				$CALENDAR_FILE_REF /* CalendarService.swift */,
				$LOCATION_FILE_REF /* LocationService.swift */,
				$NOTIFICATION_FILE_REF /* NotificationService.swift */,
				$APPBLOCK_FILE_REF /* AppBlockingService.swift */,
			);
			path = Services;
			sourceTree = "<group>";
		};
		$VIEWMODELS_GROUP /* ViewModels */ = {
			isa = PBXGroup;
			children = (
				$EVENTMON_FILE_REF /* EventMonitor.swift */,
				$BACKGROUND_FILE_REF /* BackgroundTaskManager.swift */,
				$HOMEVM_FILE_REF /* HomeViewModel.swift */,
			);
			path = ViewModels;
			sourceTree = "<group>";
		};
		$VIEWS_GROUP /* Views */ = {
			isa = PBXGroup;
			children = (
				$ONBOARD_FILE_REF /* OnboardingView.swift */,
				$HOME_FILE_REF /* HomeView.swift */,
				$UPCOMING_FILE_REF /* UpcomingEventsView.swift */,
				$SETTINGSV_FILE_REF /* SettingsView.swift */,
				$APPSELECTOR_FILE_REF /* AppSelectorView.swift */,
				$EVENTDETAIL_FILE_REF /* EventDetailView.swift */,
				$LOADING_FILE_REF /* LoadingView.swift */,
				$APPBLOCKINFO_FILE_REF /* AppBlockingInfoView.swift */,
			);
			path = Views;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		$TARGET_REF /* DontBeLate */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = $TARGET_CONFIG_LIST /* Build configuration list for PBXNativeTarget "DontBeLate" */;
			buildPhases = (
				$SOURCES_PHASE /* Sources */,
				$FRAMEWORKS_PHASE /* Frameworks */,
				$RESOURCES_PHASE /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = DontBeLate;
			productName = DontBeLate;
			productReference = $PRODUCT_REF /* DontBeLate.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		$PROJECT_REF /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					$TARGET_REF = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = $PROJECT_CONFIG_LIST /* Build configuration list for PBXProject "DontBeLate" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = $MAIN_GROUP;
			productRefGroup = $PRODUCTS_GROUP /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				$TARGET_REF /* DontBeLate */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		$RESOURCES_PHASE /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		$SOURCES_PHASE /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				$APP_BUILD /* DontBeLateApp.swift in Sources */,
				$CONTENT_BUILD /* ContentView.swift in Sources */,
				$APPSTATE_BUILD /* AppState.swift in Sources */,
				$EVENT_BUILD /* Event.swift in Sources */,
				$SETTINGS_BUILD /* UserSettings.swift in Sources */,
				$EVENTCONFIG_BUILD /* EventConfiguration.swift in Sources */,
				$CALENDAR_BUILD /* CalendarService.swift in Sources */,
				$LOCATION_BUILD /* LocationService.swift in Sources */,
				$NOTIFICATION_BUILD /* NotificationService.swift in Sources */,
				$APPBLOCK_BUILD /* AppBlockingService.swift in Sources */,
				$EVENTMON_BUILD /* EventMonitor.swift in Sources */,
				$BACKGROUND_BUILD /* BackgroundTaskManager.swift in Sources */,
				$HOMEVM_BUILD /* HomeViewModel.swift in Sources */,
				$ONBOARD_BUILD /* OnboardingView.swift in Sources */,
				$HOME_BUILD /* HomeView.swift in Sources */,
				$UPCOMING_BUILD /* UpcomingEventsView.swift in Sources */,
				$SETTINGSV_BUILD /* SettingsView.swift in Sources */,
				$APPSELECTOR_BUILD /* AppSelectorView.swift in Sources */,
				$EVENTDETAIL_BUILD /* EventDetailView.swift in Sources */,
				$LOADING_BUILD /* LoadingView.swift in Sources */,
				$APPBLOCKINFO_BUILD /* AppBlockingInfoView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		$DEBUG_CONFIG /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"\$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		$RELEASE_CONFIG /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		$TARGET_DEBUG_CONFIG /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION = YES;
				CODE_SIGN_ENTITLEMENTS = DontBeLateApp.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = DontBeLateApp/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.dontbelate.DontBeLate;
				PRODUCT_NAME = "\$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		$TARGET_RELEASE_CONFIG /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION = YES;
				CODE_SIGN_ENTITLEMENTS = DontBeLateApp.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = DontBeLateApp/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.dontbelate.DontBeLate;
				PRODUCT_NAME = "\$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		$PROJECT_CONFIG_LIST /* Build configuration list for PBXProject "DontBeLate" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				$DEBUG_CONFIG /* Debug */,
				$RELEASE_CONFIG /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		$TARGET_CONFIG_LIST /* Build configuration list for PBXNativeTarget "DontBeLate" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				$TARGET_DEBUG_CONFIG /* Debug */,
				$TARGET_RELEASE_CONFIG /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = $PROJECT_REF /* Project object */;
}
EOF

echo "✅ Project regenerated successfully!"
echo ""
echo "All files included:"
echo "  - DontBeLateApp.swift"
echo "  - ContentView.swift"
echo "  - Models: AppState, Event, UserSettings, EventConfiguration"
echo "  - Services: Calendar, Location, Notification, AppBlocking"
echo "  - ViewModels: EventMonitor, BackgroundTaskManager, HomeViewModel"
echo "  - Views: Onboarding, Home, UpcomingEvents, Settings, AppSelector, EventDetail, Loading, AppBlockingInfo"
echo ""
echo "Next: Open DontBeLate.xcodeproj in Xcode"

