#include "MessageCenter.h"

MessageCenter* MessageCenter::m_instance = nullptr;

MessageCenter* MessageCenter::instance(){
    if(!m_instance){
        m_instance = new MessageCenter(qApp);
        return m_instance;
    }
    return m_instance;
}
MessageCenter::MessageCenter(QObject* parent)
    : QObject(parent)
{

}
