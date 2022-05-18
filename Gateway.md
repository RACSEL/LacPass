# Gateway

LACPass provide two environments to test the national backend of the participant countries. This guide provides the gateway information and steps to test these environments

## Environments

| Environment | URL | Status |
| ----- | ----- | -----|
| Testing | https://lacpass.create.cl/ | Live |
| Pre-production | https://lacpass.racsel.org/ | Not deployed |


## Enrollment process
In order to enroll to our gateway, the following steps are required:

* Create a new environment for the project.
* Deploy the client repositories: issuance, business rules, and verifier ([more info](https://github.com/RACSEL/LacPass/blob/main/doc/en/implementation.md)).
* Ensure that the gateway url provided in the docker config files matches to one of the environments presented above (e.g. https://lacpass.create.cl).
* Download the trust anchor keystore (https://github.com/RACSEL/LacPass/blob/main/certs/ta.jks) and include it in the repositories. JKS Alias: `trustanchor`. JKS password: `dgcg-p4ssw0rd`.
* Send to the LACPass technical team a copy of the public keys for `AUTH`, `UPLOAD`, and `CSCA` and wait for the confirmation of enrollment. 
* Upload your signing key `DSC` using the `signerCertificate` endpoint ([more info](https://github.com/eu-digital-green-certificates/dgc-participating-countries/blob/main/gateway/OnboardingChecklist.md#test-environment)).
* Test your applications using the cases below.

## Testing
The country Chile (CL) is included in the gateway for testing purposes. The following QR codes were generated using the CL signing keys. Please scan them using the verifier app and check the expected results.

### Valid QR code sample

| QR Code | Expected Result |
| ----- | ----- |
| ![QR](https://raw.githubusercontent.com/RACSEL/LacPass/main/webpage/images/gateway_valid_qr.jpg) | ![Result](https://raw.githubusercontent.com/RACSEL/LacPass/main/webpage/images/gateway_valid_test.jpg) |

### Invalid QR code sample (Vaccination date is in the future)

| QR Code                                                                                                   | Expected Result                                                                                                 |
|-----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| ![QR](https://raw.githubusercontent.com/RACSEL/LacPass/main/webpage/images/gateway_invalid_future_qr.jpg) | ![Result](https://raw.githubusercontent.com/RACSEL/LacPass/main/webpage/images/gateway_invalid_future_test.jpg) |

### Invalid QR code sample

| QR Code | Expected Result |
| ----- | ----- |
| ![QR](https://raw.githubusercontent.com/RACSEL/LacPass/main/webpage/images/gateway_invalid_qr.jpg) | ![Result](https://raw.githubusercontent.com/RACSEL/LacPass/main/webpage/images/gateway_invalid_test.jpg) |
