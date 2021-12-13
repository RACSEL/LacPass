# Arquitectura

Como se explicó anteriormente la implementación de LACPASS se basa en los proyectos de Digital Green Certificates de la Unión Europea (DGC) y European Health Network (EHN), cuyos repositorios se encuentran en los siguientes enlaces:

-   **DGC:** [https://github.com/eu-digital-green-certificates](https://github.com/eu-digital-green-certificates)
-   **EHN:** [https://github.com/ehn-dcc-development](https://github.com/ehn-dcc-development)

La DGC provee distintos repositorios para la implementación de interoperabilidad de certificados de vacunación. La interacción de todos estos repositorios está mostrada en el siguiente diagrama.

![](https://lh3.googleusercontent.com/c6GEk2jowxSj2mIiS_Sm_HHpeF_Bs-3D2ro63lATFfaaZZ4twpMK27PTpnEHsTyAy2xXKNV6Of-aHQGh1WCYXPu2iTcgM2caWNwc2xgaZDKw-ZUnOtkyrj1SoEXiNhq4lLG_7RUF)

Funcionalmente los repositorios se pueden dividir en 3 grupos:

## Lógica y Sincronización

### [Gateway](https://github.com/eu-digital-green-certificates/dgc-gateway)

El DGC Gateway tiene el propósito de servir de soporte para todo el sistema DGC, provee todos los servicios necesarios para el traspaso seguro de validaciones y verificaciones entre sistemas nacionales. Cada sistema nacional puede implementar su propio DGC Gateway para obtener la libertad de distribuir las llaves con la tecnología preferida y además para poder manejar sistemas de verificación nacionales.

Adicionalmente si el certificado es generado en un formato estándar correcto, cualquier dispositivo verificador podrá verificar códigos de cualquier país que tenga el formato EU. Esto funciona tanto para el verificador conectado al sistema nacional como los sistemas offline que tengan descargadas las llaves públicas necesarias de antemano.

En el siguiente diagrama se muestra el flujo entre los distintos sistemas nacionales y el DGC Gateway:

![](https://lh3.googleusercontent.com/x3p1UkgBrk3jtPsd-YehtPecFWpoYy8zL3LJasGkuKyYUJTFHE_0KYNjbD-0qES7h_Qtq0pxH_xI9h5ZyvilIgNiE3jJgd3WyOMIS_654fR43jNtn6w_Y6mMuZXfxI3eoJKVWSGM)

Aquí hay un enlace con documentación detallada del DGC Gateway ([Documentación](https://github.com/eu-digital-green-certificates/dgc-gateway/blob/main/docs/software-design-dgc-gateway.md))

### [Business Rule Service](https://github.com/eu-digital-green-certificates/dgca-businessrule-service)

El DGC Business Rule Service es uno de los servicios conectados al DGC Gateway, este servicio provee de las reglas necesarias para poder verificar si un código es o no válido en un sistema nacional. Estas reglas están basadas en las vacunas que posee, los test realizados y el estado de recuperación de la persona validada.

Para generar estas reglas de validación existe un formato más detallado en este enlace ([Business Rules Test Data](https://github.com/eu-digital-green-certificates/dgc-business-rules-testdata)).

## Emisión

### [Issuance Service](https://github.com/eu-digital-green-certificates/dgca-issuance-service)

El DGC Issuance Service es el sistema backend que provee los servicios tanto de creación como de firma de nuevos certificados (green certificates). Cada país debe levantar este servicio para poder tener los certificados. Para que los certificados puedan ser usados internacionalmente se deben compartir las llaves públicas en el Gateway para que todos los países puedan verificar los certificados. Este servicio es usado por las aplicaciones móviles (Android, iOS) y por la aplicación web.

### [Issuance Web](https://github.com/eu-digital-green-certificates/dgca-issuance-web)

El Issuance Web es una aplicación web que provee una interfaz de usuario usada para proveer los datos necesarios en el issuance service. También se pueden generar certificados en esta aplicación.

## Verificación

### [Verifier Service](https://github.com/eu-digital-green-certificates/dgca-verifier-service)

Para verificar los certificados es necesario tener las llaves públicas del sistema nacional adecuado. El DGC Verifier Service es un servicio backend que se utiliza para gestionar las llaves públicas obtenidas a través del DGCG. Este servicio se utiliza en las aplicaciones móviles para obtener las llaves públicas y verificar los green certificates.

Para verificar los certificados se puede usar tanto el verificador en [iOS](https://github.com/eu-digital-green-certificates/dgca-verifier-app-ios)  como en [Android](https://github.com/eu-digital-green-certificates/dgca-verifier-app-android). Ambos repositorios contienen una aplicación muy simple para escanear los códigos QR y una interfaz de verificación y validación de estos.