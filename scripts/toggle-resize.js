var window = workspace.activeWindow;
// Define your two target sizes [width, height]
var sizeA = [1280, 720];
var sizeB = [1920, 1080];

if (window.frameGeometry.width === sizeA[0]) {
    window.frameGeometry = { x: window.x, y: window.y, width: sizeB[0], height: sizeB[1] };
} else {
    window.frameGeometry = { x: window.x, y: window.y, width: sizeA[0], height: sizeA[1] };
}
