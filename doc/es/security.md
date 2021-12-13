# Seguridad y Llaves de Encriptación

El sistema del DGC usa un sistema de seguridad basado en el paradigma de llaves públicas y privadas que se usan para verificar la autenticidad de las consultas y la firma de los certificados. Algo importante de notar es que estas llaves públicas son verificadas directamente por la aplicación del DGC y no necesariamente siguen las reglas usuales de HTTPS.

Dentro de los repositorios se usan distintos formatos y estándares para el guardado de las llaves, a continuación se describe cada uno de estos formatos:

-   **PEM:** Archivo que contiene una llave pública y opcionalmente una llave privada de forma plana. Generalmente sólo se incluye la llave pública.

-   **KEY:** Archivo que contiene una llave privada de forma plana. Este archivo nunca debería ser compartido con terceros para evitar ataques y vulnerabilidades.

-   **P12:** Archivo que contiene una llave pública y opcionalmente una privada de forma encriptada por una contraseña. Normalmente se toma como entrada un archivo PEM para construir un P12.

-   **JKS:** Formato similar al P12 que es capaz de ser leído por aplicaciones Java de forma simple.