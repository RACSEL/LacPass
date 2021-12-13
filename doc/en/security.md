# Security and Encryption Keys

The DGC system uses a security system based on the paradigm of public and private keys that are used to verify the authenticity of the queries and the signing of the certificates. Something important to note is that these public keys are verified directly by the DGC application and do not necessarily follow the usual HTTPS rules.

Within the repositories, different formats and standards are used for saving keys, each of these formats is described below:

-   **PEM:** File containing a public key and optionally a private key in flat form. Usually only the public key is included.

-   **KEY:** File containing a private key in a flat shape. This file should never be shared with third parties to avoid attacks and vulnerabilities.

-   **P12:** File that contains a public key and optionally a private one, encrypted by a password. Normally a PEM file is taken as input to build a P12.

-   **JKS:** Format similar to P12 that is able to be read by Java applications in a simple way.