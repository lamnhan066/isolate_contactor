#import "IsolateContactorPlugin.h"
#if __has_include(<isolate_contactor/isolate_contactor-Swift.h>)
#import <isolate_contactor/isolate_contactor-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "isolate_contactor-Swift.h"
#endif

@implementation IsolateContactorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIsolateContactorPlugin registerWithRegistrar:registrar];
}
@end
