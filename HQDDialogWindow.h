#ifndef HQDDIALOGWINDOW_H
#define HQDDIALOGWINDOW_H

#include <QMainWindow>

// class QDeclarativeView;
class QQuickView;

class HQDDialogWindow : public QMainWindow
{
  Q_OBJECT

public:
    HQDDialogWindow();

signals:
    void windowWillClose(const QString &pathToIconImageFile);
protected:
    void closeEvent(QCloseEvent *event);

};

#endif // HQDDIALOGWINDOW_H
