// #include <QDeclarativeView>
#include <QQmlContext>
#include <QQuickItem>
// #include <QQuickView>
#include <QApplication>
#include <QWidget>
#include <QQuickWidget>
#include <QScreen>
#include <QMessageBox>
#include <QFileIconProvider>
#include <QJSEngine>
// #include <QDeclarativeContext>
//#include <QScriptValue>
// #include "/boot/system/develop/headers/Qt/qscriptvalue.h"
#include <QtGui>
//#include <QVBoxLayout>
//#include <QThread>
//#include <QScriptEngine>
//#include "/boot/common/include/Qt/qscriptengine.h"
// #include "/boot/system/develop/headers/Qt/qscriptengine.h"
#include <QStandardPaths>
#include <Application.h>

#include <storage/Entry.h>
//#include <storage/Path.h>
#include <storage/AppFileInfo.h>
//#include "ui_PreferencesDialog.h"
//#include "mainWindow.h"
#include "HQDDialogWindow.h"
#include "HaikuMouseTrackingView.h"

#include <FindDirectory.h>
#include "mainWindow.h"

//========================================================
// CONSTANTS
//========================================================

#define INDEX_UNDEFINED -1
const uint32 M_SET_LAUNCHER_APP     = 'slap';
//const uint32 M_CHANGE_LAUNCHER_ICON = 'clin';

static const QString doubleQuote  = "\"";
static const QString cellEntryKey = "cellEntry";
static const QString appStringKey = "appString";
static const QString toolTipKey   = "toolTipText";
static const QString iconImageKey = "iconImage";
static const QString iconsFolder  = "HiQDockIcons";
//static const QString defaultTrackerIconName = "Tracker.svg";
//static const QString defaultTrashEmptyIconName = "Trash.svg";
static const QString defaultTrackerIconName =    "qrc:///defaultLauncherIcons/Tracker.svg";
static const QString defaultTrashEmptyIconName = "qrc:///defaultLauncherIcons/Trash.svg";

static const int HIDE_ALL     = 0;
static const int SHOW_ALL     = 1;
static const int CLOSE_ALL    = 2;

// This is a Haiku private method: must link against libtracker, but has to be declared here so compiler doesn't complain?
/*
    It's declared in headers/private/interface/WindowInfo.h and implemented in
    InterfaceDefs.cpp . Should be able to access it by just copying the
    associated declarations for now though, with the obvious caveats about
    compatibility risks of using private APIs, but until we add a public
    one for it that's unavoidable.

    Regards,

    Rene
*/
void do_bring_to_front_team(BRect zoomRect, team_id team, bool zoom);
void do_minimize_team      (BRect zoomRect, team_id app,  bool zoom);

QBeLooper::QBeLooper(MainWindow *mainWinObj)
 : BLooper("QBeLooper")
{
    theMainWindow_ = mainWinObj;
}

QBeLooper::~QBeLooper(){}

void QBeLooper::MessageReceived(BMessage *msg)
{
    // qDebug() << "QBeLooper::MessageReceived";

	switch(msg->what) {
        case M_SET_LAUNCHER_APP:
//        case M_CHANGE_LAUNCHER_ICON:
		case B_SOME_APP_QUIT:
		case B_SOME_APP_LAUNCHED:
        case B_SOME_APP_ACTIVATED:
		{
//            printf("Launched, Quit or AppActivated: Yay msg rec'd\n");
            // qDebug() << "QBeLooper::MessageReceived (B_SOME_APP_ACTIVATED)";
            theMainWindow_->MessageReceived(msg);
			break;
		}
//        case B_SIMPLE_DATA:
//        {
//            qDebug() << "QBeLooper::MessageReceived B_SIMPLE_DATA";
//            break;
//        }

		default:
        {
//            printf("Default: Yay msg rec'd\n");
			BLooper::MessageReceived(msg);
        }
	}
}


//MyHandler::MyHandler(MainWindow *mainWinObj)
// : BHandler("MyHandler")
//{
//    theMainWindow_ = mainWinObj;
//}
//
//MyHandler::~MyHandler(){}
//
//void MyHandler::MessageReceived(BMessage *msg)
//{
//
//    qDebug() << "MyHandler::MessageReceived !";
//    theMainWindow_->MessageReceived(msg);
//
//
////	switch(msg->what) {
////		case B_SOME_APP_QUIT:
////		case B_SOME_APP_LAUNCHED:
////		{
////            printf("Launched or Quit: Yay msg rec'd\n");
////            theMainWindow_->MessageReceived(msg);
////			break;
////		}
////		default:
////        {
////            printf("Default: Yay msg rec'd\n");
////			BHandler::MessageReceived(msg);
////        }
////	}
//}

