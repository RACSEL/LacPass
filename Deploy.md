# Deployment

This guide defines the steps to deploy all the services needed for the DGCA national backend.

Important: Clone this repository using the flag `-r` to fetch submodules.

## Build JARs

The repositories `dgca-businessrule-service`, `dgca-issuance-service` and `dgca-verifier-service` need to be built from the source. Enter to this directories and run the following command

	mvn clean install


## Create Keys

Include your generated keys into the directory certs of the root of this project. These keys can be also be generated running the `certificates.sh` scripts.

## Change environment variables

Open the file `docker-compose-national-web.yml` and change the environment variables to match the certificates, ports and urls to match your configuration.

## Deploy

To deploy the services run using docker-compose

	docker-compose -f docker-compose-national-web.yml up