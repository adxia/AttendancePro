#include "ExcelIo.h"
#include "MessageCenter.h"
#include <QRegularExpression>


ExcelIO::ExcelIO(QVector<AttendanceRecord>& records,const QVariantMap& map):m_records(records),m_excelMap(map)
{

}

bool ExcelIO::resetBook(const QString& path) {
    // 释放旧资源
    if (m_book) {
        m_book->release();
    }
    // 根据后缀名创建对应的 Book 对象
    if (path.endsWith(".xlsx", Qt::CaseInsensitive)) {
        m_book = xlCreateXMLBook();
    } else {
        m_book = xlCreateBook();
    }
    if (!m_book){
        return false;
    }
    // 统一设置注册码
    const TCHAR * name = L"your_name";
    const TCHAR * key = L"your_key";

    m_book->setKey(name, key);
    m_book->setRgbMode(true);
    return true;
}

bool ExcelIO::openFile(const QString& path){
    resetBook(path);
    std::wstring filepath = path.toStdWString();
    if(!m_book->load(filepath.c_str())){
        const QString err = m_book->errorMessage();
        emit MessageCenter::instance()->erromessage("文件读取错误", path +err,false);
        return false;
    }
    return true;
};

QVariant ExcelIO::read(int row,int col) const{
    QVariant result;
    libxl::CellType celltype = m_sheet->cellType(row, col);
    switch (celltype)
    {
    case libxl::CELLTYPE_EMPTY:
        result = "";
        break;
    case libxl::CELLTYPE_NUMBER:
        result = m_sheet->readNum(row, col);
        break;
    case libxl::CELLTYPE_STRING:
    {
        std::wstring wval = m_sheet->readStr(row, col);
        result = QString::fromStdWString(wval);
        break;
    }
    case libxl::CELLTYPE_BOOLEAN:
        result = m_sheet->readBool(row, col);
        break;
    case libxl::CELLTYPE_BLANK:
        result = "";
        break;
    case libxl::CELLTYPE_ERROR:
        result = "#NA";
        break;
    case libxl::CELLTYPE_STRICTDATE:
        result = m_sheet->readNum(row, col);
        break;
    default:
        break;
    }
    return result;
};

QDate ExcelIO::readDate(int row, int col)
{
    bool isdate = m_sheet->isDate(row,col);
    if(isdate){
        int year, month, day;
        QVariant val =  read(row,col);
        if(m_book->dateUnpack(val.toDouble(),&year,&month,&day)){
            QDate date(year,month,day);
            return date;
        }
    }
    else{
        QString val =  read(row,col).toString().trimmed();
        static const QStringList formats = {
            // 1. 斜杠系列
            "yyyy/M/d H:m:s",
            "yyyy/M/d H:m",
            "yyyy/M/d",

            // 2. 横杠系列
            "yyyy-M-d H:m:s",
            "yyyy-M-d H:m",
            "yyyy-M-d",

            // 3. 点系列与紧凑系列
            "yyyy.M.d",
            "yyyyMMdd"
        };
        for (const auto &fmt : formats) {
            QDateTime dt = QDateTime::fromString(val, fmt);
            if (dt.isValid())
            {
                return dt.date();
            }
        }
    }
    return QDate();
}
QTime ExcelIO::readTime(int row, int col)
{
    bool isdate = m_sheet->isDate(row,col);
    if(isdate){
        int year, month, day, hour, min, sec;
        QVariant val =  read(row,col);
        if(m_book->dateUnpack(val.toDouble(),&year,&month,&day,&hour,&min,&sec)){
            QTime time(hour,min,sec);
            return time;
        }
    }
    else{

        QString val =  read(row,col).toString().trimmed();
        if(val.isEmpty())
            return QTime();

        static const QStringList dateTimeFmts = {
             // 1. 斜杠系列
             "yyyy/M/d H:m:s",
             "yyyy/M/d H:m",
             "yyyy/M/d",

             // 2. 横杠系列
             "yyyy-M-d H:m:s",
             "yyyy-M-d H:m",
             "yyyy-M-d",

             // 3. 点系列与紧凑系列
             "yyyy.M.d",
             "yyyyMMdd"
        };
        for (const auto &fmt : dateTimeFmts) {
            QDateTime dt = QDateTime::fromString(val, fmt);
            if (dt.isValid()) return dt.time(); // 提取时间部分
        }

        static const QStringList timeFmts = {
             "H:m:s", "H:m"
        };
        for (const auto &fmt : timeFmts) {
            QTime t = QTime::fromString(val, fmt);
            if (t.isValid()) return t;
        }
    }
    return QTime();
}



