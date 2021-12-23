#!/bin/bash

#DEFINIR COUNTRY
COUNTRY=Chile
COUNTRY_CODE=CL
PASSWORD=dgcg-p4ssw0rd

mkdir $COUNTRY_CODE


# tls = cert_upload
# AUTHORIZATION
openssl req -x509 -new -days 365 -newkey ec:<(openssl ecparam -name prime256v1) -utf8 \
            -keyout $COUNTRY_CODE/key_auth.pem -extensions ext -config tls.conf -nodes -out $COUNTRY_CODE/cert_auth.pem;


# UPLOAD
openssl req -x509 -new -days 365 -newkey ec:<(openssl ecparam -name prime256v1) -extensions ext \
            -keyout $COUNTRY_CODE/key_upload.pem -nodes -out $COUNTRY_CODE/cert_upload.pem  -config upload.conf -utf8;

# CSCA
openssl req -x509 -new -days 1461 -newkey ec:<(openssl ecparam -name prime256v1) -extensions ext \
                 -keyout $COUNTRY_CODE/key_csca.pem -nodes -out $COUNTRY_CODE/cert_csca.pem -config csca.conf -utf8;

#LLAVES CREDENCIAL
openssl req -newkey ec:<(openssl ecparam -name prime256v1) -keyout $COUNTRY_CODE/DSC01privkey.key -nodes -out $COUNTRY_CODE/DSC01csr.pem -utf8 \
-subj "/C=$COUNTRY_CODE/O=Gobierno de $COUNTRY/OU=Ministerio de Salud/CN=Gestión de Credencial de Inmunización";

openssl x509 -req -in $COUNTRY_CODE/DSC01csr.pem -CA $COUNTRY_CODE/cert_csca.pem -CAkey $COUNTRY_CODE/key_csca.pem -CAcreateserial -days 730 \
                    -extensions ext -extfile dsc.conf -out $COUNTRY_CODE/DSCcert.pem;

# SIGNER KEYSTORE
openssl pkcs12 -export -in $COUNTRY_CODE/DSCcert.pem -inkey $COUNTRY_CODE/DSC01privkey.key -passout pass:$PASSWORD -name "firmador" -out $COUNTRY_CODE/firmasalud.p12 -name firmasalud;

keytool -importkeystore -deststorepass ${PASSWORD} -srcstorepass ${PASSWORD} -alias firmasalud -srckeystore $COUNTRY_CODE/firmasalud.p12 -destkeystore $COUNTRY_CODE/firmasalud.jks;

# SIGNED DSC CMS
openssl x509 -outform der -in $COUNTRY_CODE/DSCcert.pem -out $COUNTRY_CODE/cert.der

openssl cms -sign -nodetach -in $COUNTRY_CODE/cert.der -signer $COUNTRY_CODE/cert_upload.pem -inkey $COUNTRY_CODE/key_upload.pem -out $COUNTRY_CODE/signed.der -outform DER -binary

openssl base64 -in $COUNTRY_CODE/signed.der -out $COUNTRY_CODE/cms.b64 -e -A

# TLS KEYSTORE
openssl pkcs12 -export -in $COUNTRY_CODE/cert_auth.pem -inkey $COUNTRY_CODE/key_auth.pem -name "tls_key" -passout pass:$PASSWORD -out $COUNTRY_CODE/tls_key_store.p12;
#
# UPLOAD KEYSTORE
openssl pkcs12 -export -in $COUNTRY_CODE/cert_upload.pem -inkey $COUNTRY_CODE/key_upload.pem -name "upload_key" -passout pass:$PASSWORD -out $COUNTRY_CODE/upload_key_store.p12;
#
# TLS TRUSTSTORE
keytool -import -trustcacerts -deststorepass $PASSWORD -alias tls_trust -storetype PKCS12 -file $COUNTRY_CODE/cert_csca.pem -noprompt -keystore $COUNTRY_CODE/tls_trust_store.pk12;
#
# NATIONAL TRUSTSTORE
keytool -import -trustcacerts -deststorepass $PASSWORD -alias national_trust -storetype PKCS12 \
                -file $COUNTRY_CODE/cert_csca.pem -noprompt -keystore $COUNTRY_CODE/tls_trust_store.p12;
#
openssl req -x509 -newkey ec:<(openssl ecparam -name prime256v1) rsa:4096 -keyout key_ta.pem -out cert_ta.pem -days 365 -nodes -config upload.conf -utf8
#
openssl req -x509 -new -days 365 -newkey ec:<(openssl ecparam -name prime256v1) -extensions ext \
            -keyout key_ta.pem -nodes -out cert_ta.pem  -config ta.conf -utf8;

# TRUST ANCHOR KEY STORE
keytool -import -file cert_ta.pem -noprompt -storepass $PASSWORD -alias trustanchor -keystore ta.jks


# SIGNED DSC CMS
openssl x509 -outform der -in $COUNTRY_CODE/DSCcert.pem -out $COUNTRY_CODE/cert.der

openssl cms -sign -nodetach -in $COUNTRY_CODE/cert.der -signer $COUNTRY_CODE/cert_upload.pem -inkey $COUNTRY_CODE/key_upload.pem -out $COUNTRY_CODE/signed.der -outform DER -binary

openssl base64 -in $COUNTRY_CODE/signed.der -out $COUNTRY_CODE/cms.b64 -e -A