MainWindow::MainWindow()
    : QMainWindow(0, Qt::FramelessWindowHint)
    //: QMainWindow()
{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

//    QFileInfo qFileInfo("/boot/home/Downloads/mcClintock/Terminal");
////    QFileInfo qFileInfo(P.Path());
//
//    QFileIconProvider iconProvider;
//    QIcon myIcon = iconProvider.icon(qFileInfo);
//
//    qDebug() << "available sizes: " << myIcon.availableSizes();
//
//    QByteArray byteArray;
//    QBuffer buffer(&byteArray);
//    buffer.open(QIODevice::WriteOnly);
//    myIcon.pixmap(QSize(32, 32), QIcon::Normal, QIcon::On).save(&buffer, "PNG");
////            myIcon.pixmap(32,32).save(&buffer, "PNG");
//    QString iconBase64 = QString(byteArray.toBase64());
//    qDebug() << "byteArray = " << byteArray;
//    qDebug() << "iconBase64 = " << QString(byteArray.toBase64());
////            qDebug() << "byteCount = " << myIcon.pixmap(32,32).byteCount();
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    mouseTrackingView_        = NULL;
    iconPickerWin_            = NULL;
    prefsDialogWin_           = NULL;
    isDockHidden_             = false;
    itemWidth                 = 36;
    minItemSize               = 16;
    maxItemSize               = 128;
    currentMagnificationIndex = 7;

    autoRaiseEnabled          = true;
    autoHideEnabled           = false;
    magnificationEnabled      = true;
    sizeSliderDragInProgress  = false;
    showRunningIndicators     = true;
    newYosemiteBottomStyle    = false;
    needsUpperRefresh         = false;
    currentDockScreenPosition = SCREEN_POSITION_BOTTOM;

    indexWhereToAddNew = INDEX_UNDEFINED;

    //not working in HAIKU
    setAcceptDrops(true);

//    qDebug() << "settings has tracker icon = " << readStringSettingsForKey(ALTERNATIVE_TRACKER_ICON_SETTINGS_KEY);
    //Static 1st cell is always Tracker (can't be removed or move its position)
//    dataList.append(createLauncherDictString(true, "application/x-vnd.Be-TRAK", "Finder.png"));

    // qDebug() << "home path is " << QDir::homePath();
	
	QString configLocation = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
	qDebug() << "Qt configLocation" << configLocation;
	
	
	// BPath path;
	status_t result = find_directory(B_USER_SETTINGS_DIRECTORY, &userSettingsPath);
	if (result == B_OK) {
		qDebug() <<  "\n\n" << "B_USER_SETTINGS_DIRECTORY" << userSettingsPath.Path() << "\n\n";
	}
	else {
		qDebug() << "Error getting B_USER_SETTINGS_DIRECTORY";
	}
	

    // QString path(QDir::homePath());
    // QDir dir(path);
    // if (!dir.exists(iconsFolder)) {
        // dir.mkpath(iconsFolder);
    // }
	
    QDir dir(userSettingsPath.Path());
    if (!dir.exists(iconsFolder)) {
        dir.mkpath(iconsFolder);
    }

	

    QString trackerStringFromSettings = readStringSettingsForKey(ALTERNATIVE_TRACKER_ICON_SETTINGS_KEY);
    QString trackerIconToLoadOnStartup;
    trackerIconToLoadOnStartup = (trackerStringFromSettings.length()>0) ? trackerStringFromSettings : defaultTrackerIconName;

    dataList.append(createLauncherDictString(true, "application/x-vnd.Be-TRAK", trackerIconToLoadOnStartup));

    // Read stored app settings and launchers:
    readSettings();

    //Static Last cell is always Trash (can't be removed or move its position)
    QString trashEmptyStringFromSettings = readStringSettingsForKey(ALTERNATIVE_TRASH_EMPTY_ICON_SETTINGS_KEY);
    QString trashEmptyStringToLoadOnStartup;
    trashEmptyStringToLoadOnStartup = (trashEmptyStringFromSettings.length()>0) ? trashEmptyStringFromSettings : defaultTrashEmptyIconName;

    dataList.append(createLauncherDictString(false, "/boot/trash", trashEmptyStringToLoadOnStartup));

    /************************************************************\

        when Haiku will support transparent windows then use:
        setAttribute(Qt::WA_TranslucentBackground, true);

        For now see paintEvent hook (over-ride) parent class method
        to draw the pixmap screen

    \*************************************************************/    

    //Take screenshot for fake transparent background
    be_app->HideCursor();
    // fullScreenShotPixmap = QPixmap();
    // //fullScreenShotPixmap = QPixmap::grabWindow( QApplication::desktop()->winId() );
    // fullScreenShotPixmap = QPixmap::grabWindow( 0 );
	
	
	screen = QGuiApplication::primaryScreen();
    if (!screen) {
        qWarning() << "No primary screen found for capture.";
        return;
    }

    // Capture the entire screen
	fullScreenShotPixmap = screen->grabWindow(0); // 0 means the root window / entire desktop
	
	
	
	
	
    
    // qDebug() << "after launch: QApplication::desktop()->winId() = " << QApplication::desktop()->winId();

    qDebug() << "after launch: fullScreenShotPixmap = " << fullScreenShotPixmap.isNull();			

    be_app->ShowCursor();

    //// view = new QDeclarativeView; //Holds the qml view
    
	//view = new QQuickView; //Holds the qml view
	
	// QQuickWidget *quickWidget = new QQuickWidget();
	view = new QQuickWidget();
	
    view->rootContext()->setContextProperty("masterAppsModel", QVariant::fromValue(dataList));
	// qDebug() << "after launch: datalist = " << QVariant::fromValue(dataList);			


    //data list keys and other constants should be known to QML:
    view->rootContext()->setContextProperty("appStringKey", appStringKey);
    view->rootContext()->setContextProperty("toolTipKey",   toolTipKey);
    view->rootContext()->setContextProperty("iconImageKey", iconImageKey);

    view->rootContext()->setContextProperty("hideAll",  HIDE_ALL);
    view->rootContext()->setContextProperty("showAll",  SHOW_ALL);
    view->rootContext()->setContextProperty("closeAll", CLOSE_ALL);

    view->rootContext()->setContextProperty("itemWidth", itemWidth);
    view->rootContext()->setContextProperty("minItemSize", minItemSize);
    view->rootContext()->setContextProperty("maxItemSize", maxItemSize);
    view->rootContext()->setContextProperty("currentMagnificationIndex", currentMagnificationIndex);
    view->rootContext()->setContextProperty("autoHideEnabled", autoHideEnabled);
    view->rootContext()->setContextProperty("magnificationEnabled", magnificationEnabled);
    view->rootContext()->setContextProperty("currentDockScreenPosition", currentDockScreenPosition);
    view->rootContext()->setContextProperty("showRunningIndicators", showRunningIndicators);
    view->rootContext()->setContextProperty("newYosemiteBottomStyle", newYosemiteBottomStyle);
    bool iconResizingInProgress = false;
    view->rootContext()->setContextProperty("iconResizingInProgress", iconResizingInProgress);

//    view->rootContext()->setContextProperty("iconPath", QDir::currentPath() + "/" + iconsFolder);
    // view->rootContext()->setContextProperty("iconPath", QDir::homePath() + "/" + iconsFolder);
	
	QString pathAsString(userSettingsPath.Path());
    view->rootContext()->setContextProperty("iconPath", pathAsString + "/" + iconsFolder);

    // double windowMaxWidth  = QApplication::desktop()->availableGeometry().width();
    // double windowMaxHeight = QApplication::desktop()->availableGeometry().height();

	//screen = QGuiApplication::primaryScreen();
	
    QRect  screenGeometry = screen->geometry();
    double windowMaxWidth = screenGeometry.width();
    double windowMaxHeight = screenGeometry.height();

    view->rootContext()->setContextProperty("windowMaxWidth", QVariant::fromValue(windowMaxWidth));
    view->rootContext()->setContextProperty("windowMaxHeight", QVariant::fromValue(windowMaxHeight));

    qDebug() << "windowMaxWidth/Height = " << windowMaxWidth << "," <<windowMaxHeight;

    //Set QML widget background to transparent
    // QPalette vPalette;
	QPalette vPalette;
    vPalette.setColor(QPalette::Base, Qt::transparent);
    view->setPalette(vPalette);

	view->setClearColor(Qt::transparent); 
    view->setAttribute(Qt::WA_TranslucentBackground);
    view->setAttribute(Qt::WA_AlwaysStackOnTop);

	
    // view->setColor(Qt::transparent);

	// vPalette.setColor(QPalette::Base, Qt::transparent);
    // view->setPalette(vPalette);
 
    view->rootContext()->setContextProperty("mainWin", this);

    // view->setSource(QUrl("qrc:///qml/MainWindow.qml"));	
	view->setSource(QUrl("qrc:///qml/MainWindow.qml"));
	
	setCentralWidget(view);
	
    
	// view->setSource("qml/MainWindow.qml");
    // view->setSource(QUrl("qrc:///qml/NewMainWindowTest.qml"));
    // view->setMinimumSize ( 5, 5 );
    // view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
	
	view->setResizeMode(QQuickWidget::SizeRootObjectToView);
	
	


    // QWidget *centralWidget = new QWidget(this);
    // view->setResizeMode(QQuickView::SizeRootObjectToView);
	// 
    // QWidget *container = QWidget::createWindowContainer(view);
    // container->setMinimumSize(view->size());
    // container->setFocusPolicy(Qt::TabFocus);
	// 
    // setCentralWidget(centralWidget);
	// 
	
    myLooper = new QBeLooper(this);

	if (myLooper) {
		myLooper->Run();

        myMessenger = new BMessenger(NULL,myLooper);

        be_roster->StartWatching(*myMessenger, B_REQUEST_LAUNCHED | B_REQUEST_QUIT | B_REQUEST_ACTIVATED);
        //be_app->StartWatchingAll(*myMessenger);
    }

    //Connect up the SLOTs for QML communication
	QObject *rootObject = view->rootObject();

    QObject::connect(this, SIGNAL(notifyAppLaunched(QVariant)), rootObject, SLOT(appLaunched_SLOT(QVariant)));
    QObject::connect(this, SIGNAL(notifyAppQuit(QVariant)), rootObject, SLOT(appQuit_SLOT(QVariant)));
    QObject::connect(this, SIGNAL(notifyDockActivated()), rootObject, SLOT(dockWasActivated_SLOT()));
    QObject::connect(this, SIGNAL(notifyDockDeactivated()), rootObject, SLOT(dockWasDeactivated_SLOT()));

    QObject::connect(this, SIGNAL(addLauncherToQML(QVariant, QVariant)), rootObject, SLOT(addLauncher_SLOT(QVariant, QVariant)));
    QObject::connect(this, SIGNAL(updateToNewIconImageForItemAt(QVariant, QVariant)), rootObject, SLOT(updateToNewIconImageForItemAt_SLOT(QVariant, QVariant)));
    QObject::connect(this, SIGNAL(updateAutoHide(QVariant)), rootObject, SLOT(updateAutoHide_SLOT(QVariant)));
    QObject::connect(this, SIGNAL(updateMagnificationEnabled(QVariant)), rootObject, SLOT(updateMagnificationEnabled_SLOT(QVariant)));
    QObject::connect(this, SIGNAL(notifyQMLValueForSizeUpdated(QVariant)), rootObject, SLOT(notifyQMLValueForSizeUpdated_SLOT(QVariant)));
    QObject::connect(this, SIGNAL(updateNewScreenPosition(QVariant)), rootObject, SLOT(updateNewScreenPosition_SLOT(QVariant)));
    QObject::connect(this, SIGNAL(notifyApplistModified()), rootObject, SLOT(notifyApplistModified_SLOT()));
}


MainWindow::~MainWindow()
{
    if (myLooper) {
		myLooper->LockLooper();
		myLooper->Quit();
	}

    if (be_roster) {
        be_roster->StopWatching(*myMessenger);
    }
}

bool MainWindow::event(QEvent *evt)
{
    switch (evt->type())
    {
        case QEvent::WindowActivate:
            //gained focus
            qDebug() << "mainWindow gained focus";
            break;
        case QEvent::WindowDeactivate:
            //lost focus
            qDebug() << "mainWindow lost focus";
//            emit notifyDockDeactivated();
//start here with check to find out if current mouse position is inside dock icons?? (not within whole window frame)
            break;
        default:
            break;
    }
    return QMainWindow::event(evt);
}

