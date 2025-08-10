
#ifndef MAINWINDOW_H
#define MAINWINDOW_H


//Settings Required Values and Keys
// #define ORGANIZATION_NAME       "hey68you"
// #define APPLICATION_NAME        "application/x-vnd.HiQDock"
#define ORGANIZATION_NAME       "Hi-Q-Apps"
#define APPLICATION_NAME        "HiQDock"



#define LAUNCHERS_SETTINGS_KEY                    "launchers"
#define ITEM_WIDTH_SETTINGS_KEY                   "itemWidth"
#define MAGNIFICATION_ENABLED_SETTINGS_KEY        "magnificationEnabled"
#define MAGNIFICATION_INDEX_SETTINGS_KEY          "magnificationIndex"
#define SCREEN_POSITION_SETTINGS_KEY              "lastScreenPosition"
#define AUTO_HIDE_ENABLED_SETTINGS_KEY            "autoHide"
#define REFLECT_ICONS_3D_SHELF_SETTINGS_KEY       "3dReflectionBottomShelf"
#define RUNNING_INDICATORS_ENABLED_SETTINGS_KEY   "showRunningIndicators"
#define ALTERNATIVE_TRACKER_ICON_SETTINGS_KEY     "trackerIcon"
#define ALTERNATIVE_TRASH_FULL_ICON_SETTINGS_KEY  "trashFullIcon"
#define ALTERNATIVE_TRASH_EMPTY_ICON_SETTINGS_KEY "trashEmptyIcon"

//Possible Screen Positions
#define SCREEN_POSITION_LEFT   0
#define SCREEN_POSITION_BOTTOM 1
#define SCREEN_POSITION_RIGHT  2
#define SCREEN_POSITION_TOP    3

#include <InterfaceKit.h>
#include <FilePanel.h>
#include <QPixmap>
#include <QMainWindow>
#include <Roster.h>
//#include <QDialog>
#include <QSystemTrayIcon>
#include <storage/Path.h>

////#include "ui_PrefsWindow.h"
//#include "ui_PreferencesDialog.h"

class HaikuMouseTrackingView;
// class QDeclarativeView;
// class QQuickView;
class QQuickWidget;
class MainWindow;
class HQDDialogWindow;
//class QMenu;
//class Ui_Dialog;


class QBeLooper : public BLooper
{
    public:
        QBeLooper(MainWindow *mainWinObj);
        ~QBeLooper();

        void MessageReceived (BMessage *msg);

    private:
        MainWindow *theMainWindow_;
};

//class MyHandler : public BHandler
//{
//    public:
//        MyHandler(MainWindow *mainWinObj);
//        ~MyHandler();
//
//        virtual void MessageReceived (BMessage *msg);
//
//    private:
//        MainWindow *theMainWindow_;
//};

class MainWindow : public QMainWindow
{
    Q_OBJECT

    public:
        MainWindow();
        ~MainWindow();

        void Activate();
        void MouseOutside();
        void MessageReceived (BMessage *message);
//        virtual void RefsReceived(BMessage* message);

//        void refreshBackground();
        virtual void paintEvent(QPaintEvent *pe);
        virtual void dropEvent(QDropEvent *event);
        virtual bool event(QEvent *evt);
//        virtual void mouseMoveEvent(QMouseEvent *event);

        int getCurrentDockScreenPosition();

    public slots:
        void onQuitSlot() { writeSettings(); }
//        void TakeUpperScreenShot();

