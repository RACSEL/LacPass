# Frequent Asked Questions

This section describes the most frequently asked questions related to the project

> **If I am using the issuance-web, how can I add authentication or some access restriction measure?**


The issuance web application (issuance-web) does not have its own authentication system or any access control measure. This means that once this application is deployed, any user with access to the server can use it and issue certificates. There are different strategies to control access depending on the complexity and amount of resources that the countries have.

The simplest alternative to implement is to add basic HTTP authentication to the proxy server either nginx or apache. Both provide plugins to add this type of authentication, for example by configuring the .htpasswd file.

The next recommended option is not to use the issuance-web service and develop your own application that uses the issuance-service API. This way you have full control of development and you can add authentication at the application level.

In any case, it is recommended that the application is only visible for a specific segment of IPs or locations to avoid other types of traffic.

> **If I have a national registry of vaccinated people, how can I integrate this information into the system?**


Countries with a National Vaccination Registry can connect the information of vaccinated people to LACPASS through the issuance-service API. It is recommended to create software that is inserted between the certificate issuance client (issuance-web or custom development) and the issuance-service. This software should verify the authenticity of the certificate requested to be issued with the national registry and continue with the issuance process or reject it in case the requested data does not match. The following diagram exemplifies the operation.

![](https://lh6.googleusercontent.com/_uMIX4RZSiCF_UXnkqsm8OfI9kaOCXDSuTNcOsvxnVfviTv-_u6WdlLZ-JaBccbRmDSiqoOgDZ9Z-SGwOMTJfgAvfiiRyjt_JS7U7I1Cqrbcs2aOkQBcaCaMmtK2nPgkISGAGDlU)

> **What are the steps to follow to be able to integrate with the EU?**

The integration process is explained in the following link: [Onboarding Checklist](https://github.com/eu-digital-green-certificates/dgc-participating-countries/blob/main/gateway/OnboardingChecklist.md).

In general, the process consists of sending the public keys to the EU to add them to the gateway database as explained in the gateway section. And after testing that everything is working correctly, you need to change the gateway endpoint to their official endpoint.

Ellos tienen a disposición 3 ambientes: Test, para las pruebas de integración (este ambiente sólo se inicia cuando se empieza el proceso de Onboarding, antes de eso está apagado). Acceptance, para probar y para que la UE valide que la integración funciona correctamente. Producción: ambiente que contiene los datos reales, una vez integrado a este ambiente se completa el proceso.

> **How to handle people who are vaccinated for the first time and people who are already vaccinated?**


It is recommended that countries that have implemented a National Vaccination Registry have integrated it using the instructions above. In this way, the custom validation layer that will be developed can handle cases in which people have already been vaccinated, have been vaccinated for the first time or have an incomplete vaccination schedule.