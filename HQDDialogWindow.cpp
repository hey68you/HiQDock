#include <QtGui>
#include "HQDDialogWindow.h"


HQDDialogWindow::HQDDialogWindow()
    : QMainWindow(0, Qt::Tool)
{
}

void HQDDialogWindow::closeEvent(QCloseEvent *event)
{
    emit windowWillClose("");

    qDebug() << "HQDDialogWindow::closeEvent";

    event->accept();
}
