// Register and select a user-installed keyboard layout in the current login session.
#include <Carbon/Carbon.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    if (argc != 2) return 2;
    CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL,
        (const UInt8 *)argv[1], (CFIndex)strlen(argv[1]), false);
    if (!url) return 2;
    OSStatus status = TISRegisterInputSource(url);
    CFRelease(url);
    if (status != noErr) {
        fprintf(stderr, "Could not register keyboard layout: %d\n", (int)status);
        return 1;
    }
    CFArrayRef sources = TISCreateInputSourceList(NULL, true);
    if (!sources) return 1;
    int result = 1;
    for (CFIndex i = 0; i < CFArrayGetCount(sources); i++) {
        TISInputSourceRef source = (TISInputSourceRef)CFArrayGetValueAtIndex(sources, i);
        CFStringRef name = TISGetInputSourceProperty(source, kTISPropertyLocalizedName);
        if (name && CFEqual(name, CFSTR("US - Alt Shortcuts"))) {
            status = TISEnableInputSource(source);
            if (status == noErr) status = TISSelectInputSource(source);
            TISInputSourceRef selected = TISCopyCurrentKeyboardInputSource();
            CFStringRef selectedID = selected ? TISGetInputSourceProperty(selected, kTISPropertyInputSourceID) : NULL;
            CFStringRef expectedID = TISGetInputSourceProperty(source, kTISPropertyInputSourceID);
            if (status == noErr && selectedID && expectedID && CFEqual(selectedID, expectedID)) result = 0;
            if (selected) CFRelease(selected);
            break;
        }
    }
    CFRelease(sources);
    if (result) fprintf(stderr, "Select US - Alt Shortcuts in Keyboard > Text Input > Edit after logging in again.\n");
    return result;
}
