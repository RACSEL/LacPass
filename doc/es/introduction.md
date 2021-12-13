# Documentación Técnica LACPASS

## Introducción

Este documento se presenta como documentación técnica para la implementación de LACPASS, en el cual se detalla cómo opera la solución y los pasos necesarios que deben hacer los países participantes para integrarse a LACPASS.

El Pase de Vacunación de Latinoamérica y el Caribe, LACPASS, es una aplicación de intercambio de información sobre estados de vacunación de los países de América Latina y el Caribe, que permite que personas que hubiesen recibido parte o la totalidad del esquema de vacunación COVID en su país de residencia, al momento de viajar a otro país de la región puedan validar de forma simple y verificable su estado de vacunación en el país de destino, sin necesidad de realizar trámites adicionales como la homologación del certificado local de vacunación.

El proyecto LACPASS es una iniciativa de Red Americana de Cooperación en Salud Electrónica de América Latina y el Caribe (RACSEL), patrocinada por el Banco Interamericano de Desarrollo (BID) y ejecutada por el Centro Nacional de Sistemas de Información de Chile (CENS) por medio de la empresa privada Create de Chile, la cual se adjudicó la licitación para el desarrollo y puesta en marcha de este bien público.

La tecnología detrás de LACPASS se basa en el Digital Green Certificates de la Unión Europea (EU-DGC), este repositorio es un proyecto de código abierto usado en todos los países de la Unión Europea y 24 países fuera de ella. Este pase es multilenguaje y está disponible en Inglés, Español, Francés y Portugues los cuales son de especial interés en esta región. Además permite ser digital y en papel, y posee un código QR verificable a través de las aplicaciones que provee el DGC. Al conectar a los países interesados a LACPASS es posible usar la misma tecnología para conectarse al Digital Green Certificates de la Unión Europea.

El principal objetivo del proyecto LACPASS es conectar de forma segura y verificable la información sobre vacunación individual de los residentes de los países de la región en un sistema uniforme e interoperable que facilite los viajes dentro de la región entregando a las autoridades sanitarias y migratorias de los países una herramienta que le entregue información veráz y oportuna sobre el estado de vacunación de los pasajeros que se encuentran entrando o transitando.

Como objetivo adicional, se busca colaborar con los países de la región para que puedan conectarse de forma simple y fluida a la tecnología del Digital Green Certificates de la Unión Europea.


# Donde puedo encontrar ...

| Topico                                            | Description                                                                |
|-------------------------------------------------|------------------------------------------------------------------------------|
| [Arquitectura]                                  | Breve explicación de la arquitectura de los DCC (Digital COVID Certificates).|
| [Implementación]                                | Cómo levantar y desarrollar cada repositorio del DCC                         |
| [Seguridad]                                     | Explicación sobre la seguridad usada en los certificados                     |
| [FAQ]                                           | Preguntas Frecuentes                                                         |

[Arquitectura]: ./architecture.md
[Implementación]: ./implementation.md
[Seguridad]: ./security.md
[FAQ]: ./faq.md