int ExcelIO::Column(QString col){
    int result = 0;
    QString upper = col.toUpper();  // 不区分大小写
    for (int i = 0; i < upper.size(); ++i) {
        QChar c = upper[i];
        if (c < 'A' || c > 'Z') {
            return -1;
        }
        result = result * 26 + (c.unicode() - 'A' + 1);
    }
    return result -1;
}

bool ExcelIO::loadCheckInLog(){
    static const QRegularExpression re("^[\\(（\\[【].*?[\\)）\\]】]");
    QString sheetName = m_excelMap.value("inputSheetName").toString();
    std::wstring wname = sheetName.toStdWString();
    int nameCol =  Column(m_excelMap.value("inputuserColumn").toString());
    int dateCol =  Column(m_excelMap.value("inputdateColumn").toString());
    int logCol =  Column(m_excelMap.value("attendanceTime").toString());
    if(nameCol == -1 || logCol == -1){
        emit MessageCenter::instance()->erromessage("模板错误","输入模板映射不对，请检查模板无误。",false);
        return false;
    }
    libxl::Sheet* sheet = getSheetByName(wname);
    if (!sheet) {
        emit MessageCenter::instance()->erromessage("文件读取错误","未查询到对应Sheet。",false);
        return false;
    }
    m_sheet = sheet;

    int lastRow = m_sheet->lastRow();

    QHash<QString, TempTime> tempMap;

    for(int i=1; i < lastRow; ++i){
        TempTime temp;
        QString name = read(i,nameCol).toString();
        name.remove(re);
        name = name.trimmed();
        QDate date;
        QTime time;
        if(dateCol == -1){
            date = readDate(i,logCol);
            time= readTime(i, logCol);
        }
        else{
            date = readDate(i,dateCol);
            time= readTime(i, logCol);
        }
        if(!date.isValid()){
            emit MessageCenter::instance()->erromessage("打卡日期错误","无法解析的日期格式" + date.toString(),false);
            return false;
        }
        if(!time.isValid()){
            emit MessageCenter::instance()->erromessage("打卡时间错误","无法解析的时间格式",false);
            return false;
        }
        QString key = QString("%1-%2").arg(name,date.toString("yyyy-MM-dd"));

        TempTime &item = tempMap[key];

        if (item.times.isEmpty()) {
            item.name = name;
            item.date = date;
        }
        item.times.push_back(time);
    }
    m_records.clear();
    for(auto it = tempMap.begin(); it != tempMap.end(); ++it){
        const TempTime &temp = it.value();
        if(temp.times.isEmpty()) continue;

        AttendanceRecord rec;
        rec.name = temp.name;
        rec.date = temp.date;

        if (temp.times.length()< 1 ){
            rec.start = QTime();
            rec.end = QTime();
        }
        else{
            QVector<QTime> times = temp.times;
            std::sort(times.begin(), times.end());

            QTime start = times.first();
            QTime end;

            constexpr int MIN_INTERVAL_MIN = 30;

            for (int i = 1; i < times.size(); ++i) {
                if (start.msecsTo(times[i]) >= MIN_INTERVAL_MIN * 60 * 1000) {
                    end = times[i];
                }
            }
            rec.start = start;
            rec.end   = end;

        }
        m_records.append(rec);
    }


    return true;
};