void MainWindow::showEvent(QShowEvent *event __attribute__((unused))) //suppress the unused var warning.
{
    qDebug() << "showEvent invoked";
    loadHaikuMouseTrackingView();

//    QString testUriString = getIconBase64UriForFile("/boot/home/Downloads/mcClintock/Terminal");
//    qDebug() << "testUriString = " << testUriString;

//    set up system tray icon
//    if (trayIcon == NULL)
//    {
//        trayIconMenu = new QMenu(this);
//        trayIcon = new QSystemTrayIcon(this);
//        trayIcon->setContextMenu(trayIconMenu);
//        trayIcon->setIcon(QIcon("./HiQDockIcons/Skype.png"));
//        trayIcon->show();
//    }
//    end set up system tray icon
}

void MainWindow::Activate()
{
////    qDebug() << "MainWindow::Activate";
//////    emit notifyDockActivated();
////    this->setWindowState(Qt::WindowActive);
////    this->show();
//
//    return;

    BWindow *beWin_ = be_app->WindowAt(0);

    if (beWin_ != NULL)
    {
        if (beWin_->IsMinimized())
        {


//            //--------------------
//            if (beWin_->Lock()) {
//                beWin_->Activate();
//                beWin_->MoveBy(-1200.00, -1200.00);
//                beWin_->Unlock();
//            }
//            //--------------------

            // Refresh background image when dock is surely hidden
            qDebug() << "refreshing background";
			//be_app->HideCursor();
			// fullScreenShotPixmap = QPixmap();
            // //fullScreenShotPixmap = QPixmap::grabWindow( QApplication::desktop()->winId() );
            // fullScreenShotPixmap = QPixmap::grabWindow( 0 );
			
			// QScreen *screen = QGuiApplication::primaryScreen();
			screen = QGuiApplication::primaryScreen();
			if (!screen) {
				qWarning() << "No primary screen found for capture.";
				return;
			}

			// Capture the entire screen
			fullScreenShotPixmap = screen->grabWindow(0); 			

            qDebug() << "MainWindow::Activate fullScreenShotPixmap = " << fullScreenShotPixmap.height();
            int ms = 10;
            struct timespec ts = { ms / 1000, (ms % 1000) * 1000 * 1000 };
            nanosleep(&ts, NULL);

//            //--------------------
//            if (beWin_->Lock()) {
//                beWin_->MoveBy(1200.00, 1200.00);
//                beWin_->Unlock();
//            }
//            //--------------------

            //be_app->ShowCursor();
        }

        if (!beWin_->IsActive())
        {
            emit notifyDockActivated();
//            if (beWin_->Lock()) {
                beWin_->Activate();
//                beWin_->Unlock();
//            }
        }
        else {
//            qDebug() << "calling show";
//            if (beWin_->Lock()) {
                beWin_->Activate();
                beWin_->Show();
//                beWin_->Unlock();
//            }
        }
    }
    else {
        qDebug() << "MainWindow::Activate beWin_ is NULL ?!!";
    }
}

void MainWindow::MouseOutside()
{
    emit notifyDockDeactivated();
}

int MainWindow::getCurrentDockScreenPosition()
{
    return currentDockScreenPosition;
}

void MainWindow::loadHaikuMouseTrackingView()
{
    qDebug() << "loadHaikuMouseTrackingView invoked";

//    int32 winCount = be_app->CountWindows();
//    qDebug() << "loadHaikuMouseTrackingView winCount = " << winCount;

    BWindow *beWin_ = be_app->WindowAt(0);

    if (beWin_ == NULL)
    {
        beWin_ = be_app->WindowAt(0);
    }

    if (beWin_ && mouseTrackingView_ == NULL)
    {
//        printf("win 0 is there!\n");
        qDebug() << "win 0 is there!" << beWin_->Title();
//        theWin->StartWatchingAll(be_app_messenger);
//        printf("b4 adding mouseTrackingView_ view\n");
//        mouseTrackingView_ = new HaikuMouseTrackingView(BRect(0,0, 300, 300), this);
        mouseTrackingView_ = new HaikuMouseTrackingView(BRect(0,0, size().width(), size().height()), this);
        mouseTrackingView_->SetEventMask(B_POINTER_EVENTS, B_NO_POINTER_HISTORY);
        beWin_->AddChild(mouseTrackingView_);
        mouseTrackingView_->Show();
//        printf("added mouseTrackingView_ view\n");
        qDebug() << mouseTrackingView_;
    }
    else
    {
        qDebug() << "win not accessible: mouseTrackingView_ = " << mouseTrackingView_;
    }
}

void MainWindow::paintEvent(QPaintEvent *pe)
{
    QPainter *pPainter = new QPainter(this);

    //Original lowerRect
    QRect newRect(-pos().x(), -pos().y(), fullScreenShotPixmap.size().width(), fullScreenShotPixmap.size().height());
    pPainter->drawPixmap(newRect, fullScreenShotPixmap);

////    if (needsUpperRefresh) {
//        //Draws a second pixmap above the original screen shot to "update the area above the dock" trick?
//        //QPixmap newScreenShotPixmap = QPixmap::grabWindow( QApplication::desktop()->winId() );
//        //QPixmap croppedScreenShot = newScreenShotPixmap.copy(0,0,newScreenShotPixmap.size().width(), newScreenShotPixmap.size().height()-60);
//        //QRect croppedRect(-pos().x(), -pos().y(), croppedScreenShot.size().width(), croppedScreenShot.size().height());
//        //pPainter->drawPixmap(croppedRect, croppedScreenShot);
//
//        QRect croppedRect(-pos().x(), -pos().y(), upperScreenShotPixmap.size().width(), upperScreenShotPixmap.size().height());
//        pPainter->drawPixmap(croppedRect, upperScreenShotPixmap);
////        needsUpperRefresh = false;
////    }

    delete pPainter;
    QWidget::paintEvent(pe);
}

//void MainWindow::TakeUpperScreenShot()
//{
//    QPixmap newScreenShotPixmap = QPixmap::grabWindow( QApplication::desktop()->winId());
//    upperScreenShotPixmap = newScreenShotPixmap.copy(0,0,newScreenShotPixmap.size().width(), newScreenShotPixmap.size().height()-60);
//    qDebug() << "just took upper screenshot";
////    needsUpperRefresh = true;
//}

//void MainWindow::refreshBackground()
//{
//    QTimer::singleShot(2000, this, SLOT(TakeUpperScreenShot()));
//}

void MainWindow::dropEvent(QDropEvent *event)
{
    event->acceptProposedAction();
    qDebug() << "drop event !";
}

void MainWindow::itemRemoved(int indexRemoved)
{
    qDebug() << "got request to remove item at: " << indexRemoved;
    dataList.removeAt(indexRemoved);
    view->rootContext()->setContextProperty("masterAppsModel", QVariant::fromValue(dataList));
    writeSettings();
}

void MainWindow::initFilePanels(uint32 messageName)
{
	static bool InitOk;
	entry_ref Ref;

	if (!InitOk) {
		BMessage Msg(M_SET_LAUNCHER_APP);
		fPanelOpen = new BFilePanel(B_OPEN_PANEL, myMessenger, NULL /*Panel directory*/, B_ANY_NODE/*B_FILE_NODE*/ /*node_flavors*/, false /*mult.sele.*/, &Msg);
		InitOk = true;
	}

/*    if  (messageName == M_CHANGE_LAUNCHER_ICON)
    {
        BMessage ChangIconMsg(M_CHANGE_LAUNCHER_ICON);
        fPanelOpen->SetMessage(&ChangIconMsg);
        fPanelOpen->Window()->SetTitle("Select Image File to Use for this Item On Dock");
        fPanelOpen->SetButtonLabel(B_DEFAULT_BUTTON, "Select this Image");
        fPanelOpen->Refresh();
    }
    else*/
    if  (messageName == M_SET_LAUNCHER_APP)
    {
        qDebug() << "set panel to be an Add launcher panel";
        BMessage AddLauncherMsg(M_SET_LAUNCHER_APP);
        fPanelOpen->SetMessage(&AddLauncherMsg);
		fPanelOpen->Window()->SetTitle("Select New Application or Folder to add to Dock");
		fPanelOpen->SetButtonLabel(B_DEFAULT_BUTTON, "Select this App or Folder");
        fPanelOpen->Refresh();
    }
}

