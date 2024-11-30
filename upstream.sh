#!/bin/bash
set -e

DATE=`date '+%T'`


curl -o "/tmp/default.upstream" https://raw.gitmirror.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/v6.conf > /dev/null 2>&1

echo "$DATE: Getting data updates..."
curl -o /tmp/chinalist.upstream https://raw.gitmirror.com/felixonmars/dnsmasq-china-list/refs/heads/master/accelerated-domains.china.conf

echo "$DATE: Processing data format..."
cat "/tmp/default.upstream" "/tmp/chinalist.upstream" > /usr/share/adguardhome.upstream
sed -i  "s|server=|[|g" /usr/share/adguardhome.upstream
sed -i  "s|/114|/]114|g" /usr/share/adguardhome.upstream

sed -i "s|114.114.114.114|https://223.5.5.5/dns-query https://1.12.12.12/dns-query https://doh.360.cn/dns-query https://doh.apad.pro/dns-query|g" /usr/share/adguardhome.upstream

echo "$DATE: Cleaning..."
rm /tmp/*.upstream

echo "$DATE: Restarting AdGuardHome service..."
AdGuardHome -s restart
echo "$DATE: All finished!"
