#!/bin/bash

if [ ! -f "openssl.cnf" ];
then
    echo "download openssl.cnf"
    wget "https://tool.hejianpeng.cn/Linux/openssl.cnf"
    
fi
echo
if [ $# -gt 0 ]
then
	echo "****** " $* " Doname Certificate ******";
    echo
    if [ ! -d "ca" ];
    then 
        echo "no found dir ca"
        eval $0
        eval $0 $*
        exit 1
    fi

    cp openssl.cnf ca/openssl.cnf
    cd ca 
    #cat /proc/sys/kernel/random/uuid  | md5sum |cut -c 1-16 >demoCA/serial
    date +%s%N | md5sum |cut -c 1-20 > demoCA/serial
    sed -i "s/YouCommonName/$*/g" openssl.cnf
    openssl genrsa -out t.key 2048
    openssl req -batch -new -key t.key -out t.csr -config openssl.cnf -extensions v3_req
    startdate=`date --date='888 hour ago' '+%Y%m%d%H%M%S'`
    eval "openssl ca -in t.csr -out t.crt -cert ca.crt -keyfile ca.key -extensions v3_req -startdate ${startdate}Z -days 480 -config openssl.cnf"
    eval "mv t.key $*.key && mv t.crt $*.crt && mv t.csr $*.csr"
    rm -f openssl.cnf
    cd ../
	exit 1
fi

echo   "****** CA Certificate ******";
echo
rm -rf ca 
mkdir ca 
cd ca
mkdir demoCA
cd demoCA
mkdir newcerts cers private crl
touch index.txt
echo 00 > serial
cd ../
openssl genrsa -out ca.key 2048

#sed -i "s/YouCommonName/DST Root CA X2/g" openssl.cnf
#openssl genrsa -out ca.key 2048
#openssl req -new -out ca.csr -key ca.key -batch -config openssl.cnf
date -s 20050101
date -s 08:00:00
eval "openssl req -new -x509 -days 9131 -key ca.key -out ca.crt -subj \"/O=Digital Signature Trust Co./CN=DST Root CA X2\""
#openssl x509 -req -days 9131 -in ca.csr -signkey ca.key -out ca.crt
ntpdate -u time3.cloud.tencent.com
	echo "****** Warning ******";
echo "The current system time is"
date
echo "Please confirm whether it is consistent with the current time!!!"
echo "Press any key to continue"
read
#rm -f openssl.cnf 
cd ../