#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
int main(void) {
 @autoreleasepool {
  NSMutableArray *result = [NSMutableArray array];
  for (NSScreen *screen in NSScreen.screens) {
   NSNumber *displayID = screen.deviceDescription[@"NSScreenNumber"];
   CGFloat height = 0, width = 0;
   if (@available(macOS 12.0, *)) {
    height = screen.safeAreaInsets.top;
    if (height > 0) {
     NSRect left = screen.auxiliaryTopLeftArea, right = screen.auxiliaryTopRightArea;
     width = MAX(0, NSMinX(right) - NSMaxX(left));
    }
   }
   [result addObject:@{@"id":displayID, @"main":@([displayID unsignedIntValue] == CGMainDisplayID()),
     @"builtin":@(CGDisplayIsBuiltin([displayID unsignedIntValue]) != 0),
     @"reserved_top":@(MAX(height, NSMaxY(screen.frame) - NSMaxY(screen.visibleFrame))),
     @"name":screen.localizedName, @"notch_height":@(height), @"notch_width":@(width),
     @"width":@(screen.frame.size.width)}];
  }
  if (!result.count) return 1;
  NSData *json = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
  fwrite(json.bytes,1,json.length,stdout); putchar('\n');
 }
 return 0;
}
