#!/bin/bash
set -e

DATE=`date '+%T'`


curl -o "/tmp/default.upstream" https://raw.gitmirror.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/dns_for_default > /dev/null 2>&1

echo "$DATE: Getting data updates..."
curl -o /tmp/chinalist.upstream https://raw.gitmirror.com/felixonmars/dnsmasq-china-list/refs/heads/master/accelerated-domains.china.conf

echo "$DATE: Processing data format..."
cat "/tmp/default.upstream" "/tmp/chinalist.upstream" > /usr/share/adguardhome.upstream
sed -i  "s|server=|[|g" /usr/share/adguardhome.upstream
sed -i  "s|/114|/]114|g" /usr/share/adguardhome.upstream

response=$(curl -s https://raw.gitmirror.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/dns_only_for_china.conf)
sed -i "s|114.114.114.114|$response|g" /usr/share/adguardhome.upstream

echo "$DATE: Cleaning..."
rm /tmp/*.upstream

echo "$DATE: Restarting AdGuardHome service..."
AdGuardHome -s restart
echo "$DATE: All finished!"
