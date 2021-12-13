# Architecture

As explained above, the implementation of LACPASS is based on the Digital Green Certificates projects of the European Union (DGC) and European Health Network (EHN), whose repositories can be found at the following links:

- **DGC:** [https://github.com/eu-digital-green-certificates](https://github.com/eu-digital-green-certificates)
- **EHN:** [https://github.com/ehn-dcc-development](https://github.com/ehn-dcc-development)

The DGC provides different repositories for the implementation of interoperability of vaccination certificates. The interaction of all these repositories is shown in the following diagram:

![](https://lh5.googleusercontent.com/feH89SRfteWLOu7_qKx6hoANPfjpYCEs8R1d-_qvFoHy2omqtLaB0GiF7wy28zu4k3-46QKDntzVXuhHYx-M8q2dcr3pblJw_QSPkY8yBTps8YWTf5lRsvCYGaVD1-pTX6GquW-e)

Functionally the repositories can be divided into 3 groups:

## Logic and Synchronization

### [Gateway](https://github.com/eu-digital-green-certificates/dgc-gateway)

The DGC Gateway has the purpose of serving as support for the entire DGC system, it provides all the services necessary for the secure transfer of validations and verifications between national systems. Each national system can implement its own DGC Gateway to obtain the freedom to distribute the keys with the preferred technology and also to be able to manage national verification systems.

Additionally, if the certificate is generated in a correct standard format, any verifying device will be able to verify codes of any country that has the EU format. This works for both the verifier connected to the national system and offline systems that have the necessary public keys downloaded beforehand.

The following diagram shows the flow between the different national systems and the DGC Gateway:

![](https://lh4.googleusercontent.com/DrUA-_Q3oQp--D9kEV3Uke7v8IlbDL6zoNoHDiDNwMYlUXR2YkS2q6oHPf7cSfuQ5Om4FZtdJEkP_xpTgG0A3IInwL0yCJIdHDlJwVMHr_LbMeYHo_r9rTOIZyvdcj2-cWIYCb8-)

Here is a link to detailed documentation of the DGC Gateway ([Documentation](https://github.com/eu-digital-green-certificates/dgc-gateway/blob/main/docs/software-design-dgc-gateway.md)).

### [Business Rule Service](https://github.com/eu-digital-green-certificates/dgca-businessrule-service)

The DGC Business Rule Service is one of the services connected to the DGC Gateway, this service provides the necessary rules to verify whether or not a code is valid in a national system. These rules are based on the vaccines you have, the tests performed and the recovery status of the validated person..

To generate these validation rules there is a more detailed format in this link ([Business Rules Test Data](https://github.com/eu-digital-green-certificates/dgc-business-rules-testdata)).

## Issuance

### [Issuance Service](https://github.com/eu-digital-green-certificates/dgca-issuance-service)

The DGC Issuance Service is the backend system that provides both the creation and signing of new certificates (green certificates). Each country must raise this service to be able to have the certificates. In order for the certificates to be used internationally, the public keys must be shared in the Gateway so that all countries can verify the certificates. This service is used by mobile applications (Android, iOS) and by web applications.

### [Issuance Web](https://github.com/eu-digital-green-certificates/dgca-issuance-web)

The Issuance Web is a web application that provides a user interface used to provide the necessary data in the issuance service. Certificates can also be generated in this application.

## Verification

### [Verifier Service](https://github.com/eu-digital-green-certificates/dgca-verifier-service)

To verify the certificates it is necessary to have the public keys of the appropriate national system. The DGC Verifier Service is a backend service that is used to manage the public keys obtained through the DGCG. This service is used in mobile applications to obtain public keys and verify green certificates.

To verify the certificates you can use both the verifier on [iOS](https://github.com/eu-digital-green-certificates/dgca-verifier-app-ios)  and [Android](https://github.com/eu-digital-green-certificates/dgca-verifier-app-android). Both repositories contain a very simple application to scan QR codes and a verification and validation interface for these.