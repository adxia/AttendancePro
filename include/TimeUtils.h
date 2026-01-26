// TimeUtils.h
#pragma once
#include <QTime>
#include <QString>

namespace TimeUtils {

QTime parseTime(const QString &str);
bool isValidTime(const QString &str);

}