bool ExcelIO::loadAttendance(){
    QString sheetName = m_excelMap.value("inputSheetName").toString();
    std::wstring wname = sheetName.toStdWString();
    int nameCol =  Column(m_excelMap.value("inputuserColumn").toString());
    int dateCol =  Column(m_excelMap.value("inputdateColumn").toString());
    int starCol =  Column(m_excelMap.value("signInColumn").toString());
    int endCol =  Column(m_excelMap.value("signOutColumn").toString());

    if(nameCol == -1 || dateCol==-1 || starCol== -1 || endCol == -1){
        emit MessageCenter::instance()->erromessage("模板错误","输入模板映射不对，请检查模板无误。",false);
        return false;
    }
    libxl::Sheet* sheet = getSheetByName(wname);
    if (!sheet) {
        emit MessageCenter::instance()->erromessage("文件读取错误","未查询到对应Sheet。",false);
        return false;
    }
    m_sheet = sheet;

    int lastRow = m_sheet->lastRow();
    m_records.clear();
    for(int i=1; i < lastRow; ++i){
        AttendanceRecord row;
        row.name = read(i,nameCol).toString();

        QDate date = readDate(i,dateCol);
        if (!date.isValid()) {
            emit MessageCenter::instance()->erromessage("日期错误","打卡日期列解析错误，不允许空或非日期格式",false);
            return false;
        }
        row.date = date;

        bool isStar = m_sheet->isDate(i,starCol);
        if(isStar){
            int year, month, day, hour, min, sec;
            QVariant val =  read(i,starCol);
            if(m_book->dateUnpack(val.toDouble(),&year,&month,&day,&hour,&min,&sec)){
                QTime time(hour, min, sec);
                row.start = time;
            }
        }
        else{
            QVariant star =  read(i,starCol);
            QTime t = QTime::fromString(star.toString(), "HH:mm");
            if (!t.isValid())
                t = QTime::fromString(star.toString(), "H:mm");
            row.start = t;
        }
        bool isEnd = m_sheet->isDate(i,endCol);
        if(isEnd){
            int year, month, day, hour, min, sec;
            QVariant val =  read(i,endCol);
            if(m_book->dateUnpack(val.toDouble(),&year,&month,&day,&hour,&min,&sec)){
                QTime time(hour, min, sec);
                row.end = time;
            }
        }
        else{
            QVariant end =  read(i,endCol);
            QTime t = QTime::fromString(end.toString(), "HH:mm");
            if (!t.isValid())
                t = QTime::fromString(end.toString(), "H:mm");
            row.end = t;
        }
        m_records.append(row);
    }
    return true;
};



bool ExcelIO::loadData(){
    if(m_excelMap.value("inputType").toString()=="考勤汇总表")
    {
        if(!loadAttendance())
            return false;

    }
    else
    {
        if(!loadCheckInLog())
            return false;
    }
    return true;

};

libxl::Sheet* ExcelIO::getSheetByName(const std::wstring& name) {

    int sheetCount = m_book->sheetCount();
    for (int i = 0; i < sheetCount; ++i) {
        if(m_book->getSheetName(i) == name){
            return m_book->getSheet(i);
        }
    }
    return nullptr;
}


libxl::Color ExcelIO::colorFromHex(const QString& hex)
{
    QString s = hex;
    if (s.startsWith('#'))
        s.remove(0, 1);
    if (s.length() != 6)
        return libxl::COLOR_BLACK;
    bool ok;
    int r = s.mid(0, 2).toInt(&ok, 16);
    int g = s.mid(2, 2).toInt(&ok, 16);
    int b = s.mid(4, 2).toInt(&ok, 16);
    return m_book->colorPack(r, g, b);
}



