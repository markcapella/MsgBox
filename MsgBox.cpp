
// Std C and c++.
#include <iostream>
#include <string>
#include <string.h>

// X11.
#include <X11/Xatom.h>
#include <X11/Xft/Xft.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

using namespace std;

// Application.
#include "MsgBox.h"
#include "xPngWrapper.h"


/**
 * Module Consts.
 */
const string INPUT_PNGFILE =
    "/usr/share/icons/hicolor/48x48/apps/msgboxerror.png";

const XftColor mFontColor = {
    .pixel = 0x0, .color = {
        .red = 0xff, .green = 0xff,
        .blue = 0xff, .alpha = 0xffff
    }
};

/**
 * Module globals.
 */
Display* mDisplay;
Window mMsgBox;
XftFont* mFont;
xPngWrapper* mIconWrapper;

/**
 * Module Entry.
 */
int main(int argCount, char** argValues) {
    // Ensure proper invocation.
    if (argCount < APP_PARMS_REQUIRED) {
        displayUsage();
        return true;
    }

    // Parse invocation.
    const int xPos = atoi(argValues[1]);
    const int yPos = atoi(argValues[2]);
    const int width = atoi(argValues[3]);
    const int height = atoi(argValues[4]);
    const string msgTitle(argValues[5]);
    const string msgString(argValues[6]);

    // Get wrapped PNG file for the Icon.
    char* pngFileName = strdup(INPUT_PNGFILE.c_str());
    mIconWrapper = new xPngWrapper(pngFileName);
    if (mIconWrapper->hasErrorStatus()) {
        cout << COLOR_RED << endl << "MsgBox: " <<
            mIconWrapper->errorStatus() <<
            COLOR_NORMAL << endl;
        return true;
    }

    // Open X11 display, ensure it's available.
    mDisplay = XOpenDisplay(NULL);
    if (mDisplay == NULL) {
        cout << COLOR_RED << "MsgBox: X11 Windows are "
            "unavailable with this desktop. - FATAL" <<
            COLOR_NORMAL << "\n";
        exit(2);
    }

    // Set font for layouts.
    mFont = XftFontOpenName(mDisplay,
        DefaultScreen(mDisplay), "-misc-fixed-medium-r-normal-"
        "-15-140-75-75-c-90-iso8859-16");
    if (mFont == NULL) {
        cout << COLOR_RED << "\nMsgBox: Cannot open XftFont - "
            "FATAL.\n" << COLOR_NORMAL;
        exit(3);
    }

    // Create MsgBox from X11 window.
    mMsgBox = XCreateSimpleWindow(mDisplay,
        DefaultRootWindow(mDisplay), 0, 0, width, height,
        1, BlackPixel(mDisplay, 0), WhitePixel(mDisplay, 0));

    // Set title string.
    XTextProperty properties;
    properties.value = (unsigned char*) msgTitle.c_str();
    properties.encoding = XA_STRING;
    properties.format = 8;
    properties.nitems = msgTitle.length();
    XSetWMName(mDisplay, mMsgBox, &properties);

    // Set icon name strings.
    XClassHint* classHint = XAllocClassHint();
    if (classHint) {
        classHint->res_class = pngFileName;
        classHint->res_name = pngFileName;
        XSetClassHint(mDisplay, mMsgBox, classHint);
        XFree(classHint);
    }
    XTextProperty iconProperty;
    XStringListToTextProperty(&pngFileName, 1,
        &iconProperty);
    XSetWMIconName(mDisplay, mMsgBox, &iconProperty);

    // Set the _NET_WM_ICON property from the vector.
    const Atom net_wm_icon = XInternAtom(mDisplay,
        "_NET_WM_ICON", False);
    XChangeProperty(mDisplay, mMsgBox, net_wm_icon,
        XA_CARDINAL, 32, PropModeReplace,
        reinterpret_cast<unsigned char*>
            (mIconWrapper->getPngData().data()),
             mIconWrapper->getPngData().size());

    // Map (show) MsgBox window.
    XMapWindow(mDisplay, mMsgBox);
    XMoveWindow(mDisplay, mMsgBox, xPos, yPos);

    // Select observable x11 events &
    // Select observable x11 client messages.
    XSelectInput(mDisplay, mMsgBox, ExposureMask);
    Atom mDeleteMessage = XInternAtom(mDisplay,
        "WM_DELETE_WINDOW", False);
    XSetWMProtocols(mDisplay, mMsgBox, &mDeleteMessage, 1);

    // Loop until close event frees us.
    bool msgboxActive = true;
    while (msgboxActive) {
        XEvent event;
        XNextEvent(mDisplay, &event);

        // Process ClientMsg Close event.
        if (event.type == ClientMessage) {
            if (event.xclient.data.l[0] == mDeleteMessage) {
                msgboxActive = false;
            }
            break;
        }

        // Process Expose event. Set the MsgBox
        // Msg on Window expose.
        if (event.type == Expose) {
            if (XPending(mDisplay) == 0) {
                const XExposeEvent* EVENT =
                    (XExposeEvent*) &event;
                if (EVENT->width > 1 && EVENT->height > 1) {
                    XftDraw* textDrawable = XftDrawCreate(mDisplay,
                        mMsgBox, DefaultVisual(mDisplay,
                        DefaultScreen(mDisplay)),
                        DefaultColormap(mDisplay,
                        DefaultScreen(mDisplay)));
                    XftDrawString8(textDrawable, &mFontColor, mFont,
                        LEFT_MARGIN, TOP_MARGIN, (const FcChar8*)
                        msgString.c_str(), msgString.length());
                }
            }
        }
    }

    // Close display & done.
    XUnmapWindow(mDisplay, mMsgBox);
    XDestroyWindow(mDisplay, mMsgBox);
    XCloseDisplay(mDisplay);
}

/**
 * Helper method to display app cmdline invocation.
 */
void displayUsage() {
    cout << COLOR_BLUE << "\nUsage:" << COLOR_NORMAL << "\n";
    cout << COLOR_GREEN << "   MsgBox xPos yPos width height "
        "title message" << COLOR_NORMAL << "\n";

    cout << COLOR_BLUE << "\nExample:" << COLOR_NORMAL << "\n";
    cout << COLOR_GREEN << "   MsgBox 600 500 260 66 \"Warning\" "
        "\"Something Bad happened  :-(\"" << COLOR_NORMAL << "\n";
}
