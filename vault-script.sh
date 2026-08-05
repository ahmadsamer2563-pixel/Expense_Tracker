#!/bin/bash

# Variables
VAULT_ADDR='http://127.0.0.1:8200'
VAULT_TOKEN="YOUR_VAULT_TOKEN_HERE"
SECRET_PATH='secret/database'
ENV_FILE='/home/aau/Desktop/Project2/Expense_Tracker/backend/.env'

# Export Vault address and token
export VAULT_ADDR
export VAULT_TOKEN

# Retrieve secrets from Vault
echo "Retrieving secrets from Vault..."

SECRETS=$(vault kv get -format=json $SECRET_PATH)

# Check if retrieval was successful
if [ $? -ne 0 ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

# Extract data and save to .env file
echo "Saving secrets to $ENV_FILE..."

echo "$SECRETS" | jq -r '.data.data | to_entries[] | .key + "=" + (.value|tostring)' > $ENV_FILE

echo "POSTGRES_DB=$(grep '^DB_NAME=' "$ENV_FILE" | cut -d= -f2-)" >> "$ENV_FILE"
echo "POSTGRES_USER=$(grep '^DB_USER=' "$ENV_FILE" | cut -d= -f2-)" >> "$ENV_FILE"
echo "POSTGRES_PASSWORD=$(grep '^DB_PASSWORD=' "$ENV_FILE" | cut -d= -f2-)" >> "$ENV_FILE"

# Check if .env file was created successfully
if [ $? -ne 0 ]; then
  echo "Failed to save secrets to $ENV_FILE."
  exit 1
fi

echo ".env file created successfully."

# Run Docker
echo "Starting Docker containers..."

cd /home/aau/Desktop/Project2/Expense_Tracker

sudo docker compose up --build -d
