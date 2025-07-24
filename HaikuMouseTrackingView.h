/*
 * Copyright 2012. All rights reserved.
 * Distributed under the terms of the MIT license.
 *
 * Author:
 *	hey68you@gmail.com
 *
 */

#ifndef HIQDOCK_HAIKUMOUSETRACKINGVIEW_H
#define HIQDOCK_HAIKUMOUSETRACKINGVIEW_H

#include "mainWindow.h"

class HaikuMouseTrackingView : public BView
{
    public:
        HaikuMouseTrackingView(BRect frame, MainWindow *mainWinObj);
        ~HaikuMouseTrackingView();
    private:        MainWindow *theMainWindow_;

    virtual void MouseMoved(BPoint point, uint32 transit, const BMessage *message);
    virtual void MouseUp(BPoint point);
    virtual void MessageReceived (BMessage *message);
};

#endif // HIQDOCK_HAIKUMOUSETRACKINGVIEW_H
