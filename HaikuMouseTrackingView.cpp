/*
 * Copyright 2012. All rights reserved.
 * Distributed under the terms of the MIT license.
 *
 * Author:
 *	hey68you@gmail.com
 *
 */

#include <View.h>
#include <Rect.h>
#include <Point.h>
#include <stdio.h>
#include <stdlib.h>
#include <Window.h>
#include "HaikuMouseTrackingView.h"

HaikuMouseTrackingView::HaikuMouseTrackingView(BRect frame, MainWindow *mainWinObj)
		: BView(frame,"aHaikuMouseTrackingView", /*B_FOLLOW_NONE*/B_FOLLOW_ALL, 0)
{
	SetViewColor(B_TRANSPARENT_COLOR);
    theMainWindow_ = mainWinObj;
    //printf("HaikuMouseTrackingView constructor = %p", &theMainWindow_);
}

HaikuMouseTrackingView::~HaikuMouseTrackingView()
{
}

void
HaikuMouseTrackingView::MouseMoved(BPoint point, uint32 transit __attribute__((unused)), const BMessage *message __attribute__((unused))) //suppress the unused var warnings.
{
    BWindow *window = Window();
    BRect windowFrame = window->Frame();
    point = ConvertToScreen(point);

	//printf("MouseMoved on HaikuMouseTrackingView x,y,bottom = %f, %f, %f\n", point.x, point.y, windowFrame.bottom);

    int currentDockPosition = theMainWindow_->getCurrentDockScreenPosition();

    //if ((point.y >= windowFrame.bottom) && currentDockPosition == SCREEN_POSITION_BOTTOM)
    if ((point.y >= windowFrame.bottom - 1) && currentDockPosition == SCREEN_POSITION_BOTTOM)
    {
        theMainWindow_->Activate();
    }
    else if ((point.x <= windowFrame.left) && currentDockPosition == SCREEN_POSITION_LEFT)
    {
        theMainWindow_->Activate();
    }
    //else if ((point.x >= windowFrame.right) && currentDockPosition == SCREEN_POSITION_RIGHT)
    else if ((point.x >= windowFrame.right - 1) && currentDockPosition == SCREEN_POSITION_RIGHT)
    {
        theMainWindow_->Activate();
    }
    else if ((point.y <= windowFrame.top) && currentDockPosition == SCREEN_POSITION_TOP)
    {
        theMainWindow_->Activate();
    }
}

void
HaikuMouseTrackingView::MouseUp(BPoint point __attribute__((unused)))
{
//    printf("HaikuMouseTrackingView MouseUp x,y = %f, %f\n",  point.x, point.y);
}

void
HaikuMouseTrackingView::MessageReceived(BMessage *message)
{
//    printf("HaikuMouseTrackingView message received!!!\n");

	BView::MessageReceived(message);
}