void MainWindow::setIconImageForItemAt(int indexOfItem)
{
    qDebug() << "got request to change iconImage for item at %d \n\n" << indexOfItem;
    indexWhereToAddNew = indexOfItem;

//OLD
//  initFilePanels(M_CHANGE_LAUNCHER_ICON);
//	fPanelOpen->Show();
//NEW

    // QDeclarativeView *pickerView = NULL;
    // QQuickView *pickerView = NULL;

    if (iconPickerWin_ != NULL)
    {
        // // pickerView = dynamic_cast<QDeclarativeView*>(iconPickerWin_->centralWidget());
        // pickerView = dynamic_cast<QQuickView*>(iconPickerWin_->centralWidget());

        pickerView->rootContext()->setContextProperty("launcherToolTip", getStringValueFromJSON(toolTipKey, dataList.at(indexOfItem)));
        pickerView->rootContext()->setContextProperty("originalIconImageSource", getIconBase64UriForFile(getStringValueFromJSON(appStringKey, dataList.at(indexOfItem))));
        QRect pickWinRect = iconPickerWin_->geometry();
		
		QRect screenGeometry = screen->availableGeometry();
		QPoint center = screenGeometry.center();
		
        // pickWinRect.moveCenter(QApplication::desktop()->availableGeometry().center());
        pickWinRect.moveCenter(center);	
        iconPickerWin_->setGeometry(pickWinRect);
        iconPickerWin_->show();
        return;
    }

    iconPickerWin_ = new HQDDialogWindow();
    // iconPickerWin_ = new HQDDialogWindow(0, /*Qt::SubWindow*/Qt::Tool);
    iconPickerWin_->setWindowTitle("HiQDock - Set New Icon");
    // iconPickerWin_->setAttribute(Qt::WA_DeleteOnClose);

// //    QDeclarativeView *pickerView = new QDeclarativeView;
//     pickerView = new QDeclarativeView;
    pickerView = new QQuickView;


//    qDebug() << "QDir::currentPath() + / iconsFolder =  " << QDir::homePath() << "/" << iconsFolder;



	QString pathAsString(userSettingsPath.Path()); 

//    pickerView->rootContext()->setContextProperty("iconPickerInitialFolder", QDir::currentPath() + "/" + iconsFolder);
    pickerView->rootContext()->setContextProperty("userSettingsPath", pathAsString);
    pickerView->rootContext()->setContextProperty("iconPickerInitialFolder", pathAsString + "/" + iconsFolder);
    pickerView->rootContext()->setContextProperty("launcherToolTip", getStringValueFromJSON(toolTipKey, dataList.at(indexOfItem)));
    pickerView->rootContext()->setContextProperty("originalIconImageSource", getIconBase64UriForFile(getStringValueFromJSON(appStringKey, dataList.at(indexOfItem))));

    pickerView->setSource(QUrl("qrc:///qml/IconPicker.qml"));
    // pickerView->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    pickerView->setResizeMode(QQuickView::SizeRootObjectToView);

    QObject *rootObject = dynamic_cast<QObject*>(pickerView->rootObject());
    QObject::connect(rootObject, SIGNAL(iconSelected(QString)), this, SLOT(notifyIconPicked(QString)));
    QObject::connect(iconPickerWin_, SIGNAL(windowWillClose(QString)), this, SLOT(notifyIconPicked(QString)));

	QWidget *container = QWidget::createWindowContainer(pickerView);

    // iconPickerWin_->setCentralWidget(pickerView);
    iconPickerWin_->setCentralWidget(container);
    iconPickerWin_->setWindowModality(Qt::ApplicationModal);
	
	QRect availGeom = screen->availableGeometry();

    // int padding = QApplication::desktop()->availableGeometry().width() * 0.25;
    int padding = availGeom.width() * 0.25;
    // iconPickerWin_->setMinimumSize(QApplication::desktop()->availableGeometry().width() - padding, QApplication::desktop()->availableGeometry().height() - padding);
    // iconPickerWin_->setMaximumSize(QApplication::desktop()->availableGeometry().width() - padding, QApplication::desktop()->availableGeometry().height() - padding);
    // QRect pickWinRect = iconPickerWin_->geometry();
    // pickWinRect.moveCenter(QApplication::desktop()->availableGeometry().center());
    // iconPickerWin_->setGeometry(pickWinRect);
	
    iconPickerWin_->setMinimumSize(availGeom.width() - padding, availGeom.height() - padding);
 //    iconPickerWin_->setMaximumSize(availGeom.width() - padding, availGeom.height() - padding);
    QRect pickWinRect = iconPickerWin_->geometry();
    pickWinRect.moveCenter(availGeom.center());
    iconPickerWin_->setGeometry(pickWinRect);

// 
    iconPickerWin_->show();
}

void MainWindow::notifyIconPicked(const QString &pathToIconImageFile)
{
    qDebug() << "MainWindow::notifyIconPicked = " << pathToIconImageFile;
    if (iconPickerWin_ != NULL)
    {
        iconPickerWin_->hide();
    }

//    if (pathToIconImageFile.length() > 0)
//    {
        emit updateToNewIconImageForItemAt(QVariant(pathToIconImageFile), QVariant(indexWhereToAddNew));
        indexWhereToAddNew = INDEX_UNDEFINED;
//    }
    writeSettings();
}

//void MainWindow::notifyIconPickerWindowDestroyed()
//{
//    qDebug() << "notifyIconPickerWindowDestroyed";
//}

void MainWindow::updateIconImageInMasterListForItemAt(int indexOfItem, const QString &jsonString)
{
    qDebug() << "new icon file name to add to masterAppsModel list = " + jsonString;
    dataList[indexOfItem] = jsonString;
    view->rootContext()->setContextProperty("masterAppsModel", QVariant::fromValue(dataList));
    // emit notifyApplistModified();
    writeSettings();
}

void MainWindow::addNewItemAt(int indexToAddNewItem)
{
    qDebug() << "got request to add new item at: " << indexToAddNewItem;
    indexWhereToAddNew = indexToAddNewItem;

/*-----------------------------------------------------------------------------------\\
    This is crashing after selecting the file;
    Therefore I decided to implement a complete native BFilePanel and it's working
    instead of this:

    QString filename = QFileDialog::getOpenFileName(this, tr("Select New App or Folder to Add"), "/boot", tr("Application Files (*.*)"));
	if ( !filename.isEmpty() )
    {
        qDebug() << "filename selected = " + filename;
    }

    //then it crashes!!!

\\-----------------------------------------------------------------------------------*/

	initFilePanels(M_SET_LAUNCHER_APP);
	fPanelOpen->Show();
}


bool MainWindow::isAppRunning(const QString &appSignatureString)
{
    BList *teams = new BList;
    be_roster->GetAppList(appSignatureString.toLatin1().data(), teams);

    // qDebug() << "isAppRunning called - list count = " << teams->CountItems();

    return (teams->CountItems() > 0);
}

bool MainWindow::isMultiLaunch(const QString &appSignatureString)
{
    app_info theInfo;
    be_roster->GetAppInfo(appSignatureString.toLatin1().data(), &theInfo);

    uint32 behavior = theInfo.flags & B_LAUNCH_MASK;

    return behavior & B_MULTIPLE_LAUNCH;
}

int MainWindow::moveItems(int fromIndex, int toIndex)
{
    qDebug() << "got request to move from: " << fromIndex << " to index: " << toIndex;
    dataList.move(fromIndex, toIndex);
    view->rootContext()->setContextProperty("masterAppsModel", QVariant::fromValue(dataList));
    writeSettings();
    emit notifyApplistModified();
    return fromIndex*toIndex;
}

void MainWindow::openFolder(const QString &folderPath) {

    std::string cmd = "/bin/open '";

    BPath P(folderPath.toLatin1().data());
    if (P.InitCheck() != B_OK) {
        qDebug() << "couldn't open" << folderPath.toLatin1().data();
        return;
    }

    cmd += P.Path();

    cmd += "'";
    system(cmd.c_str());
}

void MainWindow::launch(const QString &appSignatureString)
{
    qDebug() << "got request to launch " + appSignatureString + "<->" + appSignatureString.toLatin1().data(); //name;
    status_t stat = B_NO_INIT;

    stat = be_roster->Launch(appSignatureString.toLatin1().data()/*, &ref */);
	
	if (stat == B_OK) {
		qDebug() << "launched: " << appSignatureString;
	}
}

