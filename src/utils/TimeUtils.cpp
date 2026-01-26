// TimeUtils.cpp
#include "TimeUtils.h"

namespace TimeUtils {

QTime parseTime(const QString &str)
{
    QTime t = QTime::fromString(str, "HH:mm");
    if (t.isValid()) return t;

    t = QTime::fromString(str, "H:mm");
    if (t.isValid()) return t;

    return QTime();
}

bool isValidTime(const QString &str)
{
    return parseTime(str).isValid();
}

}
