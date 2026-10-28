
#include <QApplication>
#include <QObject>
#include <QMainWindow>
// #include <QDeclarativeView>
#include <QQuickView>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <Roster.h>
#include <Messenger.h>
#include <Application.h>
//#include <QGraphicsBlurEffect>
#include <QLoggingCategory>

#include "mainWindow.h"

///////////////////
//class QBeApplication : public QApplication
//{
//    public:
//        QBeApplication(int argc, char *argv[]);
//        ~QBeApplication();
//
//        virtual void MessageReceived(BMessage *msg);
//
//};
//
//QBeApplication::QBeApplication(int argc, char *argv[])
// : QApplication(argc, argv)
//{
//    be_roster->StartWatching(BMessenger((BHandler*)this));
//}
//
//QBeApplication::~QBeApplication(){}
//
//void QBeApplication::MessageReceived(BMessage *msg)
//{
////    switch (message->what) {
////
////		case B_SOME_APP_QUIT:
////		case B_SOME_APP_LAUNCHED:
////		{
////       }
//
//    printf("QBeApplication msg rec'd\n");
////    BApplication::MessageReceived(msg);
//}
///////////////////

//class MyHandler : public BHandler
//{
//    public:
//        MyHandler();
//        ~MyHandler();
//
//        virtual void MessageReceived(BMessage *msg);
//
//};
//
//MyHandler::MyHandler()
// : BHandler("MyHandler")
//{
////    theMainWindow_ = mainWinObj;
//}
//
//MyHandler::~MyHandler(){}
//
//void MyHandler::MessageReceived(BMessage *msg)
//{
//    printf("Default: App Handler msg rec'd\n");
//
//	switch(msg->what) {
//		case B_SOME_APP_QUIT:
//		case B_SOME_APP_LAUNCHED:
//		{
//            printf("Launched or Quit: Yay msg rec'd\n");
////            theMainWindow_->MessageReceived(msg);
//			break;
//		}
//		default:
//        {
//            printf("Default: Yay msg rec'd\n");
//			BHandler::MessageReceived(msg);
//        }
//	}
//}

int main(int argc, char *argv[])
{
    //Q_INIT_RESOURCE(application);

#ifdef QT_NO_DEBUG_OUTPUT
    QLoggingCategory::setFilterRules("qml=false");
#endif

    // HiQDock renders its QML through QQuickWidget. On Haiku the RHI/OpenGL path
    // cannot compile the scene graph shaders, so the software scenegraph adaptation
    // is required. Request it before the first QQuickWindow, which MainWindow creates.
    QQuickWindow::setGraphicsApi(QSGRendererInterface::Software);


    QApplication app(argc, argv);
//    QBeApplication app(argc, argv);


    // The Qt Configurator's "Use Software 2d context renderer" option selects the same
    // adaptation by exporting QMLSCENE_DEVICE=softwarecontext, and that is the mechanism
    // that is known to work here. Request it from the application as well, so HiQDock
    // behaves identically whether or not that option is enabled. Set after QApplication
    // because the Haiku platform plugin rebuilds the process environment (clearenv plus
    // putenv) while the platform integration is created inside that constructor.
    qputenv("QMLSCENE_DEVICE", "softwarecontext");
	
//extern const char *kApplicationSignature = "application/x-vnd.HiDock";
//
//HDockApp::HDockApp()
//	:
//	BApplication(kApplicationSignature)

//    qmlRegisterType<QGraphicsBlurEffect>("Effects",1,0,"Blur");

    app.setOrganizationName(ORGANIZATION_NAME);
    app.setApplicationName(APPLICATION_NAME);

    MainWindow mainWin;

    QObject::connect(&app, SIGNAL(aboutToQuit()), &mainWin, SLOT(onQuitSlot()));

    mainWin.show();

    int stat = app.exec();

//    BWindow          *beWin_;
//    beWin_ = app->WindowAt(0);
//    if (beWin_)
//    {
//        printf("got beWin_ in main.cpp");
//
////        qDebug() << "main.cpp win 0 is there!";
//        status_t stat = beWin_->SendBehind(NULL);
////        if  (stat == B_OK) {
// //           qDebug() << "main.cpp SendBehind worked";
//   //     }
//     //   else {
//       //     qDebug() << "main.cpp SendBehind FAILED";
//        //}
//
//    }

    return stat;
}
