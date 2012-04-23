/*****************************************************************************
 * Copyright: 2011 Michael Zanetti <mzanetti@kde.org>                        *
 *                                                                           *
 * This program is free software: you can redistribute it and/or modify      *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * This program is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/

#include "songs.h"
#include "audioplayer.h"
#include "audioplaylist.h"
#include "audioplaylistitem.h"
#include "xbmc.h"
#include "xbmcconnection.h"
#include "libraryitem.h"
#include "xbmcdownload.h"

Songs::Songs(int artistid, int albumid, XbmcModel *parent):
    XbmcLibrary(parent),
    m_artistId(artistid),
    m_albumId(albumid)
{
    connect(XbmcConnection::notifier(), SIGNAL(responseReceived(int,QVariantMap)), SLOT(responseReceived(int,QVariantMap)));
}

Songs::~Songs()
{
    qDebug() << "deleting songs model";
}

void Songs::refresh()
{
    QVariantMap params;
    if(m_artistId != -1) {
      params.insert("artistid", m_artistId);
    }
    if(m_albumId != -1) {
      params.insert("albumid", m_albumId);
    }
    QVariantList properties;
    properties.append("artist");
    properties.append("album");
    properties.append("thumbnail");
    properties.append("file");

    params.insert("properties", properties);

    QVariantMap sort;
    if(m_albumId == -1) {
        sort.insert("method", "label");
    } else {
        sort.insert("method", "track");
    }
    sort.insert("order", "ascending");
    params.insert("sort", sort);
    m_requestList.insert(XbmcConnection::sendCommand("AudioLibrary.GetSongs", params), RequestList);
}

void Songs::fetchItemDetails(int index)
{
    QVariantMap params;
    params.insert("songid", m_list.at(index)->data(RoleSongId).toInt());

    QVariantList properties;
//    properties.append("title");
//    properties.append("artist");
//    properties.append("albumartist");
    properties.append("genre");
    properties.append("year");
    properties.append("rating");
//    properties.append("album");
//    properties.append("track");
    properties.append("duration");
    properties.append("comment");
//    properties.append("lyrics");
//    properties.append("musicbrainztrackid");
//    properties.append("musicbrainzartistid");
//    properties.append("musicbrainzalbumid");
//    properties.append("musicbrainzalbumartistid");
    properties.append("playcount");
//    properties.append("fanart");
//    properties.append("thumbnail");
//    properties.append("file");
//    properties.append("artistid");
//    properties.append("albumid");

    params.insert("properties", properties);

    connect(XbmcConnection::notifier(), SIGNAL(responseReceived(int,QVariantMap)), SLOT(responseReceived(int,QVariantMap)));
    int id = XbmcConnection::sendCommand("AudioLibrary.GetSongDetails", params);
    m_requestList.insert(id, RequestDetails);
    m_detailsRequestMap.insert(id, index);
}

void Songs::download(int index, const QString &path)
{
    LibraryItem *item = qobject_cast<LibraryItem*>(m_list.at(index));

    QString destination = path + "/Music/" + item->artist() + '/' + item->album() + '/' + item->title() + '.' + item->fileName().split('.').last();
    qDebug() << "should download" << destination;

    XbmcDownload *download = new XbmcDownload();
    download->setDestination(destination);
    download->setIconId("icon-m-content-audio");
    download->setLabel(item->title());

    startDownload(index, download);
}

void Songs::responseReceived(int id, const QVariantMap &rsp)
{
    if(!m_requestList.contains(id)) {
        return;
    }

    switch(m_requestList.value(id)) {
    case RequestList: {
        QList<XbmcModelItem*> list;
    //    qDebug() << "got songs:" << rsp.value("result");
        QVariantList responseList = rsp.value("result").toMap().value("songs").toList();
        foreach(const QVariant &itemVariant, responseList) {
            QVariantMap itemMap = itemVariant.toMap();
            LibraryItem *item = new LibraryItem();
            item->setTitle(itemMap.value("label").toString());
            item->setSubtitle(itemMap.value("artist").toString() + " - " + itemMap.value("album").toString());
            item->setArtist(itemMap.value("artist").toString());
            item->setAlbum(itemMap.value("album").toString());
            item->setSongId(itemMap.value("songid").toInt());
            item->setThumbnail(itemMap.value("thumbnail").toString());
            item->setFileName(itemMap.value("file").toString());
            item->setIgnoreArticle(false); // Ignoring article here...
            item->setFileType("file");
            item->setPlayable(true);
            list.append(item);
        }
        beginInsertRows(QModelIndex(), 0, list.count() - 1);
        foreach(XbmcModelItem *item, list) {
            m_list.append(item);
        }
        endInsertRows();
        setBusy(false);
        }
        break;
    case RequestDetails:
        qDebug() << "got item details:" << rsp;
        LibraryItem *item = qobject_cast<LibraryItem*>(m_list.at(m_detailsRequestMap.value(id)));
        QVariantMap details = rsp.value("result").toMap().value("songdetails").toMap();
        item->setYear(details.value("year").toString());
        item->setRating(details.value("rating").toInt());
        item->setDuration(QTime().addSecs(details.value("duration").toInt()));
        item->setComment(details.value("comment").toString());
        item->setPlaycount(details.value("playcount").toInt());
        emit dataChanged(index(m_detailsRequestMap.value(id), 0, QModelIndex()), index(m_detailsRequestMap.value(id), 0, QModelIndex()));
    }
}

XbmcModel* Songs::enterItem(int index)
{
    Q_UNUSED(index)
    qDebug() << "Cannot enter song items. Use playItem() to play it";
    return 0;
}

void Songs::playItem(int row)
{
    AudioPlaylistItem pItem;
    if(m_artistId == -1 && m_albumId == -1) {
        pItem.setSongId(index(row, 0, QModelIndex()).data(RoleSongId).toInt());
    } else if(m_albumId == -1){
        pItem.setArtistId(m_artistId);
    } else {
        pItem.setAlbumId(m_albumId);
    }
    Xbmc::instance()->audioPlayer()->playlist()->clear();
    Xbmc::instance()->audioPlayer()->playlist()->addItems(pItem);
//    Xbmc::instance()->audioPlayer()->playlist()->playItem(row);
    Xbmc::instance()->audioPlayer()->playItem(row);
}

void Songs::addToPlaylist(int row)
{
    AudioPlaylistItem pItem;
    pItem.setSongId(index(row, 0, QModelIndex()).data(RoleSongId).toInt());
    Xbmc::instance()->audioPlayer()->playlist()->addItems(pItem);
}

QString Songs::title() const
{
    return tr("Songs");
}
