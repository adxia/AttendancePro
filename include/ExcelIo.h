#ifndef EXCELIO_H
#define EXCELIO_H
#include <QObject>
#include <tchar.h>
#include "libxl.h"
#include "Struct.h"
#include <QDate>

class ExcelIO :public QObject {
    Q_OBJECT
public:
    explicit ExcelIO(QVector<AttendanceRecord>& records,const QVariantMap& map);

    libxl::Color colorFromHex(const QString& hex);

    bool resetBook(const QString& path);

    libxl::Sheet* getSheetByName(const std::wstring& name);

    int Column(QString col);

    bool openFile(const QString& path);

    QDate readDate(int row, int col);

    QTime readTime(int row, int col);

    void close();

    int rowCount() const;

    bool loadData();

    bool loadCheckInLog();

    bool loadAttendance();

    bool saveAs(QString& filepath,TemplateType templatetype,const QString &savefolder);

    void writeNumber(int row, int col, double value);

    void loadExcelMap();

    virtual ~ExcelIO();


private:
    QVector<AttendanceRecord>& m_records;
    const QVariantMap& m_excelMap;
    libxl::Book* m_book = nullptr;
    libxl::Sheet* m_sheet = nullptr;
    QVariant read(int row,int col) const;
};

#endif // EXCELIO_H
