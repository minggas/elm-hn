const electron = require('electron');

// Module to control application life.
const app = electron.app;
const remote = electron.remote;
const shell = electron.shell;
const BrowserWindow = electron.BrowserWindow;
//const Menu = remote.Menu;

// Create the menu.
//var menu = new Menu();

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
//
let mainWindow;

// Create the browser window.
function createWindow () {
    mainWindow = new BrowserWindow({
        width: 840, 
        height: 760,
        icon: `images/icon.png`
    });

    // Load the index.html of the app.
    mainWindow.loadURL(`file://${__dirname}/index.html`);

    // Open the DevTools.
    //mainWindow.webContents.openDevTools();

    // Emitted when the window is closed.
    mainWindow.on('closed', function () {

        // Dereference the window object, usually you would store windows
        // in an array if your app supports multi windows, this is the time
        // when you should delete the corresponding element.
        //
        mainWindow = null;
    });

    // Open URLs in the desktop browser.
    mainWindow.webContents.on('new-window', function(event, url) {
        event.preventDefault();
        shell.openExternal(url);
    });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
//
app.on('ready', createWindow);

// Quit when all windows are closed.
app.on('window-all-closed', function () {
    
    // On OS X it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q.
    //
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

// On OS X it's common to re-create a window in the app when the
// dock icon is clicked and there are no other windows open.
//
app.on('activate', function () {
    if (mainWindow === null) {
        createWindow();
    }
});