void MainWindow::notifyInsideDock(bool isInside)
{

    BWindow *beWin_ = be_app->WindowAt(0);

    qDebug() << "MainWindow::notifyInsideDock = " << isInside;
    qDebug() << "MainWindow::notifyInsideDock beWin_ = " << beWin_;
//    QThread::msleep(500);
    int ms = 10;
    struct timespec ts = { ms / 1000, (ms % 1000) * 1000 * 1000 };
    nanosleep(&ts, NULL);

    //Auto-raise
    if (isInside)
    {
//        if (beWin_->Lock()) {
            beWin_->Activate();
//            beWin_->Unlock();
//        }
//        show();
    }
    else
    {
        if (!autoHideEnabled)
        {
            beWin_->SendBehind(NULL);
/*
            if (beWin_->Lock()) {
                qDebug() << "MainWindow::notifyInsideDock locked worked = ";

                status_t stat = beWin_->SendBehind(NULL);
                if  (stat == B_OK) {
                    qDebug() << "MainWindow::notifyInsideDock SendBehind worked";
                }
                else {
                    qDebug() << "MainWindow::notifyInsideDock SendBehind FAILED";
                }
                beWin_->Unlock();
            }
            else  {
                qDebug() << "MainWindow::notifyInsideDock locked FAILED" << ", beWin_" << beWin_;
                status_t stat = beWin_->SendBehind(NULL);
                if  (stat == B_OK) {
                    qDebug() << "MainWindow::notifyInsideDock without lock SendBehind worked";
                }
                else {
                    qDebug() << "MainWindow::notifyInsideDock without lock SendBehind FAILED";
                }
            }
*/
        }
//        else
//          beWin_->Minimize(true);
//        refreshBackground();
    }
}

//void MainWindow::notifyInsideDock(bool isInside)
//{
//    qDebug() << "MainWindow::notifyInsideDock = " << isInside;
////    QThread::msleep(500);
//    int ms = 10;
//    struct timespec ts = { ms / 1000, (ms % 1000) * 1000 * 1000 };
//    nanosleep(&ts, NULL);
//
//    //Auto-raise
//    if (isInside)
//    {
//        this->setWindowState(this->windowState() & ~Qt::WindowMinimized | Qt::WindowActive);
//        //        show();
//    }
//    else
//    {
//        if (!autoHideEnabled)
//        {
//            beWin_->SendBehind(NULL);
//        }
////        else
////          beWin_->Minimize(true);
////        refreshBackground();
//    }
//}

void MainWindow::notifyDockHidden(bool showingState)
{
    isDockHidden_ = !showingState;
//    if (autoHideEnabled && isDockHidden_)

//    BLooper *looperTrayIcon = dynamic_cast<BLooper*>(trayIcon);

    BWindow *beWin_ = be_app->WindowAt(0);

    if (isDockHidden_)
    {
////        looperTrayIcon->LockLooper();
//
//        if (beWin_->Lock()) {
            beWin_->Minimize(true);
//            beWin_->Unlock();
//        }
//
////        looperTrayIcon->UnlockLooper();
//        this->setWindowState(Qt::WindowMinimized);

////        if (beWin_->Lock()) {
//            if (myLooper->LockLooper()) {
//
//
//            beWin_->Minimize(true);
////            beWin_->Unlock();
//            myLooper->UnlockLooper();
//        }
    }
}

//void MainWindow::notifyDockHidden(bool showingState)
//{
//    isDockHidden_ = !showingState;
////    if (autoHideEnabled && isDockHidden_)
//
////    BLooper *looperTrayIcon = dynamic_cast<BLooper*>(trayIcon);
//    if (isDockHidden_)
//    {
//        this->setWindowState(Qt::WindowMinimized);
//    }
//}

void MainWindow::notifySetAutoHide(bool onOff)
{
    autoHideEnabled = onOff;
    view->rootContext()->setContextProperty("autoHideEnabled", autoHideEnabled);
    emit updateAutoHide(autoHideEnabled);

//    emit notifyDockActivated();
    writeSettings();
}


void MainWindow::notifySetMagnificationEnabled(bool enable)
{
    magnificationEnabled = enable;
    view->rootContext()->setContextProperty("magnificationEnabled", magnificationEnabled);
    emit updateMagnificationEnabled(enable);
    writeSettings();
}

void MainWindow::notifyUseNewYosemiteBottomStyle(bool useNewStyleOnBottom)
{
    newYosemiteBottomStyle = useNewStyleOnBottom;
    view->rootContext()->setContextProperty("newYosemiteBottomStyle", newYosemiteBottomStyle);
    writeSettings();
}

void MainWindow::showPreferencesDialog()
{
    if (prefsDialogWin_ != NULL)
    {
        QRect prefWinRect = prefsDialogWin_->geometry();
		QRect availGeom = screen->availableGeometry();
        prefWinRect.moveCenter(availGeom.center());
        prefsDialogWin_->setGeometry(prefWinRect);
        prefsDialogWin_->show();
        prefsDialogWin_->activateWindow();
        return;
    }

    prefsDialogWin_ = new QMainWindow(0, /*Qt::SubWindow*/Qt::Tool);
    prefsDialogWin_->setWindowTitle("HiQDock Options");
    // QDeclarativeView *prefsView = new QDeclarativeView;
    QQuickView *prefsView = new QQuickView;

    prefsView->rootContext()->setContextProperty("currentDockScreenPosition", currentDockScreenPosition);
    prefsView->rootContext()->setContextProperty("magnificationEnabled", magnificationEnabled);
    prefsView->rootContext()->setContextProperty("autoHideEnabled", autoHideEnabled);
    prefsView->rootContext()->setContextProperty("showRunningIndicators", showRunningIndicators);
    prefsView->rootContext()->setContextProperty("newYosemiteBottomStyle", newYosemiteBottomStyle);
    prefsView->rootContext()->setContextProperty("itemWidth", itemWidth);
    prefsView->rootContext()->setContextProperty("minItemSize", minItemSize);
    prefsView->rootContext()->setContextProperty("maxItemSize", maxItemSize);
    prefsView->rootContext()->setContextProperty("currentMagnificationIndex", currentMagnificationIndex);

    prefsView->setSource(QUrl("qrc:///qml/HiQDockPreferences/HiQDockPreferences.qml"));
    // prefsView->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    prefsView->setResizeMode(QQuickView::SizeRootObjectToView);

    QObject *rootObject = dynamic_cast<QObject*>(prefsView->rootObject());

    QObject::connect(rootObject, SIGNAL(showHideRunningIndicators(bool)), this, SLOT(notifyShowRunningIndicators(bool)));
    QObject::connect(rootObject, SIGNAL(setAutoHide(bool)), this, SLOT(notifySetAutoHide(bool)));
    QObject::connect(rootObject, SIGNAL(setMagnificationEnabled(bool)), this, SLOT(notifySetMagnificationEnabled(bool)));
    QObject::connect(rootObject, SIGNAL(useNewYosemiteBottomStyle(bool)), this, SLOT(notifyUseNewYosemiteBottomStyle(bool)));
    QObject::connect(rootObject, SIGNAL(sizeDraggingInProgress(bool)), this, SLOT(notifySizeDraggingInProgress(bool)));
    QObject::connect(rootObject, SIGNAL(valueForSizeUpdated(double)), this, SLOT(notifyValueForSizeUpdated(double)));
    QObject::connect(rootObject, SIGNAL(valueForMagnificationUpdated(double)), this, SLOT(notifyValueForMagnificationUpdated(double)));
    QObject::connect(rootObject, SIGNAL(setNewScreenPosition(int)), this, SLOT(notifySetNewScreenPosition(int)));


	QWidget *container = QWidget::createWindowContainer(prefsView);
    // prefsDialogWin_->setCentralWidget(prefsView);
    prefsDialogWin_->setCentralWidget(container);
    prefsDialogWin_->setWindowModality(Qt::WindowModal);


    prefsDialogWin_->show();

    QRect prefWinRect = prefsDialogWin_->geometry();
	QRect availGeom = screen->availableGeometry();
    // prefWinRect.moveCenter(QApplication::desktop()->availableGeometry().center());
    prefWinRect.moveCenter(availGeom.center());
    prefsDialogWin_->setGeometry(prefWinRect);

    BWindow *prefsBWindow = dynamic_cast<BWindow*>(prefsDialogWin_);
//    prefsBWindow->SetFlags(B_NOT_RESIZABLE);
    prefsBWindow->SetLook(B_MODAL_WINDOW_LOOK);
}

void MainWindow::notifyValueForMagnificationUpdated(double percent)
{
    if (!magnificationEnabled) {
        return;
    }

    int proposedNewIndex = int(percent*9);

    if (proposedNewIndex == currentMagnificationIndex) {
        return;
    }

    qDebug() << "notifyValueForMagnificationUpdated: " << percent;
//    currentMagnificationIndex = int(percent*9);
    currentMagnificationIndex = proposedNewIndex;
    qDebug() << "currentMagnificationIndex will be = " << currentMagnificationIndex;
    view->rootContext()->setContextProperty("currentMagnificationIndex", currentMagnificationIndex);
    //now because new need to re-trigger "calculateTotalWidthNeeded();"
    view->rootContext()->setContextProperty("magnificationEnabled", magnificationEnabled);
    emit updateMagnificationEnabled(magnificationEnabled);
    writeSettings();
}