        //===========================================================
        // "invokable slots" can be called from within QML
        //   and c++ can return value to the calling QML script-code
        //===========================================================
        Q_INVOKABLE bool isAppRunning(const QString &appSignatureString);
        Q_INVOKABLE bool isMultiLaunch(const QString &appSignatureString);
        Q_INVOKABLE int  moveItems(int fromIndex, int toIndex);
        Q_INVOKABLE void launch(const QString &appSignatureString);
        Q_INVOKABLE void openFolder(const QString &folderPath);
        Q_INVOKABLE void itemRemoved(int indexRemoved);
        Q_INVOKABLE void addNewItemAt(int indexToAddNewItem);
        Q_INVOKABLE void setIconImageForItemAt(int indexOfItem);
        Q_INVOKABLE void updateIconImageInMasterListForItemAt(int indexOfItem, const QString &jsonString);
        Q_INVOKABLE void hideShowQuitApp(const QString &appSignatureString, int hideShowOrQuit);
        Q_INVOKABLE void openParentFolder(const QString &appSignatureString);
        Q_INVOKABLE QString getIconBase64UriForFile(const QString &appSignatureString);
        Q_INVOKABLE void notifyNewItemWidth(int newItemWidth);
        Q_INVOKABLE void notifyWidthChanged(int newWidth);
        Q_INVOKABLE void notifyHeightChanged(int newHeight);
        Q_INVOKABLE void notifyInsideDock(bool isInside);
        Q_INVOKABLE void notifyDockHidden(bool showingState);
        Q_INVOKABLE void notifyIconPicked(const QString &pathToIconImageFile);
//        Q_INVOKABLE void notifyIconPickerWindowDestroyed();
        Q_INVOKABLE void notifySetAutoHide(bool onOff);
        Q_INVOKABLE void notifySetMagnificationEnabled(bool enable);
        Q_INVOKABLE void notifyUseNewYosemiteBottomStyle(bool useNewStyleOnBottom);
        Q_INVOKABLE void showPreferencesDialog();
        Q_INVOKABLE void notifyShowRunningIndicators(bool showIndicator);
        Q_INVOKABLE void notifyValueForSizeUpdated(double percent);
        Q_INVOKABLE void notifyValueForMagnificationUpdated(double percent);
        Q_INVOKABLE void notifySizeDraggingInProgress(bool isDragging);
        Q_INVOKABLE void notifySetNewScreenPosition(int newPosition);

    signals: // sending stuff to QML via "emit" (can't get return value) -- HAVE TO LINK it up to the QML in the .cpp
             // using: QObject::connect(this, SIGNAL( .....

//        void notifyAppLaunched(QVariant appSignatureString, QVariant appTeamId);
        void notifyAppLaunched(QVariant appSignatureString);
//        void notifyAppQuit(QVariant appTeamId);
        void notifyAppQuit(QVariant appSignatureString);
        void notifyDockActivated();
        void notifyDockDeactivated();
        void addLauncherToQML(QVariant jsonDataString, QVariant indexToPutNewItem);
        void updateToNewIconImageForItemAt(QVariant pathToIcon, QVariant indexOfItem);
        void updateAutoHide(QVariant autoHide);
        void updateMagnificationEnabled(QVariant enable);
        void updateNewScreenPosition(QVariant newScreenPosition);
        void notifyQMLValueForSizeUpdated(QVariant newPercent);
        void notifyApplistModified();

    protected:
        void closeEvent(QCloseEvent *event);
        virtual void showEvent(QShowEvent *event);

    private:

        QString createLauncherDictString(bool isApp, const QString &appSignatureString, const QString &iconName);
        QString getStringValueFromJSON(const QString &propertyKey, const QString &jsonString);
        QString readStringSettingsForKey(const QString &settingsKey);
//        void mouseMoveEvent(QMouseEvent *event);
        void loadHaikuMouseTrackingView();
        void setNewApp(BMessage *message, uint32 messageName);
		void initFilePanels(uint32 messageName);
        void loadDefaultLaunchers();
        void readSettings();
        void writeSettings();
        bool isOrientationChanging(int newPosition);
        void moveScreenToPosition(int newPosition);
		
		BPath userSettingsPath;

        // QDeclarativeView *view;
		QScreen          *screen;
        // QQuickView       *view;
		QQuickWidget     *view;
        BMessenger       *myMessenger;
        QBeLooper        *myLooper;
        QPixmap          fullScreenShotPixmap;
//        QPixmap          upperScreenShotPixmap;
        QStringList      dataList;
        BFilePanel       *fPanelOpen;
//        QMainWindow      *iconPickerWin_;
        HQDDialogWindow  *iconPickerWin_;
        QMainWindow      *prefsDialogWin_;
        int              itemWidth;
        int              minItemSize;
        int              maxItemSize;
        int              currentMagnificationIndex;
        int              indexWhereToAddNew;
        int              currentDockScreenPosition;
        bool             isDockHidden_;
        bool             autoRaiseEnabled;
        bool             autoHideEnabled;
        bool             magnificationEnabled;
        bool             showRunningIndicators;
        bool             newYosemiteBottomStyle;
        bool             sizeSliderDragInProgress;
        bool             needsUpperRefresh;
//        BWindow          *beWin_;

        HaikuMouseTrackingView *mouseTrackingView_;

//        QSystemTrayIcon *trayIcon;
//        QMenu           *trayIconMenu;
};

#endif // MAINWINDOW_H