bool ExcelIO::saveAs(QString& filepath,TemplateType templatetype,const QString &savefolder){
    resetBook(filepath);
    openFile(filepath);

    if(templatetype == Formal){
        QString sheetName = m_excelMap.value("formalSheetName").toString();
        int starRow = m_excelMap.value("formalStartRow").toInt();
        int starCol = Column(m_excelMap.value("formalStartColumn").toString());
        int dateRow =  m_excelMap.value("formalDateRow").toInt();
        int nameCol = Column(m_excelMap.value("formalNameColumn").toString());
       // QString dateformat = m_excelMap.value("formalDateFormat").toString();

        std::wstring wname = sheetName.toStdWString();
        libxl::Sheet* sheet = getSheetByName(wname);

        if (!sheet) {
            emit MessageCenter::instance()->erromessage("模板1错误","未查询到对应Sheet。",false);
            return false;
        }
        m_sheet = sheet;
        int lastRow = m_sheet->lastRow();
        int lastCol = m_sheet->lastCol();
        QSet<int> cols;
        QHash<QString,WriteMap> table;

        QHash<int, int> dateToCol;
        for(int j = starCol; j < lastCol; ++j) {
            int d = read(dateRow-1, j).toInt();
            if(d >= 1 && d <= 31) dateToCol[d] = j;
        }
        for(int i = starRow-1; i < lastRow; ++i){
            QString name = read(i,nameCol).toString();
            if(!name.isEmpty()){
                for(int j = starCol;j<lastCol;++j){
                    for(auto [date, col] : dateToCol.asKeyValueRange()) {
                        table.insert(name + "_" + QString::number(date), {i, col});
                    }
                }
            }
        }
        //缺勤格式
        libxl::Format* absenceformat = m_book->addFormat();
        absenceformat->setFillPattern(libxl::FILLPATTERN_SOLID);
        QString color = m_excelMap.value("absenceBgColor").toString();
        absenceformat->setPatternForegroundColor(colorFromHex(color));
        absenceformat->setBorder(libxl::BORDERSTYLE_THIN);

        //漏打卡格式
        libxl::Format* missingformat = m_book->addFormat();
        missingformat->setFillPattern(libxl::FILLPATTERN_SOLID);
        QString missingcolor = m_excelMap.value("missingBgColor").toString();
        missingformat->setPatternForegroundColor(colorFromHex(missingcolor));
        missingformat->setBorder(libxl::BORDERSTYLE_THIN);

        //边框居中格式
        libxl::Format* alignformat = m_book->addFormat();
        alignformat->setAlignH(libxl::ALIGNH_CENTER);
        alignformat->setAlignV(libxl::ALIGNV_CENTER);
        alignformat->setBorder(libxl::BORDERSTYLE_THIN);

        //红字体格式
        libxl::Font* font = m_book->addFont();
        QString fontcolor = m_excelMap.value("lateTextColor").toString();
        font->setColor(colorFromHex(fontcolor));
        libxl::Format* fontredformat = m_book->addFormat();
        fontredformat->setFont(font);
        fontredformat->setAlignH(libxl::ALIGNH_CENTER);
        fontredformat->setAlignV(libxl::ALIGNV_CENTER);
        fontredformat->setBorder(libxl::BORDERSTYLE_THIN);

        int len = m_records.length();
        for (int i=0;i<len;++i){
            int dd = m_records[i].date.day();
            QString name = m_records[i].name + "_" + QString::number(dd);
            if (!table.contains(name)) {
                continue;
            }
            int writeRow = table.value(name).row;
            int writeCol = table.value(name).col;

            if(m_records[i].note == "缺勤"){
                m_sheet->writeBlank(writeRow, writeCol, absenceformat);
            }
            else if(m_records[i].note == "漏打卡"){
                m_sheet->writeBlank(writeRow, writeCol, missingformat);
            }
            else if(m_records[i].note == "休息"){
                continue;
            }
            else if (!m_records[i].workDetail.isEmpty()){
                std::wstring val = m_records[i].workDetail.toStdWString();
                m_sheet->writeStr(writeRow,writeCol,val.c_str(),alignformat);
                cols.insert(writeCol);
            }
            else if(m_records[i].workHours < 0 && m_records[i].note.isEmpty() && m_records[i].workDetail.isEmpty()){

                double val = m_records[i].workHours;
                if(val != 0){
                    m_sheet->writeNum(writeRow,writeCol,val, fontredformat);
                }
            }

            else if(m_records[i].workHours >= 0 && m_records[i].note.isEmpty() && m_records[i].workDetail.isEmpty()){
                double val = m_records[i].workHours;
                if(val != 0){
                    m_sheet->writeNum(writeRow,writeCol,val,alignformat);
                }
            }
        }
        if(!cols.isEmpty()){
            for(int item:cols){
                m_sheet->setCol(item,item,6);
            }
        }
        int month = QDate::currentDate().month();
        std::wstring path = savefolder.toStdWString()+ QString::number(month).toStdWString() + L"月模板1考勤表.xlsx";
        m_book->save(path.c_str());
    }

    else if(templatetype == Service){

        QString sheetName = m_excelMap.value("serviceSheetName").toString();
        int starRow = m_excelMap.value("serviceStartRow").toInt();
        int starCol = Column(m_excelMap.value("serviceStartColumn").toString());
        int dateRow =  m_excelMap.value("serviceDateRow").toInt();
        int nameCol = Column(m_excelMap.value("serviceNameColumn").toString());
        // QString dateformat = m_excelMap.value("formalDateFormat").toString();

        std::wstring wname = sheetName.toStdWString();
        libxl::Sheet* sheet = getSheetByName(wname);

        if (!sheet) {
            emit MessageCenter::instance()->erromessage("模板2错误","未查询到对应Sheet："+sheetName,false);
            return false;
        }
        m_sheet = sheet;
        int lastRow = m_sheet->lastRow();
        int lastCol = m_sheet->lastCol();
        QSet<int> cols;
        QHash<QString,WriteMap> table;
        QHash<int, int> dateToCol;
        for(int j = starCol; j < lastCol; ++j) {
            int d = read(dateRow-1, j).toInt();
            if(d >= 1 && d <= 31) dateToCol[d] = j;
        }

        for(int i = starRow-1; i < lastRow; ++i){
            QString name = read(i,nameCol).toString();
            if(!name.isEmpty()){
                for(auto [date, col] : dateToCol.asKeyValueRange()) {
                    table.insert(name + "_" + QString::number(date), {i, col});
                }
            }
        }
        //缺勤格式
        libxl::Format* absenceformat = m_book->addFormat();
        absenceformat->setFillPattern(libxl::FILLPATTERN_SOLID);
        QString color = m_excelMap.value("serviceAbsenceBgColor").toString();
        absenceformat->setPatternForegroundColor(colorFromHex(color));
        absenceformat->setBorder(libxl::BORDERSTYLE_THIN);

        //漏打卡格式
        libxl::Format* missingformat = m_book->addFormat();
        missingformat->setFillPattern(libxl::FILLPATTERN_SOLID);
        QString missingcolor = m_excelMap.value("serviceMissingBgColor").toString();
        missingformat->setPatternForegroundColor(colorFromHex(missingcolor));
        missingformat->setBorder(libxl::BORDERSTYLE_THIN);

        //边框居中格式
        libxl::Format* alignformat = m_book->addFormat();
        alignformat->setAlignH(libxl::ALIGNH_CENTER);
        alignformat->setAlignV(libxl::ALIGNV_CENTER);
        alignformat->setBorder(libxl::BORDERSTYLE_THIN);

        //红字体格式
        libxl::Font* font = m_book->addFont();
        QString fontcolor = m_excelMap.value("serviceLateTextColor").toString();
        font->setColor(colorFromHex(fontcolor));
        libxl::Format* fontredformat = m_book->addFormat();
        fontredformat->setFont(font);
        fontredformat->setAlignH(libxl::ALIGNH_CENTER);
        fontredformat->setAlignV(libxl::ALIGNV_CENTER);
        fontredformat->setBorder(libxl::BORDERSTYLE_THIN);


        int len = m_records.length();
        for (int i=0;i<len;++i){
            int dd = m_records[i].date.day();
            QString name = m_records[i].name + "_" + QString::number(dd);
            if (!table.contains(name)) {
                continue;
            }
            int writeRow = table.value(name).row;
            int writeCol = table.value(name).col;

            if(m_records[i].note == "缺勤"){
                m_sheet->writeBlank(writeRow, writeCol, absenceformat);
            }
            else if(m_records[i].note == "漏打卡"){
                m_sheet->writeBlank(writeRow, writeCol, missingformat);
            }
            else if(m_records[i].note == "休息"){
                continue;
            }
            else if (!m_records[i].workDetail.isEmpty()){

                std::wstring val = m_records[i].workDetail.toStdWString();
                m_sheet->writeStr(writeRow,writeCol,val.c_str(),alignformat);
                cols.insert(writeCol);
            }
            else if(m_records[i].workHours < 0 && m_records[i].note.isEmpty() && m_records[i].workDetail.isEmpty()){
                double val = m_records[i].workHours;
                if(val != 0){
                    m_sheet->writeNum(writeRow,writeCol,val,fontredformat);
                }
            }
            else if(m_records[i].workHours >= 0 && m_records[i].note.isEmpty() && m_records[i].workDetail.isEmpty()){
                double val = m_records[i].workHours;
                if(val != 0){
                    m_sheet->writeNum(writeRow,writeCol,val,alignformat);
                }
            }
        }
        if(!cols.isEmpty()){
            for(int item:cols){
                m_sheet->setCol(item,item,6);
            }
        }

        int month = QDate::currentDate().month();
        std::wstring path = savefolder.toStdWString() + QString::number(month).toStdWString() + L"月模板2考勤表.xlsx";
        m_book->save(path.c_str());
    }
    return true;
};

ExcelIO::~ExcelIO(){
    if (m_book){
        m_book->release();
    }
}