void MainWindow::notifyValueForSizeUpdated(double percent)
{
    qDebug() << "notifyValueForSizeUpdated: " << percent;
    emit notifyQMLValueForSizeUpdated(percent);
}

void MainWindow::notifySizeDraggingInProgress(bool isDragging)
{
    qDebug() << "notifySizeDraggingInProgress: " << isDragging;
    sizeSliderDragInProgress = isDragging;
    view->rootContext()->setContextProperty("iconResizingInProgress", isDragging);
}

void MainWindow::notifyShowRunningIndicators(bool show)
{
    qDebug() << "notifyShowRunningIndicators: " << show;
    showRunningIndicators = show;
    view->rootContext()->setContextProperty("showRunningIndicators", showRunningIndicators);
    writeSettings();
}

bool MainWindow::isOrientationChanging(int newPosition)
{
    if ((currentDockScreenPosition == SCREEN_POSITION_LEFT) || (currentDockScreenPosition == SCREEN_POSITION_RIGHT)) {
        return ((newPosition == SCREEN_POSITION_BOTTOM) || (newPosition == SCREEN_POSITION_TOP));
    }
    else { //it's currently on top or bottom
        return ((newPosition == SCREEN_POSITION_LEFT) || (newPosition == SCREEN_POSITION_RIGHT));
    }
}

void MainWindow::notifySetNewScreenPosition(int newPosition)
{
    qDebug() << "notifySetNewScreenPosition: " << newPosition;
    bool orientationWillChange = isOrientationChanging(newPosition);
    currentDockScreenPosition = newPosition;
    view->rootContext()->setContextProperty("currentDockScreenPosition", currentDockScreenPosition);
    emit updateNewScreenPosition(newPosition);

    if (orientationWillChange) {
        qDebug() << "going to flip resize window: h x w" << size().height() << "x" << size().width();
        resize( QSize( size().height(), size().width() ) );
        BWindow *beWin_ = be_app->WindowAt(0);
        if (beWin_ == NULL)
        {
            beWin_ = be_app->WindowAt(0);
        }
        beWin_->ResizeTo(size().height(), size().width());
    }
    else {
        qDebug() << "NOT resizing window!";
    }

    moveScreenToPosition(currentDockScreenPosition);

    writeSettings();
}

void MainWindow::moveScreenToPosition(int newPosition)
{
    // QRect screenRect = QApplication::desktop()->screenGeometry();
	QRect screenRect = screen->availableGeometry();

    //@TODO: Haiku screen geometry is off by 1 pixel I think so need to add 1 to width and height
    QSize screenSize(screenRect.width() + 1, screenRect.height() + 1);
    ///////////////////////////////////////////////////////////////////

    BWindow *beWin_ = be_app->WindowAt(0);
    // if (beWin_ == NULL)
    // {
    //     beWin_ = be_app->WindowAt(0);
    // }

    switch ( newPosition )
	{
        case SCREEN_POSITION_LEFT:
            qDebug() << "moveScreenToPosition: SCREEN_POSITION_LEFT";
            move(   QPoint(0, (screenSize.height()  - size().height())/2) );
            beWin_->MoveTo(0, (screenSize.height()  - size().height())/2);
			break;
        case SCREEN_POSITION_BOTTOM:
            qDebug() << "moveScreenToPosition: SCREEN_POSITION_BOTTOM";
            move(   QPoint((screenSize.width() - size().width())/2,  screenSize.height()  - size().height()) );
            beWin_->MoveTo((screenSize.width() - size().width())/2,  screenSize.height()  - size().height()) ;
            break;
        case SCREEN_POSITION_RIGHT:
            qDebug() << "moveScreenToPosition: SCREEN_POSITION_RIGHT";
            move(   QPoint(screenSize.width() - size().width(), (screenSize.height() - size().height())/2) );
            beWin_->MoveTo( screenSize.width() - size().width(), (screenSize.height() - size().height())/2) ;
            break;
        case SCREEN_POSITION_TOP:
            qDebug() << "moveScreenToPosition: SCREEN_POSITION_TOP";
            move(   QPoint((screenSize.width() - size().width())/2, 0) );
            beWin_->MoveTo((screenSize.width() - size().width())/2, 0) ;
            break;
        default:
            qDebug() << "moveScreenToPosition: how did we get here? screen position not recognized";
            break;
    }

        beWin_->Activate();
}

void MainWindow::notifyNewItemWidth(int newItemWidth)
{
    qDebug() << "notifyNewItemWidth: got request to change icon size to new width = " << newItemWidth;
    itemWidth = newItemWidth;
    view->rootContext()->setContextProperty("itemWidth", itemWidth);
    writeSettings();
}

void MainWindow::notifyWidthChanged(int newWidth)
{
    qDebug() << "notifyWidthChanged: got request to resize to new width = " << newWidth;

    if ((currentDockScreenPosition == SCREEN_POSITION_LEFT) || (currentDockScreenPosition == SCREEN_POSITION_RIGHT))
    {
        if (!sizeSliderDragInProgress && (newWidth <= size().width()))
        {
            qDebug() << "notifyWidthChanged - not resizing or moving window size().width() = " << size().width();

            return;
        }
    }

    BWindow *beWin_ = be_app->WindowAt(0);
    // if (beWin_ == NULL)
    // {
    //     beWin_ = be_app->WindowAt(0);
    // }
    beWin_->ResizeTo(newWidth, size().height());
    resize( QSize( newWidth, size().height() ) );
    moveScreenToPosition(currentDockScreenPosition);
}

void MainWindow::notifyHeightChanged(int newHeight)
{
    qDebug() << "notifyHeightChanged: got request to resize to new height = " << newHeight;

    if (newHeight > size().height())
    {
        qDebug() << "notifyHeightChanged - resizing to w:" << size().width() << "x" << newHeight;

        resize( QSize( size().width(), newHeight) );
        moveScreenToPosition(currentDockScreenPosition);
    }
    else
    {
        qDebug() << "notifyHeightChanged - not resizing or moving window, " << size().height() << " == " << newHeight;

        //=====
        /***** I don't understand this bug :) but this problem only happens when Dock is on right side :)"*/
        if (currentDockScreenPosition == SCREEN_POSITION_RIGHT) {
            resize( QSize( size().width()+1, size().height()+1) );
            resize( QSize( size().width()-1, size().height()-1) );
            moveScreenToPosition(currentDockScreenPosition);
        }
        //=====

    }
}

//void 
//MainWindow::RefsReceived(BMessage* message)
//{}

void MainWindow::setNewApp(BMessage *message, uint32 messageName __attribute__((unused))) //suppress the unused var warning.
{
    entry_ref ref;
    if (message->FindRef("refs", 0, &ref) == B_OK) {
        BEntry E(&ref, TRUE);
        if (E.Exists()) {
            BPath P;
            E.GetPath(&P);
            //printf("P.Path() is: %s\n", P.Path());

            BFile beFileObj(&ref, 0);
            BAppFileInfo fileInfo(&beFileObj);

//            if (messageName == M_CHANGE_LAUNCHER_ICON)
//            {
//                printf("will change to the requested icon: %s\n", P.Path());
//                emit updateToNewIconImageForItemAt(QVariant(P.Path()), QVariant(indexWhereToAddNew));
//                indexWhereToAddNew = INDEX_UNDEFINED;
//                return;
//            }

            char *fileType = new char[B_MIME_TYPE_LENGTH];
            fileInfo.GetType(fileType);
//            printf("type is: %s\n", fileType);

            char *appSig = new char[B_MIME_TYPE_LENGTH];
            status_t stat = fileInfo.GetSignature(appSig);

            //to check if it's an app check if fileTyp B_APP_MIME_TYPE
            //see: boot/develop/headers/os/storage/MimeType.h

//            extern const char *B_PEF_APP_MIME_TYPE;	// "application/x-be-executable"
//            extern const char *B_PE_APP_MIME_TYPE;	// "application/x-vnd.be-peexecutable"
//            extern const char *B_ELF_APP_MIME_TYPE;	// "application/x-vnd.be-elfexecutable"

            QString appFileOrDir;

            if  (stat == B_OK)
            {
//                printf("appSig is: %s\n", appSig);
                appFileOrDir = QString(appSig);
            }
            else
            {
//                printf("this doesn't have an app sig\n");
                appFileOrDir = QString(P.Path());
                qDebug() << "appFileOrDir = " << appFileOrDir;
            }

            //check if app or whatever it is already exists:
            for (int i = 0; i < dataList.count() ; ++i)
            {
                QString oneLauncherJSONDataString = getStringValueFromJSON(appStringKey, dataList.at(i));
                qDebug() << "dataList.at(" << i << ") = " << oneLauncherJSONDataString << " -vs- " << appFileOrDir;

                if (oneLauncherJSONDataString == appFileOrDir)
                {
                    qDebug() << "that app already exists in the dock!";
                    indexWhereToAddNew = INDEX_UNDEFINED;
                    QMessageBox alertBox;
                    alertBox.setText("\"" + appFileOrDir + "\" already exists in the dock!");
                    alertBox.setIcon(QMessageBox::Warning);
                    alertBox.setModal(true);
                    alertBox.exec();
                    return;
                }
            }

            QString jsonString = createLauncherDictString((stat == B_OK), appFileOrDir, "");

            emit addLauncherToQML(jsonString, QVariant(indexWhereToAddNew));
            dataList.insert(indexWhereToAddNew, jsonString);

//            printf("after insert now dataList is:\n\n");
//            qDebug() << dataList << "\n\n";

            writeSettings();
            indexWhereToAddNew = INDEX_UNDEFINED;
        }
    }
}


