#!/bin/bash

# Variables
USERNAME="db-username-if-it-exists"
PASSWORD="db-user-password-if-it-exists"
CLUSTER_ENDPOINT="cluster-endpoint"
DB_NAME="name-of-database"
OUTPUT_DIR="/the/directory/you/want/the/collections/to/be/exported/to"
SSL_CA_FILE="/path/to/pem/file"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Get the list of collections from the database
collections1=$(mongosh --ssl --sslCAFile $SSL_CA_FILE --username $USERNAME --password $PASSWORD --authenticationDatabase admin "mongodb://$USERNAME:$PASSWORD@$CLUSTER_ENDPOINT:27017/?tls=true&tlsCAFile=$SSL_CA_FILE&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false" --db $DB_NAME --eval "db.getCollectionNames().join(',')" --quiet)
collections=$(mongosh --ssl --sslCAFile $SSL_CA_FILE --username $USERNAME --password $PASSWORD --authenticationDatabase admin "mongodb://$USERNAME:$PASSWORD@$CLUSTER_ENDPOINT:27017/$DB_NAME?tls=true&tlsCAFile=$SSL_CA_FILE" --eval "db.getCollectionNames().join(',')")

# Convert collections string to array
IFS=',' read -r -a collectionArray <<< "$collections"

# Loop over each collection and export it
for collection in "${collectionArray[@]}"; do
    echo "Exporting collection: $collection"

    sudo mongoexport --ssl --sslCAFile $SSL_CA_FILE --username $USERNAME --password $PASSWORD --authenticationDatabase admin --uri "mongodb://$USERNAME:$PASSWORD@$CLUSTER_ENDPOINT:27017/?tls=true&tlsCAFile=$SSL_CA_FILE&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false" --db $DB_NAME --collection "$collection" --out "./$OUTPUT_DIR/${collection}.json"
    
    echo "Exported collection: $collection to $OUTPUT_DIR/${collection}.json"
done
