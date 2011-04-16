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

#include "settingsdialog.h"

#include <QGridLayout>
#include <QDialogButtonBox>
#include <QStandardItemModel>
#include <QLabel>

SettingsDialog::SettingsDialog(QWidget *parent) :
    QDialog(parent)
{

    setWindowTitle("XbmcRemote - " + tr("Settings"));
    QHBoxLayout *hLayout = new QHBoxLayout();
    setLayout(hLayout);

//    QVBoxLayout *layout = new QVBoxLayout();
//    hLayout->addLayout(layout);

    hLayout->addWidget(new QLabel("Host:"));

    m_hostName = new QLineEdit();
    hLayout->addWidget(m_hostName);



    QDialogButtonBox *buttonBox = new QDialogButtonBox(QDialogButtonBox::Ok | QDialogButtonBox::Cancel, Qt::Vertical);
    hLayout->addWidget(buttonBox);

    connect(buttonBox, SIGNAL(accepted()), this, SLOT(accept()));
    connect(buttonBox, SIGNAL(rejected()), this, SLOT(reject()));
}

void SettingsDialog::setHostname(const QString &hostname)
{
    m_hostName->setText(hostname);
}

QString SettingsDialog::hostname()
{
    return m_hostName->text();
}