void MainWindow::hideShowQuitApp(const QString &appSignatureString, int hideShowOrQuit) //void MainWindow::hideShowQuitApp(qint64 teamId, int hideShowOrQuit)
{
    qDebug() << "hideShowQuitApp: appSignatureString is: " << appSignatureString << "; task to do is: " << hideShowOrQuit;

//OLD
//    switch ( hideShowOrQuit )
//	{
//        case HIDE_ALL:
//			printf("hide all\n");
//			do_minimize_team(BRect(0,0,1280,1024), (qint64)teamId, true);
//			break;
//
//		case SHOW_ALL:
//			printf("show all\n");
//			do_bring_to_front_team(BRect(0,0,1280,1024), (qint64)teamId, true);
//          be_roster->ActivateApp((qint64)teamId);
//			break;
//
//		case CLOSE_ALL:
//			{
//				printf("close all\n");
//				BMessenger messenger((char*)NULL, (qint64)teamId);
//				uint32 command = B_QUIT_REQUESTED;
//				app_info aInfo;
//				be_roster->GetRunningAppInfo((qint64)teamId, &aInfo);
//
//				if (strcasecmp(aInfo.signature, /*kTrackerSignature*/ "application/x-vnd.Be-TRAK") == 0)
//					command = 'Tall';
//
//				messenger.SendMessage(command);
//				break;
//			}
//        default:
//            break;
//    }
//NEW

    BList *teams = new BList;
    be_roster->GetAppList(appSignatureString.toLatin1().data(), teams);

    switch ( hideShowOrQuit )
	{
        case HIDE_ALL:
			qDebug() << "hide all";
            for (int i = 0; i < teams->CountItems(); ++i)
            {
                qint64 teamId = (qint64)teams->ItemAt(i);
                do_minimize_team(BRect(0,0,1280,1024), teamId, true);
            }
			break;

		case SHOW_ALL:
			qDebug() << "show all";
            for (int i = 0; i < teams->CountItems(); ++i)
            {
                qint64 teamId = (qint64)teams->ItemAt(i);
                do_bring_to_front_team(BRect(0,0,1280,1024), teamId, true);
                be_roster->ActivateApp(teamId);
            }
			break;

		case CLOSE_ALL:
			{
				qDebug() << "close all";
                for (int i = 0; i < teams->CountItems(); ++i)
                {
                    qint64 teamId = (qint64)teams->ItemAt(i);
                    BMessenger messenger((char*)NULL, teamId);
                    uint32 command = B_QUIT_REQUESTED;
                    app_info aInfo;
                    be_roster->GetRunningAppInfo(teamId, &aInfo);

                    if (strcasecmp(aInfo.signature, /*kTrackerSignature*/ "application/x-vnd.Be-TRAK") == 0) {
                        command = 'Tall';
                    }

                    messenger.SendMessage(command);
                }

				break;
			}
        default:
            break;
    }


//    qDebug() << "isAppRunning called - list count = " << teams->CountItems();//int32 CountItems() const;
//
//    return (teams->CountItems() > 0);
}


void MainWindow::openParentFolder(const QString &appSignatureString)
{
    qDebug() << "got request to openParentFolder for: " + appSignatureString;

    entry_ref ref;
    status_t stat = be_roster->FindApp(appSignatureString.toLatin1().data(), &ref);

    std::string cmd = "/bin/open '";

    if (stat == B_OK)
    {
        BEntry myBEntry(&ref, TRUE);
        myBEntry.GetParent(&myBEntry);
        BPath P;
        myBEntry.GetPath(&P);
        qDebug() << "P.Path() is:" << QString(P.Path());

        // system("/bin/open '/boot/home/Desktop'");
        // std::string cmd = "/bin/open '";
        cmd += P.Path();
    }
    else //probably not an app but a regular file or directory
    {
        BPath P(appSignatureString.toLatin1().data());
        if (P.InitCheck() != B_OK) {
            qDebug() << "couldn't open" << appSignatureString.toLatin1().data();
            return;
        }

        cmd += P.Path();
    }

    cmd += "'";
    system(cmd.c_str());
}

void MainWindow::MessageReceived (BMessage *message)
{
    //printf("MainWindow::MessageReceived message-->\n");

    const char* appSignatureString = NULL;

	switch (message->what) {
		case B_SOME_APP_LAUNCHED:
		{
			//printf("At MainWin app was launched mssg\n");
//			const char* appSignatureString = NULL;
			message->FindString("be:signature", &appSignatureString);
//			printf("app launched: %s\n", appSignatureString);

//            team_id team = -1;
//            message->FindInt32("be:team", &team);
//            printf("app launched team id = %lu\n", team);

            QString appSigQString(appSignatureString);
//            emit notifyAppLaunched(QVariant(appSigQString), QVariant((qint64)team));
            emit notifyAppLaunched(QVariant(appSigQString));

			break;
		}

		case B_SOME_APP_QUIT:
		{
//			team_id team = -1;
//			message->FindInt32("be:team", &team);
//			printf("app quit: %lu\n", team);
//            emit notifyAppQuit(QVariant((qint64)team));

            message->FindString("be:signature", &appSignatureString);
//			printf("\napp Quit: %s\n", appSignatureString);
            QString appSigQString(appSignatureString);
            emit notifyAppQuit(QVariant(appSigQString));

			break;
		}

        case B_SOME_APP_ACTIVATED:
        {
//            const char* appSignatureString = NULL;
			message->FindString("be:signature", &appSignatureString);
//			printf("\napp activated: %s\n", appSignatureString);

//            bool isAppActivatedHiQDock = (strcasecmp(appSignatureString, "application/x-vnd.HiQDock") == 0);
//
//            if (!isAppActivatedHiQDock && beWin_->IsMinimized())
//            {
//                // Refresh background image when dock is surely hidden and some app is activated
//                printf("\nrefreshing background\n");
//                pixmap = QPixmap::grabWindow( QApplication::desktop()->winId() );
//            }

			break;
		}

        case M_SET_LAUNCHER_APP: {
            setNewApp(message, M_SET_LAUNCHER_APP);
            break;
        }

//        case M_CHANGE_LAUNCHER_ICON: {
//            setNewAppOrChangeIcon(message, M_CHANGE_LAUNCHER_ICON);
//            break;
//		}


//        case B_SIMPLE_DATA:
//        {
//            qDebug() << "MainWindow::MessageReceived B_SIMPLE_DATA";
//            break;
//        }
		default:
		{
//			printf("window msg rec'd\n");
			break;
		}
	}
}

QString MainWindow::createLauncherDictString(bool isApp, const QString &appSignatureString, const QString &iconName)
{
    entry_ref ref;

    status_t stat = B_NO_INIT;

    if (isApp)
    {
        stat = be_roster->FindApp(appSignatureString.toLatin1().data(), &ref);
    }

    QString toolString;

    // fileName that contains the full file path name and is a QString type
    if (isApp && (stat == B_OK))
    {
        toolString = ref.name;
    }
    else
    {
        QFileInfo fileInfo(appSignatureString);
        if (fileInfo.exists()) {
            toolString = fileInfo.completeBaseName(); // Return only a file name
        }
    }

    QString fullEntryString = "{";

    fullEntryString.append(doubleQuote + appStringKey       + doubleQuote + ":");
    fullEntryString.append(doubleQuote + appSignatureString + doubleQuote + ",");
    fullEntryString.append(doubleQuote + iconImageKey       + doubleQuote + ":");
    fullEntryString.append(doubleQuote + iconName           + doubleQuote + ",");
    fullEntryString.append(doubleQuote + toolTipKey         + doubleQuote + ":");
    fullEntryString.append(doubleQuote + toolString         + doubleQuote);

    fullEntryString.append("}");

//    qDebug() << "fullEntryString = " + fullEntryString;

    return fullEntryString;
}

