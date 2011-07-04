#ifndef SHARES_H
#define SHARES_H

#include "xbmcmodel.h"

class Shares : public XbmcModel
{
    Q_OBJECT
public:
    explicit Shares(const QString &mediatype, QObject *parent = 0);

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    XbmcModel *enterItem(int index);
    void playItem(int index);

    QString title() const;

private slots:
    void responseReceived(int id, const QVariantMap &rsp);

private:
    int m_requestId;
    QString m_mediaType;
};

#endif // SHARES_H
