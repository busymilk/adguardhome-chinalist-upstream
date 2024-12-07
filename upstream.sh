#!/bin/bash
set -e

DATE=`date '+%T'`

echo "$DATE: Getting data updates...1"
curl -o "/tmp/default.upstream" https://raw.githubusercontent.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/dns_for_default > /dev/null 2>&1

echo "$DATE: Getting data updates...1.5"
curl -o "/tmp/special.upstream" https://raw.githubusercontent.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/dns_for_special > /dev/null 2>&1


echo "$DATE: Getting data updates...2"
curl -o /tmp/chinalist.upstream https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/refs/heads/master/accelerated-domains.china.conf

echo "$DATE: Processing data format...3"
cat "/tmp/default.upstream" "/tmp/special.upstream" "/tmp/chinalist.upstream" > /usr/share/adguardhome.upstream
sed -i  "s|server=|[|g" /usr/share/adguardhome.upstream
sed -i  "s|/114|/]114|g" /usr/share/adguardhome.upstream

response=$(curl -s https://raw.githubusercontent.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/dns_only_for_china.conf)
sed -i "s|114.114.114.114|$response|g" /usr/share/adguardhome.upstream

echo "$DATE: Cleaning...4"
rm /tmp/*.upstream

echo "$DATE: Restarting AdGuardHome service..."
AdGuardHome -s restart
echo "$DATE: All finished!"