void MainWindow::loadDefaultLaunchers()
{
//    qDebug() << "loadDefaultLaunchers() called!";

//    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-Terminal",       "web_Monitor 2_thumb.png"));
//    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-DeskCalc",       "web_calc1_thumb.png"));
//    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-Magnify",        "dashboard.png"));
//    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-StyledEdit",     "editor.png"));
//    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-MediaPlayer",    "Skype.png"));
//    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-ActivityMonitor","web_backup 1_thumb.png"));

    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-Terminal",       "qrc:///defaultLauncherIcons/Terminal.svg"));
    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-DeskCalc",       "qrc:///defaultLauncherIcons/DeskCalc.svg"));
    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-Magnify",        "qrc:///defaultLauncherIcons/Magnify.svg"));
    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-StyledEdit",     "qrc:///defaultLauncherIcons/StyledEdit.svg"));
    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-MediaPlayer",    "qrc:///defaultLauncherIcons/MediaPlayer.svg"));
    dataList.append(createLauncherDictString(true, "application/x-vnd.Haiku-ActivityMonitor","qrc:///defaultLauncherIcons/ActivityMonitor.svg"));
}


QString MainWindow::getIconBase64UriForFile(const QString &appSignatureString)
{
//    qDebug() << "MainWindow::getIconBase64UriForFile = " + appSignatureString;

    entry_ref ref;
    status_t stat = be_roster->FindApp(appSignatureString.toLatin1().data(), &ref);

    QString fileFullPath;

    if (stat == B_OK)
    {
        BEntry myBEntry(&ref, TRUE);

        char name[B_FILE_NAME_LENGTH];
        myBEntry.GetName(name);
        myBEntry.GetParent(&myBEntry);
        BPath P;
        myBEntry.GetPath(&P);
        fileFullPath = QString(P.Path()) + "/" + QString(name);
    }
    else //probably not an app but a regular file or directory
    {
        QFileInfo fileInfo(appSignatureString);
        if (fileInfo.exists()) {
              fileFullPath = appSignatureString;
        }
        else {
            return "";
        }
    }

    QFileInfo qFileInfo(fileFullPath);

    QFileIconProvider iconProvider;
    QIcon theIcon = iconProvider.icon(qFileInfo);
    QByteArray byteArray;
    QBuffer    buffer(&byteArray);
    buffer.open(QIODevice::WriteOnly);
    theIcon.pixmap(QSize(32, 32), QIcon::Normal, QIcon::On).save(&buffer, "PNG");
    QString iconBase64 = QString(byteArray.toBase64());
    return "data:image/png;base64," + iconBase64;
}


QString MainWindow::readStringSettingsForKey(const QString &settingsKey)
{
    QSettings settings(ORGANIZATION_NAME, APPLICATION_NAME);

    return settings.value(settingsKey).toString();
}

void MainWindow::readSettings()
{
    QSettings settings(ORGANIZATION_NAME, APPLICATION_NAME);

    int size = settings.beginReadArray(LAUNCHERS_SETTINGS_KEY);

    if (size <= 0) {
//        printf("\n !!! No launchers in readSettings()... size = %d\n !!!\n\n\n\t Defaults will be loaded\n\n", size);
        settings.endArray();
        loadDefaultLaunchers();

        return;
    }

//    qDebug() << "readSettings()... size of launchers array = " + size;

    for (int i = 0; i < size; ++i) {
        settings.setArrayIndex(i);
//        qDebug() << (i + ": " + settings.value(cellEntryKey).toString());
        dataList.append(settings.value(cellEntryKey).toString());
    }
    settings.endArray();

    itemWidth                 = settings.value(ITEM_WIDTH_SETTINGS_KEY, 36).toInt();
    magnificationEnabled      = settings.value(MAGNIFICATION_ENABLED_SETTINGS_KEY, true).toBool();
    currentMagnificationIndex = settings.value(MAGNIFICATION_INDEX_SETTINGS_KEY, 7).toInt();
    currentDockScreenPosition = settings.value(SCREEN_POSITION_SETTINGS_KEY, 1).toInt();
    autoHideEnabled           = settings.value(AUTO_HIDE_ENABLED_SETTINGS_KEY, false).toBool();
    showRunningIndicators     = settings.value(RUNNING_INDICATORS_ENABLED_SETTINGS_KEY, true).toBool();
    newYosemiteBottomStyle    = settings.value(REFLECT_ICONS_3D_SHELF_SETTINGS_KEY, false).toBool();
}

QString MainWindow::getStringValueFromJSON(const QString &propertyKey, const QString &jsonString)
{
    // QScriptValue  object;
    // QScriptEngine engine;
    QJSEngine engine;
 
    // object = engine.evaluate("(" + jsonString + ")");

	QJSValue object = engine.evaluate("(" + jsonString + ")");
	

    // QScriptValue objectContents = object.property(propertyKey);
    QJSValue objectContents = object.property(propertyKey);

    return objectContents.toString();
}

void MainWindow::writeSettings()
{
    QSettings settings(ORGANIZATION_NAME, APPLICATION_NAME);
//    settings.setValue("pos", pos());
//    settings.setValue("size", size());

     settings.remove(LAUNCHERS_SETTINGS_KEY);
     settings.beginWriteArray(LAUNCHERS_SETTINGS_KEY);

     // minus two here is because we're skipping the last cell Trash launcher as static can't be removed or moved
     for (int i = 0; i < dataList.count() - 2; ++i)
     {
        settings.setArrayIndex(i);
        // plus one here is because we're skipping the first cell Tracker launcher as static can't be removed or moved
        settings.setValue(cellEntryKey, dataList.at(i+1));
     }
     settings.endArray();

//    //TODO:
//    ALTERNATIVE_TRACKER_ICON_SETTINGS_KEY
//    ALTERNATIVE_TRASH_FULL_ICON_SETTINGS_KEY
//    ALTERNATIVE_TRASH_EMPTY_ICON_SETTINGS_KEY

    QString currentTrackerIcon = getStringValueFromJSON(iconImageKey, dataList.at(0));

    qDebug() << "writeSettings getStringValueFromJSON Tracker icon = " << currentTrackerIcon;

    if (currentTrackerIcon == defaultTrackerIconName)
    {
        qDebug() << "not saving tracker icon, because still using default";
    }
    else
    {
        qDebug() << "saving new user-selected tracker icon: " << currentTrackerIcon;
        settings.remove(ALTERNATIVE_TRACKER_ICON_SETTINGS_KEY);
        settings.setValue(ALTERNATIVE_TRACKER_ICON_SETTINGS_KEY, currentTrackerIcon);
    }

    QString currentTrashEmptyIcon = getStringValueFromJSON(iconImageKey, dataList.at(dataList.count() - 1));

    if (currentTrashEmptyIcon == defaultTrashEmptyIconName)
    {
        qDebug() << "not saving trash empty icon, because still using default";
    }
    else
    {
        qDebug() << "saving new user-selected trash empty icon: " << currentTrashEmptyIcon;
        settings.remove(ALTERNATIVE_TRASH_EMPTY_ICON_SETTINGS_KEY);
        settings.setValue(ALTERNATIVE_TRASH_EMPTY_ICON_SETTINGS_KEY, currentTrashEmptyIcon);
    }

    settings.setValue(ITEM_WIDTH_SETTINGS_KEY, itemWidth);
    settings.setValue(MAGNIFICATION_ENABLED_SETTINGS_KEY, magnificationEnabled);
    settings.setValue(MAGNIFICATION_INDEX_SETTINGS_KEY, currentMagnificationIndex);
    settings.setValue(SCREEN_POSITION_SETTINGS_KEY, currentDockScreenPosition);
    settings.setValue(AUTO_HIDE_ENABLED_SETTINGS_KEY, autoHideEnabled);
    settings.setValue(RUNNING_INDICATORS_ENABLED_SETTINGS_KEY, showRunningIndicators);
    settings.setValue(REFLECT_ICONS_3D_SHELF_SETTINGS_KEY, newYosemiteBottomStyle);

    qDebug() << "Current settings saved.";
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    qDebug() << "closeEvent";
    writeSettings();

    if (iconPickerWin_ != NULL) {
        iconPickerWin_->close();
        iconPickerWin_->deleteLater();
    }

    if (prefsDialogWin_ != NULL) {
        prefsDialogWin_->close();
        prefsDialogWin_->deleteLater();
    }
    event->accept();
}
