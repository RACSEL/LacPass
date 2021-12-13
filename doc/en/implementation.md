# Implementation

This section describes the steps that need to be taken for a new participating country to be included in LACPASS.

**Technologies**
The “EU Digital Covid Certificates” (EUDCC) repositories provide APIs that are developed in the Spring Framework using Java as the primary programming language. The databases used are Mysql and Postgresql. The certificate issuance web application is developed in React. And the mobile apps are natively developed on Kotlin (Android) and Swift (iOS). All projects except mobile apps are available through Docker.

**Server Requirements**
A server is required which will host the web services repositories. The characteristics of this server will depend on the estimated traffic, but a server with at least 4 vCPUs, 8 Gb of RAM and 50 Gb of disk is recommended.

A server is required which will host the web services repositories. The characteristics of this server will depend on the estimated traffic, but a server with at least 4 vCPUs, 8 Gb of RAM and 50 Gb of disk is recommended.

**Pre-requirements**
The steps to follow to create each of the EUDCC repositories will be given below. Pre requirements:

-   OpenJDK 11
-   Maven
-   Authenticate with [Github Packages](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-apache-maven-registry)
-   Docker (optional)
-   Docker-compsoe (optional)
-   Node 14
-   OpenSSL
-   [DGC-CLI](https://github.com/eu-digital-green-certificates/dgc-cli)

In order to install the dependencies through Maven in the repositories that use Spring as technology, you need to be authenticated by Github. For this you need to create a [personal access token](https://github.com/settings/tokens), which has the option "read: packages" selected. Then you must fill in the maven configuration file (in linux located in ~/.m2/settings.xml) like the one shown below:

```XML
<?xml version="1.0" encoding="UTF-8"?>  
<settings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  xmlns="http://maven.apache.org/SETTINGS/1.0.0" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">  
  <interactiveMode>false</interactiveMode>  
    <servers>  
      <server>  
        <id>dgc-github</id>  
        <username>$USER</username>  
        <password>$TOKEN</password>  
      </server>  
      <server>  
        <id>ehd-github</id>  
        <username>$USER</username>  
        <password>$TOKEN</password>  
      </server>  
    </servers>  
</settings>
```
## [Gateway](https://github.com/eu-digital-green-certificates/dgc-gateway)

The gateway is used to share and verify information through all the countries connected to it. Therefore, it should not be included in the backend of each country, here it is explained how to set up a gateway only in order to be able to test the connection of other services. The repository can be cloned using:

```bash
$ git clone https://github.com/eu-digital-green-certificates/dgc-gateway
```
**Keys**
To run it locally you need to create a TrustAnchor. The TrustAnchor is used to sign entries in the database. To create the TrustAnchor the following command is used:

```bash
$ openssl req -x509 -newkey rsa:4096 -keyout key_ta.pem -out cert_ta.pem -days 365 -nodes
```

Then the public key is exported to the Java Keystore using:

```bash
$ keytool -importcert -alias dgcg_trust_anchor -file cert_ta.pem -keystore ta.jks -storepass dgcg-p4ssw0rd
```

Where "cert_ta.pem" is the public key and "dcg-p4ssw0rd" is the password of the public key. This "ta.jks" key must be placed in a folder named "certs", which must be created in the root of the repository.

**Database**
This repository uses a MySql database, if docker is not used to build the project, you need to install and create a base in MySql.

**Configuration**
To configure variables such as the directory of the public key and the connection to the database, it can be done in two ways. If Docker is used to run the project, the environment variables shown in "docker-compose.yml" can be edited. For more details on this file, the documentation is available at the following link. If docker is not used, you can edit the Spring configuration file in "~/dgc-gateway/src/main/resources/application.yml"

**Execute**
To build the project executable, through Maven, use the following command:

```bash
$ mvn clean install
```

If docker is used to run the project, an extra flag must be added to the previous command:

```bash
$ mvn clean install -P docker
```

This will create a "jar" file in the "~/dgc-gateway/target" directory. To run the application you use:

```bash
$ java -jar target/dgc-gateway-latest.jar
```

And if you use Docker, you can use:

```bash
$ docker-compose up --build
```
Which will upload the gateway API along with a mysql database. In order to query the API of this gateway, it is necessary to register certain certificates that belong to the backend of each country. These certificates will be from AUTHENTICATION, UPLOAD and CSCA. For this, these certificates can be created with OpenSSL:

```bash
# AUTHENTICATION
$ openssl req -x509 -newkey rsa:4096 -keyout key_auth.pem -out cert_auth.pem -days 365 -nodes

# CSCA  
$ openssl req -x509 -newkey rsa:4096 -keyout key_csca.pem -out cert_csca.pem -days 365 -nodes  

# UPLOAD
$ openssl req -x509 -newkey rsa:4096 -keyout key_upload.pem -out cert_upload.pem -days 365 -nodes
```

These certificates must be signed by the TrustAnchor of the gateway (“cert_ta.pem” and “key_ta.pem”), for this the client provided by the EUDCC can be used. This can be downloaded at this link. Then using this jar, the following commands can be executed:

```bash
$ java -jar dgc-cli.jar ta sign -c cert_ta.pem -k key_ta.pem -i cert_auth.pem  
$ java -jar dgc-cli.jar ta sign -c cert_ta.pem -k key_ta.pem -i cert_csca.pem  
$ java -jar dgc-cli.jar ta sign -c cert_ta.pem -k key_ta.pem -i cert_upload.pem
```
In each of these commands a "TrustAnchor Signature", "Certificate Raw Data", "Certificate Thumbprint" and "Certificate Country" will be delivered. These values have to be entered in the "trusted_party" table of the gateway database, so three new lines will be added in this table (for each of the certificates). This can be done using:

```bash
$ mysql --user=root --password=admin dgc  
$ INSERT INTO trusted_party (created_at, country, thumbprint, raw_data, signature, certificate_type)  
SELECT  
  NOW() as created_at,  
  'CL' as country,  
  '{Certificate_Thumbprint}' as thumbprint,  
  '{Certificate_Raw_Data}' as raw_data,  
  '{TrustAnchor_Signature}' as signature,  
  '{AUTHENTICATION|UPLOAD|CSCA}' as certificate_type;
```
To test that the values were entered correctly, a request can be made to the gateway API using the authentication thumbprint:

```bash
$ curl -X GET http://localhost:8080/trustList -H "accept: application/json" -H "X-SSL-Client-SHA256: $THUMBPRINT" -H "X-SSL-Client-DN: C=$COUNTRY"
```

Which should deliver the list of certificates in the table "trusted_parties".

## [Business rule](https://github.com/eu-digital-green-certificates/dgca-businessrule-service)

This repository contains a backend with the business rules to accept/reject the states of the COVID certificates issued by the countries. The repository can be cloned using:

```bash
$ git clone https://github.com/eu-digital-green-certificates/dgca-businessrule-service
```

**Keys**
This repository requires three keys, a trust_anchor, trust_store, and key_store. The trust_anchor is the TrustAnchor created in the gateway, the trust_store can be created using the certificate and authentication key that were registered in the gateway as follows:

```bash
$ openssl pkcs12 -export -in cert_auth.pem -inkey key_auth.pem -name 1 -out tls_key_store.p12
```

The truststore is created using the authentication certificate, with the command:

```bash
$ openssl pkcs12 -export -in cert_auth.pem -name tls_trust -out tls_trust_store.p12 -nokeys
```

**Database**
This repository uses a Postgresql database, if docker is not used to build the project, you need to install and create a Postgresql database.

**Configurations**
To configure variables such as the directory of the keys and the connection to the database, it can be done in two ways. If Docker is used to run the project, the environment variables shown in "docker-compose.yml" can be edited. For more details on this file, the documentation is available at the following link. If docker is not used, you can edit the Spring configuration file in "~/dgc-gateway/src/main/resources/application.yml". The most important variables are shown below:

```yml
# Credentials database
SPRING_DATASOURCE_URL=<CONNECTION_URL>
SPRING_DATASOURCE_USERNAME=<USER>
SPRING_DATASOURCE_PASSWORD=<PASSWORD>

# Gateway endpoint
DGC_GATEWAY_CONNECTOR_ENDPOINT=https://test-dgcg-ws.tech.ec.europa.eu

# Certificates
DGC_GATEWAY_CONNECTOR_TLSTRUSTSTORE_PATH=<PATH>
DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_ALIAS=<ALIAS>
DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_PATH=<PATH>
DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_PASSWORD=<PASSWORD>
DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_ALIAS=<ALIAS>
DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_PATH=<PATH>
DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_PASSWORD=<PASSWORD>
```

**Run**
To build the project executable, which is built through Maven, the following command is used:

```bash
$ mvn clean install
```

This will create a "jar" file in the "~/dgc-businessrule-service/target" directory. To run the application you use:

```bash
$ java -jar target/dgc-businessrule-service-latest.jar
```

And if you use Docker, you can use:

```bash
$ docker-compose up --build
```

**Rules**
This section briefly explains how to generate a JSON file with the certificate validation rules. These rules determine if a person who enters a country is considered suitable to enter this country, the rules are based on the vaccines administered, the tests they have performed and the state of recovery after contracting COVID. All these rules must be encoded according to the standards of the Digital COVID Certificate.

To generate the validation rules it is required to generate a json with the following:

-   Valid as a [CertLogic](https://github.com/ehn-dcc-development/dgc-business-rules/blob/main/certlogic/specification/README.md) expression.
-   The JSON file of every rule is validated against this [JSON Schema](https://github.com/ehn-dcc-development/ehn-dcc-schema/blob/release/1.3.0/DCC.combined-schema.json).
-   The specified AffectedFields field is checked against the fields of the DCC payload accessed from the Logic field. ([DCC Schema](https://github.com/ehn-dcc-development/ehn-dcc-schema/blob/release/1.3.0/DCC.combined-schema.json))

CertLogic is a semantics subset that extends the [JsonLogic](https://jsonlogic.com/) semantics. These semantics use intuitive and simple rules to be able to verify patterns or logic within a Json file. They use logical operators such as equality ("=="), numeric operators, and so on. These operators can be found [here](https://jsonlogic.com/operations.html).

Here is an example of how a Json is constructed with the CertLogic semantics:

```json
{
  "<operation id>": [
     <operand 1>,
     <operand 2>,
     // ...
     <operand n>
  ]
}
```

Now to generate a file with the correct [standards](https://github.com/eu-digital-green-certificates/dgc-gateway/blob/main/src/main/resources/validation-rule.schema.json), the scheme must be followed correctly, for this the following fields must be added:

-   **AffectedFields**: Arrangement of rules to be used from the payload (QR).
-   **Country**: ISO country code. (e.g. "CL").
-   **CertificateType**: Certificate type. Valid values are "General", "Test", "Vaccination", "Recovery". If, for example, the rule looks for the minimum time after a COVID test, this certificate is of the "Recovery" type.
-   **Description**: Fix with the description of the rule, here all the languages that you want to support are added.
-   **Engine**: Type of semantics used. (e.g. "CERTLOGIC")
-   **EngineVersion**: Version of the semantics. Currently "1.2.2".
-   **Identifier**: Unique identifier for the rule. It must be the pattern "^(GR|VR|TR|RR|IR)-[A-Z]{2}-\\d{4}$". For example, if the rule is "Recovery", the country is Chile and it is also the first rule, the identifier is "RR-CL-0000".
-   **Logic**: Object where the rule is established. Here semantics are used to define the rule.
-   **SchemaVersion**: Version of the schema used.
-   **Type**: Type of the rule, it can be of acceptance (“Acceptance”) or invalidation (“Invalidation”).
-   **ValidFrom**: Until what date this rule is valid (without ms and with time zone).
-   **ValidTo**: From what date this rule is valid (without ms and with time zone).
- **Version**: Rule version

To better understand how this file is generated, it will be explained in a general way how to construct the “Logic” and “AffectedFields” fields. For the field "AffectedFields" it must be understood how the payload arrives (content of the QR), the content has a standard format that can be found at this [link](https://github.com/ehn-dcc-development/ehn-dcc-schema/blob/release/1.3.0/DCC.combined-schema.json). The payload object must contain at least one of the following fields:

-   **“v”**: Contains everything related to vaccination (“Vaccination Entry”).
-   **“t”**: Contains everything related to the tests performed (“Test Entry”).
-   **“r”**: Contains everything related to recovery (“Recovery Entry”).

Each of these fields can contain specific attributes to what it represents, we will detail in the following points what each one can contain.

**Vaccination Entry (“v”)**

-   tg: Disease or target agent.
-   vp: Vaccine or prophylaxis.
-   mp: Vaccine drug.
-   ma: Authorized marketing company or manufacturer.
-   dn: Dose Number.
-   sd: Total doses (Series of doses, for example would be 2 if two doses are required).
-   dt: Vaccination date.
-   co: Country of vaccination.
-   is: Certificate issuer.
-   ci: Unique identifier of the certificate (UVCI).

**Test Entry (“t”)**

-   tg: Disease or target agent.
-   tt: Type of test.
-   nm: Nucleic acid test.
-   ma: Rapid antigen test name and manufacturer.
-   sc: Date/Time of sample collection.
-   tr: Test result.
-   tc: Center in charge of the examination.
-   co: Test country.
-   is: Certificate issuer.
-   ci: Unique identifier of the certificate (UVCI).

**Recovery Entry (“r”)**

-   tg: Disease or target agent.
-   fr: Nucleic acid test first positive date.
-   co: Test Country.
-   is: Certificate issuer.
-   df: Date from which the exam is valid.
-   du: Date until when the exam is valid.
-   ci: Unique identifier of the certificate (UVCI).

There is an official document on the documentation of this standard, in this [link](https://ec.europa.eu/health/sites/default/files/ehealth/docs/covid-certificate_json_specification_en.pdf).

To better understand how the values are chosen, we will take as an example the rule "Vaccination series must be complete (eg 1/1, 2/2)". For this example the values of "AffectedFields" would be the following:

```json
"AffectedFields": [  
  "v.0", // Vaccination values are required.
  "v.0.dn", // Current dose.
  "v.0.sd" // Total number of doses in the series.
]
```

Now understanding how the "AffectedFields" is assembled, following the same example, we are going to build the logic of the rule: "The vaccination schedule must be complete (for example, 1/1, 2/2)". The first thing to note is that it is a vaccination rule so the “v” part of the payload is used. In addition, as it seeks to verify the vaccination series, both "dn" and "sd" will be used where we will obtain the information of the current dose and the total of doses required respectively. Then, to validate the complete vaccination scheme, it must be verified that both values are the same, as shown in the following scheme:

```json
"Logic": {
  "if": [ // If the content is met, the rule is accepted.  
    {
      "var": "payload.v.0" // Where to obtain the values is made explicit.
    },
    {
      "===": [ // The exact equality operator is used.
        {
          "var": "payload.v.0.dn" // Current Dose (Number in the series).
        },
        {
          "var": "payload.v.0.sd" // Total number of doses in the series.
        }
     }  
  ]
}
```

This example was taken from the rules of Spain [here](https://github.com/eu-digital-green-certificates/dgc-business-rules-testdata/blob/main/ES/VR-ES-0001/rule.json). If you need more examples you can see those recommended by the EU ([More examples](https://github.com/eu-digital-green-certificates/dgc-business-rules-testdata/tree/main/EU)).

## [Issuance](https://github.com/eu-digital-green-certificates/dgca-issuance-service)

This repository contains a backend that allows the issuance of vaccination certificates. The repository can be cloned using the following command:

```bash
$ git clone https://github.com/eu-digital-green-certificates/dgca-issuance-service
```

**Keys**
This project does not require creating new keys, the same ones previously created for the business rule will be used. In fact, instead of copying the keys between the repositories, it is recommended to have a directory where all the repositories share the keys and are shared through symbolic links or docker volumes.

**Database**
This repository uses a Postgresql database, if docker is not used to build the project, you need to install and create a Postgresql database.

**Configurations**
Like the business rule, the repository configuration is in the docker-compose.yml file, but you can also change the "src/main/resources/application.yml" file directly if you don't use docker.

The issuance service has two forms of execution: one for testing and the other connected to a gateway. Both are explained below:

**Testing Configuration**: This is the one that comes by default and is used to quickly test the issuance of certificates without having to install a gateway. No further configuration is required to operate in this mode and a generic test key is used to sign the certificates.

**Production Configuration**: This configuration connects to a gateway and allows interoperation with the other DGC services. To access this configuration you have to change the docker-compose.yml and add the following configurations to the backend:

```bash
backend:
  environment:
    ... # KEEP WHAT IS AND ADD THE FOLLOWING
    
    # EMISION DE CERTIFICADOS
    - ISSUANCE_DGCIPREFIX=URN:UVCI:V1:CL
    - ISSUANCE_KEYSTOREFILE=/app/certs/CL/firmasalud.jks
    - ISSUANCE_KEYSTOREPASSWORD=dgcg-p4ssw0rd
    - ISSUANCE_CERTALIAS=firmador
    - ISSUANCE_PRIVATEKEYPASSWORD=dgcg-p4ssw0rd
    - ISSUANCE_COUNTRYCODE=CL
    - ISSUANCE_EXPIRATION_VACCINATION=365
    - ISSUANCE_EXPIRATION_RECOVERY=365
    - ISSUANCE_EXPIRATION_TEST=60
    
    # SERVICIOS DISPONIBLES
    - ISSUANCE_ENDPOINTS_FRONTENDISSUING=true
    - ISSUANCE_ENDPOINTS_BACKENDISSUING=true
    - ISSUANCE_ENDPOINTS_TESTTOOLS=true
    - ISSUANCE_ENDPOINTS_WALLET=true
    - ISSUANCE_ENDPOINTS_PUBLISHCERT=true
    - ISSUANCE_ENDPOINTS_DID=true
    
    # CONFIGURACION DE GATEWAY
    - DGC_GATEWAY_CONNECTOR_ENABLED=true
    - DGC_GATEWAY_CONNECTOR_ENDPOINT=https://lacpass.example.com:3050
    - DGC_GATEWAY_CONNECTOR_PROXY_ENABLED=false
    - DGC_GATEWAY_CONNECTOR_PROXY_HOST=
    - DGC_GATEWAY_CONNECTOR_PROXY_PORT=-1
    - DGC_GATEWAY_CONNECTOR_MAX-CACHE-AGE=300
    - DGC_GATEWAY_CONNECTOR_TLSTRUSTSTORE_PATH=file:/app/certs/tls_trust_store.p12
    - DGC_GATEWAY_CONNECTOR_TLSTRUSTSTORE_PASSWORD=dgcg-p4ssw0rd
    - DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_PATH=file:/app/certs/tls_key_store.p12
    - DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_PASSWORD=dgcg-p4ssw0rd
    - DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_ALIAS=tls_key
    - DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_PATH=file:/app/certs/ta.jks
    - DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_PASSWORD=dgcg-p4ssw0rd
    - DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_ALIAS=trustanchor
    - DGC_GATEWAY_CONNECTOR_UPLOADKEYSTORE_PATH=file:/app/certs/CL/upload_key_store.p12
    - DGC_GATEWAY_CONNECTOR_UPLOADKEYSTORE_ALIAS=upload_key
    - DGC_GATEWAY_CONNECTOR_UPLOADKEYSTORE_PASSWORD=dgcg-p4ssw0rd
```

Make sure you replace the keys correctly. More information about this configuration in [this link](https://github.com/eu-digital-green-certificates/dgca-issuance-service/blob/main/docs/configuration.md).

**Run**
To build the project executable, which is built through Maven, the following command is used:

```bash
$ mvn clean package
```

This will create a "jar" file in the "~/dgc-issuance-service/target" directory. To run the application you use:

```bash
$ java -jar target/dgc-issuance-service-latest.jar
```

And if you use Docker, you can use:

```bash
$ docker-compose up --build
```

At the end, the web service that issues certificates should be started on the port indicated in the configuration. For example, if port 8081 is used, you can navigate to this URL: [http://localhost:8081/swagger](http://localhost:8081/swagger)

**Web Client**
To test the issuance of certificates, the DGC provides another repository called [issuance-web](https://github.com/eu-digital-green-certificates/dgca-issuance-web). This is a web application that consumes the API delivered by the issuance-service and allows the generation of vaccination certificates. This application works independently if Testing mode or productive mode was chosen in issuance-service. To clone the repository, you run the following command:

```bash
$ git clone https://github.com/eu-digital-green-certificates/dgca-issuance-web
```

Then to connect with the APIs it is necessary to modify the docker-compose.yml file, or change the nginx configuration file.

```bash
  - DGCA_ISSUANCE_SERVICE_URL=http://dgc-issuance-service:8081
  - DGCA_BUSINESSRULE_SERVICE_URL=http://dgc-businessrule-service:8082
```

Here you must specify the URLs of the issuance-service and business rule. Something important to note is that this repository brings these two services as dependencies, since in this guide we are setting up and configuring each service separately, it is necessary to remove these from the configuration.

Finally you can run the web application using the following command:

```bash
$ docker-compose up --build
```
## [Verifier](https://github.com/eu-digital-green-certificates/dgca-verifier-service)

This repository contains a backend that allows the verification of vaccination certificates issued. The repository can be cloned using the following command:

```bash
$ git clone https://github.com/eu-digital-green-certificates/dgca-verifier-service
```

**Keys**
Like the issuance service, this repository needs the previously created keys.

**Database**
This repository uses a Postgresql database, if docker is not used to build the project, you need to install and create a Postgresql database.

**Configurations**
Like the issuance-service, the repository configuration is in the docker-compose.yml file, but the "src/main/resources/application.yml" file can also be changed directly in case of not using docker.

There is no testing mode for the verifier-service, so it is always used with an associated gateway. To configure it, it is necessary to modify the configuration file and indicate the routes to the gateway and the keys:

```bash
      - DGC_GATEWAY_CONNECTOR_ENDPOINT=https://dgc-gateway.example.com
      - DGC_GATEWAY_CONNECTOR_TLSTRUSTSTORE_PATH=file:/ec/prod/app/san/dgc/tls_trust_store.p12
      - DGC_GATEWAY_CONNECTOR_TLSTRUSTSTORE_PASSWORD=dgcg-p4ssw0rd
      - DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_ALIAS=1
      - DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_PATH=file:/ec/prod/app/san/dgc/tls_key_store.p12
      - DGC_GATEWAY_CONNECTOR_TLSKEYSTORE_PASSWORD=dgcg-p4ssw0rd
      - DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_ALIAS=ta
      - DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_PATH=file:/ec/prod/app/san/dgc/trust_anchor.jks
      - DGC_GATEWAY_CONNECTOR_TRUSTANCHOR_PASSWORD=dgcg-p4ssw0rd
```

**Run**
Like the previous repositories, to build the project executable, the following Maven command is used:

```bash
$ mvn clean install
```

This will create a "jar" file in the "~/dgc-verifier-service/target" directory. To run the application you use:

```bash
$ java -jar target/dgc-issuance-verifier-latest.jar
```

And if you use Docker, you can use:

```bash
$ docker-compose up --build
```

At the end, the web service that issues certificates should be started on the port indicated in the configuration. For example, if port 8082 is used, you can navigate to this URL: [http://localhost:8082/swagger](http://localhost:8081/swagger)

## Verification Mobile Apps

For mobile applications the repositories are divided into the iOS and Android platforms. Both platforms have 4 repositories divided by functionalities that each one fulfills. For the development of applications to verify the certificates, only the “verifier” and “wallet” repositories will be modified according to what is needed. The repositories for both platforms are as follows:

-   App Core: This repository contains all the services necessary to connect to the DGC Verifier Service and to the DGC Business Rule. It is also responsible for signing the certificates to be able to send them safely.
    - iOS: [https://github.com/eu-digital-green-certificates/dgca-app-core-ios](https://github.com/eu-digital-green-certificates/dgca-app-core-ios)
    - Android: [https://github.com/eu-digital-green-certificates/dgca-app-core-android](https://github.com/eu-digital-green-certificates/dgca-app-core-android)

-   Verifier: This repository contains the mobile application that is in charge of scanning and verifying the certificates using the public keys, it uses the App Core to make the pertinent calls.
    -   iOS: [https://github.com/eu-digital-green-certificates/dgca-verifier-app-ios](https://github.com/eu-digital-green-certificates/dgca-verifier-app-ios)
    -   Android: [https://github.com/eu-digital-green-certificates/dgca-verifier-app-android](https://github.com/eu-digital-green-certificates/dgca-verifier-app-android)

-   Wallet: This repository provides a user interface to manage and save personal DGCs.
    -   iOS: [https://github.com/eu-digital-green-certificates/dgca-wallet-app-ios](https://github.com/eu-digital-green-certificates/dgca-wallet-app-ios)
    -   Android: [https://github.com/eu-digital-green-certificates/dgca-wallet-app-android](https://github.com/eu-digital-green-certificates/dgca-wallet-app-android)

-   CertLogic: This repository contains the source code to handle CertLogic semantics in mobile applications.
    -   iOS: [https://github.com/eu-digital-green-certificates/dgc-certlogic-ios](https://github.com/eu-digital-green-certificates/dgc-certlogic-ios)
    -   Android: [https://github.com/eu-digital-green-certificates/dgc-certlogic-android](https://github.com/eu-digital-green-certificates/dgc-certlogic-android)

In case QR code examples are required, there are these official examples ([https://dgc.a-sit.at/ehn/testsuite](https://dgc.a-sit.at/ehn/testsuite)).

### iOS

The requirements for services on iOS are:
-   A Mac or virtual machine is required to run Xcode.
-   Xcode 12.5+ is used for builds. A macOS 11.0+ operating system is required.
-   To install it on physical devices, an Apple developer account is required. For this you must enroll in the apple development program ([Apple Developer Program](https://developer.apple.com/programs/enroll/))


#### Verifier

This repository contains the mobile application to verify certificates through iOS. In order to install this project you must first clone it locally with the following command:

```bash
$ git clone https://github.com/eu-digital-green-certificates/dgca-verifier-app-ios
```

In order to have the connection and certificate signing services, you must also have the core repository in the same folder, you can use the same command used to clone the core repository.

```
<project folder>
|___dgca-app-core-ios
|___dgca-verifier-app-ios
```

Once you have both repositories installed, they must modify the context.jsonc file with the correct national system values. This file is located in the “context” folder. You must fill in the appropriate values as shown in the following diagram:

```json
{
  // Origin in ISO alpha 2 code:
  "origin": "XX",
  "versions": {
    "default": {
      "privacyUrl": "https://<PRIVACY_URL>",
      "context": {
        "url": "https://<URL_ISSUANCE_SERVICE>/context",
        "pubKeys": [<PUBLIC_KEYS>]
      },
      "endpoints": {
        "claim": {
          "url": "https://<URL_ISSUANCE_SERVICE>/dgci/wallet/claim",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "countryList": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/countrylist",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "rules": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/rules",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "valuesets": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/valuesets",
          "pubKeys": [<PUBLIC_KEYS>]
        }
      }
    },
  }
}
```

Once you have these values, you can run the certificate validation application.

To modify the Locale of the app you just have to generate a new locale file inside the folder “Localization/DGCAVerifier”. Copy the file en.xloc and modify it to meet your localization.

**Wallet**

This repository contains the mobile application to save and manage personal certificates. In order to install this project you must first clone it locally with the following command:

```bash
$ git clone https://github.com/eu-digital-green-certificates/dgca-wallet-app-ios
```

In order to have the connection and certificate signing services, you must also have the core repository in the same folder, you can use the same command used to clone the core repository.

```console
<project folder>
|___dgca-app-core-ios
|___dgca-wallet-app-ios
```

Like the verifier, you must modify the context.jsonc in order to generate the personal certificate. You can also modify the location in the same file.

### Android

The requirements for services on Android are:

-   For development it is recommended to use Android Studio. The latest version available can be downloaded [here](https://developer.android.com/studio/).
-   Android SDK version 26+

#### Verifier and Wallet (Android)

This repository contains the mobile application to verify certificates through Android. In order to install this project you must first clone it locally with the following command:

```bash
$ git clone https://github.com/eu-digital-green-certificates/dgca-verifier-app-android
$ git clone https://github.com/eu-digital-green-certificates/dgca-wallet-app-android
```

In order to have the connection and certificate signing services, you must also have the core repository in the same folder, you can use the same command used to clone the core repository.

```console
<project folder>
|___dgca-verifier-app-android
|___dgca-app-core-android
|___dgc-certlogic-android
```

Once you have the repositories installed, they must modify the verifier-context.jsonc file with the correct national system values. This file is located in the “app/src/acc/assets” folder. You must generate a file called "config.json" in the same folder and fill in the appropriate values as shown in the following diagram:

#### Verifier

```json
{
  // Origin in ISO alpha 2 code:
  "origin": "XX",
  "versions": {
    "default": {
      "privacyUrl": "https://<PRIVACY_URL>",
      "context": {
        "url": "https://<URL_VERIFIER_SERVICE>/context",
        "pubKeys": [<PUBLIC_KEYS>]
      },
      "endpoints": {
        "status": {
          "url": "https://<URL_VERIFIER_SERVICE>/signercertificateStatus",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "update": {
          "url": "https://<URL_VERIFIER_SERVICE>/signercertificateUpdate",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "countryList": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/countrylist",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "rules": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/rules",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "valuesets": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/valuesets",
          "pubKeys": [<PUBLIC_KEYS>]
        }
      }
    },
  }
}
```

#### Wallet

```json
{
  // Origin in ISO alpha 2 code:
  "origin": "XX",
  "versions": {
    "default": {
      "privacyUrl": "https://<PRIVACY_URL>",
      "context": {
        "url": "https://<URL_ISSUANCE_SERVICE>/context",
        "pubKeys": [<PUBLIC_KEYS>]
      },
      "endpoints": {
        "claim": {
          "url": "https://<URL_ISSUANCE_SERVICE>/dgci/wallet/claim",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "countryList": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/countrylist",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "rules": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/rules",
          "pubKeys": [<PUBLIC_KEYS>]
        },
        "valuesets": {
          "url": "https://<URL_BUSINESSRULE_SERVICE>/valuesets",
          "pubKeys": [<PUBLIC_KEYS>]
        }
      }
    },
  }
}
```

In the file "app/src/main/java/dgca/verifier/app/android/di/NetworkModule.kt" modify the variable "BASE_URL" by the url of the verifier:

```kotlin
const val BASE_URL = "https://<URL_VERIFIER_SERVICE>/"
```

In the case of the wallet, change it to:

```kotlin
const val BASE_URL = "https://<URL_ISSUANCE_SERVICE>/"
```

To run the project in an android emulator you must execute this command:

```bash
$ gradlew -PCONFIG_FILE_NAME="config.json"
```