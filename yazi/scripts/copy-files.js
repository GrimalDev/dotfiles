ObjC.import('AppKit');

function copyFiles(paths, pasteboard) {
    if (!paths.length) throw new Error('No files selected');
    const urls = paths.map(function (path) {
        const absolute = $(path).stringByStandardizingPath;
        if (!$.NSFileManager.defaultManager.fileExistsAtPath(absolute)) {
            throw new Error('File does not exist: ' + path);
        }
        return $.NSURL.fileURLWithPath(absolute);
    });
    pasteboard.clearContents;
    if (!pasteboard.writeObjects($(urls))) throw new Error('Could not copy files to clipboard');
}

function run(argv) {
    copyFiles(argv, $.NSPasteboard.generalPasteboard);
}
