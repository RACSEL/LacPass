# Preguntas Frecuentes

Esta sección describe las preguntas más frecuentes relacionadas al proyecto

> **Si estoy usando el issuance-web, ¿cómo se puede agregar autenticación o alguna medida de restricción de acceso?**

La aplicación web de issuance (issuance-web) no cuenta con un sistema de autenticación propio ni ninguna medida de control de acceso. Esto quiere decir que una vez desplegada esta aplicación cualquier usuario que tenga acceso al servidor puede usarla y emitir certificados. Existen distintas estrategias para controlar el acceso dependiendo de la complejidad y cantidad de recursos que posean los países.

La alternativa más simple de implementar es agregar autenticación HTTP básica al servidor de proxy ya sea nginx o apache. Ambos proveen plugins para agregar este tipo de autenticación, por ejemplo configurando el archivo .htpasswd.

La siguiente opción recomendada es no utilizar el servicio de issuance-web y desarrollar una aplicación propia que utilice la API del issuance-service. De esta forma se tiene control total del desarrollo y se puede agregar autenticación a nivel de la aplicación.

De todas formas se recomienda que la aplicación esté sólo visible para un segmento específico de IPs o ubicaciones para evitar otro tipo de tráfico.

> **Si tengo un registro nacional de personas vacunadas, ¿cómo puedo integrar esta información al sistema?**

Los países con un Registro Local de Vacunación pueden conectar la información de las personas vacunadas a LACPASS por medio de la API del issuance-service. Lo recomendado es crear un software que se inserte entre el cliente de emisión de certificados (issuance-web o desarrollo propio) y el issuance-service. Este software debería verificar la autenticidad del certificado solicitado a emitir con el registro nacional y continuar con el proceso de emisión o detenerlo en caso que los datos solicitados no coincidan. El siguiente diagrama ejemplifica el funcionamiento.

![](https://lh3.googleusercontent.com/4puvQ_9GqMW2rcH0WoXxPlE2OT9SNK8n7TFpRK8_Ajb013zURETUV8hvvQYrw6hjEcnTtM6UpRgm6PQZY1IMvOsXSyRufCl-KP_6lnyNex2F44yEk-bDzsxM_CYa_kuGcpC2oepq)

> **¿Cuáles son los pasos a seguir para poder integrarse con la UE?**

El proceso de integración está explicado en el siguiente enlace: [Onboarding Checklist](https://github.com/eu-digital-green-certificates/dgc-participating-countries/blob/main/gateway/OnboardingChecklist.md).

A modo general el proceso consiste en enviar a la UE las llaves públicas para agregarlas a la base de datos del gateway tal como se explicó en la sección del gateway. Y luego de hacer pruebas de que todo esté funcionando correctamente, se necesita cambiar el endpoint del gateway al endpoint oficial de ellos.

Ellos tienen a disposición 3 ambientes: Test, para las pruebas de integración (este ambiente sólo se inicia cuando se empieza el proceso de Onboarding, antes de eso está apagado). Acceptance, para probar y para que la UE valide que la integración funciona correctamente. Producción: ambiente que contiene los datos reales, una vez integrado a este ambiente se completa el proceso.

> **¿Cómo manejar las personas que se vacunan por primera vez y las personas que ya se encuentran vacunadas?**

Es recomendable que los países que tienen implementado un Registro Local de Vacunación lo hayan integrado usando las instrucciones anteriores. De esta forma, la capa de validación propia que se debe desarrollar puede manejar los casos en los cuales las personas ya estuvieron vacunadas o se han vacunado por primera vez o tienen su esquema de vacunación incompleto.