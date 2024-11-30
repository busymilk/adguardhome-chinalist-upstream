#!/bin/bash
set -e
SYSTEMD=0

DATE=`date '+%T'`
echo "$DATE: IPv4 connection testing..."

if ping -c 3 "223.6.6.6" > /dev/null 2>&1; then
	IPv4="true"
fi
if [[ $SYSTEMD == 1 ]]; then
    echo "IPv6 connection testing..."
else
    echo "$DATE: IPv6 connection testing..."
fi
if ping -c 3 "2400:3200:baba::1" > /dev/null 2>&1; then
	IPv6="true"
fi
if [[ $IPv4 == "true" ]]; then
	if [[ $IPv6 == "true" ]]; then
		if [[ $SYSTEMD == 1 ]]; then
			echo "IPv4 and IPv6 connections both available."
		else
			echo "$DATE: IPv4 and IPv6 connections both available."
		fi
		curl -o "/tmp/default.upstream" https://gitlab.com/fernvenue/adguardhome-upstream/-/raw/master/v6.conf > /dev/null 2>&1
	else
		if [[ $SYSTEMD == 1 ]]; then
			echo "Only IPv4 connection available."
		else
			echo "$DATE: Only IPv4 connection available."
		fi
		curl -o "/tmp/default.upstream" https://gitlab.com/fernvenue/adguardhome-upstream/-/raw/master/v4.conf > /dev/null 2>&1
	fi
else
	if [[ $IPv6 == "true" ]]; then
		if [[ $SYSTEMD == 1 ]]; then
			echo "Only IPv6 connection available."
		else
			echo "$DATE: Only IPv6 connection available."
		fi
		curl -o "/tmp/default.upstream" https://gitlab.com/fernvenue/adguardhome-upstream/-/raw/master/v6only.conf > /dev/null 2>&1
	else
		if [[ $SYSTEMD == 1 ]]; then
			echo "No available network connection was detected, please try again."
		else
			echo "$DATE: No available network connection was detected, please try again."
		fi
		exit 1
	fi
fi
if [[ $SYSTEMD == 1 ]]; then
    echo "Getting data updates..."
else
    echo "$DATE: Getting data updates..."
fi
curl -s https://gitlab.com/fernvenue/chn-domains-list/-/raw/master/CHN.ALL.agh | sed "/#/d" > "/tmp/chinalist.upstream"
if [[ $SYSTEMD == 1 ]]; then
    echo "Processing data format..."
else
    echo "$DATE: Processing data format..."
fi
cat "/tmp/default.upstream" "/tmp/chinalist.upstream" > /usr/share/adguardhome.upstream
if [[ $IPv4 == "true" ]]; then
	sed -i "s|114.114.114.114|h3://223.5.5.5:443/dns-query h3://223.6.6.6:443/dns-query|g" /usr/share/adguardhome.upstream
else
	sed -i "s|114.114.114.114|2400:3200::1 2400:3200:baba::1|g" /usr/share/adguardhome.upstream
fi
if [[ $SYSTEMD == 1 ]]; then
    echo "Cleaning..."
else
    echo "$DATE: Cleaning..."
fi
rm /tmp/*.upstream
if [[ $SYSTEMD == 1 ]]; then
    echo "Restarting AdGuardHome service..."
else
    echo "$DATE: Restarting AdGuardHome service..."
fi
systemctl restart AdGuardHome
if [[ $SYSTEMD == 1 ]]; then
    echo "All finished!"
else
    echo "$DATE: All finished!"
fi
