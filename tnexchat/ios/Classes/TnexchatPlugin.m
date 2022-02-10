#import "TnexchatPlugin.h"
#if __has_include(<tnexchat/tnexchat-Swift.h>)
#import <tnexchat/tnexchat-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tnexchat-Swift.h"
#endif

@implementation TnexchatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTnexchatPlugin registerWithRegistrar:registrar];
}
@end
