#import <AppKit/AppKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreWLAN/CoreWLAN.h>

@interface WiFiDelegate : NSObject <NSApplicationDelegate, CLLocationManagerDelegate>
@property(nonatomic, strong) CLLocationManager *location;
@property(nonatomic) BOOL requesting;
@property(nonatomic) BOOL finished;
@property(nonatomic, strong) NSWindow *window;
@end
@implementation WiFiDelegate
- (void)finish {
    if (self.finished) return;
    self.finished = YES;
    NSString *ssid = nil;
    CLAuthorizationStatus status = self.location.authorizationStatus;
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        ssid = CWWiFiClient.sharedWiFiClient.interface.ssid;
    }
    // Only the SSID is read. Never start location updates or request coordinates.
    NSString *value = ssid.length ? ssid : @"Hidden by macOS";
    value = [[value componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet] componentsJoinedByString:@" "];
    NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/com.grimaldev.sketchybar-wifi"];
    [NSFileManager.defaultManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:@{NSFilePosixPermissions: @0700} error:nil];
    [[NSString stringWithFormat:@"authorization=%d services=%d ssidAvailable=%d\n", status, CLLocationManager.locationServicesEnabled, ssid.length > 0] writeToFile:[directory stringByAppendingPathComponent:@"status"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [value writeToFile:[directory stringByAppendingPathComponent:@"ssid"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [NSApp terminate:nil];
}
- (void)requestPermission:(id)sender {
    if (self.location.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.location requestWhenInUseAuthorization];
    } else if (self.location.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
        [self finish];
    } else {
        [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"]];
    }
}
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.requesting = [NSProcessInfo.processInfo.arguments containsObject:@"--request"];
    self.location = [CLLocationManager new];
    self.location.delegate = self;
    if (self.requesting) {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 430, 170)
            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
            backing:NSBackingStoreBuffered defer:NO];
        self.window.title = @"SketchyBar Wi-Fi";
        NSTextField *text = [NSTextField wrappingLabelWithString:
            @"Allow Location access to show your connected Wi-Fi network name in SketchyBar. No geographic coordinates are requested."];
        text.frame = NSMakeRect(24, 75, 382, 70);
        [self.window.contentView addSubview:text];
        NSButton *button = [NSButton buttonWithTitle:@"Request Location Access" target:self action:@selector(requestPermission:)];
        button.frame = NSMakeRect(105, 22, 220, 32);
        [self.window.contentView addSubview:button];
        [self.window center];
        [self.window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self requestPermission:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self finish]; });
    }
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return YES; }
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if (self.requesting && manager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) [self finish];
}
@end
int main(void) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication;
        WiFiDelegate *delegate = [WiFiDelegate new];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}
