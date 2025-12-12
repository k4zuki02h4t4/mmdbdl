#!/bin/bash

set -e

# Config
# You can see your Account id and license key information on https://www.maxmind.com/en/accounts/current/license-key.
readonly ACCOUNT_ID=${1}
readonly LICENSE_KEY=${2}
readonly MMDB_DIR=${HOME}/mmdb

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Please run this script with sudo or root privileges." >&2
    exit 1
fi

if [ -z "${ACCOUNT_ID}" ]; then
    echo "ERROR: EMPTY ACCOUNT ID (ARGS 1)." >&2
    exit 1
fi

if [ -z "${LICENSE_KEY}" ]; then
    echo "ERROR: EMPTY LICENSE KEY (ARGS 2)." >&2
    exit 1
fi

# mmdb 保存ディレクトリを作成
rm -rf ${MMDB_DIR}
mkdir -p ${MMDB_DIR}

# ディレクトリを移動
cd ${MMDB_DIR}

# mmdb ファイルをダウンロード
curl --fail-with-body -L -u ${ACCOUNT_ID}:${LICENSE_KEY} \
-o GeoLite2-ASN.tar.gz     'https://download.maxmind.com/geoip/databases/GeoLite2-ASN/download?suffix=tar.gz' \
-o GeoLite2-City.tar.gz    'https://download.maxmind.com/geoip/databases/GeoLite2-City/download?suffix=tar.gz' \
-o GeoLite2-Country.tar.gz 'https://download.maxmind.com/geoip/databases/GeoLite2-Country/download?suffix=tar.gz'

# mmdb ファイルをダウンロードできているかの確認
if [ ! -e "${MMDB_DIR}/GeoLite2-ASN.tar.gz" ]; then
    echo "ERROR: Failed to download GeoLite2-ASN.tar.gz."
    exit 1
fi
if [ ! -e "${MMDB_DIR}/GeoLite2-City.tar.gz" ]; then
    echo "ERROR: Failed to download GeoLite2-City.tar.gz."
    exit 1
fi
if [ ! -e "${MMDB_DIR}/GeoLite2-Country.tar.gz" ]; then
    echo "ERROR: Failed to download GeoLite2-Country.tar.gz."
    exit 1
fi

# tar.gz ファイルを展開後削除
for f in *.tar.gz; do tar -zxvf "$f"; rm -rf "$f"; done

# mmdb ファイルを移動
cp */*.mmdb .

# mmdb ファイルを抜き取ったディレクトリを削除
find . -mindepth 1 -type d | xargs rm -rf

exit 0
