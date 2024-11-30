#!/bin/bash
set -e

DATE=`date '+%T'`

echo "$DATE: IPv4 connection testing..."
if ping -c 3 "223.6.6.6" > /dev/null 2>&1; then
	IPv4="true"
fi

echo "$DATE: IPv6 connection testing..."
if ping -c 3 "2400:3200:baba::1" > /dev/null 2>&1; then
	IPv6="true"
fi
if [[ $IPv4 == "true" ]]; then
	if [[ $IPv6 == "true" ]]; then
		echo "$DATE: IPv4 and IPv6 connections both available."
		curl -o "/tmp/default.upstream" https://raw.gitmirror.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/v6.conf > /dev/null 2>&1
	else
		echo "$DATE: Only IPv4 connection available."
		curl -o "/tmp/default.upstream" https://raw.gitmirror.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/v4.conf > /dev/null 2>&1
	fi
else
	if [[ $IPv6 == "true" ]]; then
		echo "$DATE: Only IPv6 connection available."
		curl -o "/tmp/default.upstream" https://raw.gitmirror.com/busymilk/adguardhome-chinalist-upstream/refs/heads/master/v6only.conf > /dev/null 2>&1
	else
		echo "$DATE: No available network connection was detected, please try again."
		exit 1
	fi
fi

echo "$DATE: Getting data updates..."
curl -o /tmp/chinalist.upstream https://raw.gitmirror.com/felixonmars/dnsmasq-china-list/refs/heads/master/accelerated-domains.china.conf
echo "$DATE: Processing data format..."
sed -i  "s|server=|[|g" /usr/share/adguardhome.upstream
sed -i  "s|/114|/]|g" /usr/share/adguardhome.upstream
cat "/tmp/default.upstream" "/tmp/chinalist.upstream" > /usr/share/adguardhome.upstream
if [[ $IPv4 == "true" ]]; then
	sed -i "s|114.114.114.114|https://223.5.5.5/dns-query https://1.12.12.12/dns-query https://doh.360.cn/dns-query https://doh.apad.pro/dns-query|g" /usr/share/adguardhome.upstream
else
	sed -i "s|114.114.114.114|https://2400:3200:baba::1/dns-query https://dns.ipv6dns.com/dns-query https://doh.apad.pro/dns-query|g" /usr/share/adguardhome.upstream
fi
echo "$DATE: Cleaning..."
rm /tmp/*.upstream
echo "$DATE: Restarting AdGuardHome service..."
AdGuardHome -s restart
echo "$DATE: All finished!"
