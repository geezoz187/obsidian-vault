#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <directory> <public_pem_file>"
  exit 1
fi

# Directory to search for files
directory="$1"

# Public PEM file path
public_pem="$2"

# Check if the public PEM file exists
if [ ! -f "$public_pem" ]; then
  echo "Public PEM file not found: $public_pem"
  exit 1
fi

# Function to encrypt a file using hybrid encryption (AES + RSA)
encrypt_file() {
  local file="$1"
  local encrypted_file="${file}.enc"
  local aes_key_file="${file}.aes"
  local encrypted_aes_key_file="${aes_key_file}.key"

  # Step 1: Generate a random 256-bit (32-byte) AES key
  openssl rand -out "$aes_key_file" 32

  # Step 2: Encrypt the file using the AES key
  openssl enc -pbkdf2 -aes-256-cbc -salt -in "$file" -out "$encrypted_file" -pass file:"$aes_key_file"

  # Step 3: Encrypt the AES key using the RSA public key
  openssl pkeyutl -encrypt -inkey "$public_pem" -pubin -in "$aes_key_file" -out "$encrypted_aes_key_file" -pkeyopt rsa_padding_mode:pkcs1

  # Remove the plaintext AES key file for security
  rm -f "$aes_key_file"
  rm -f "$file"
  git add "$encrypted_file"
  git add "$encrypted_aes_key_file"

  echo "Encrypted $file -> $encrypted_file"
  echo "Encrypted AES key -> $encrypted_aes_key_file"
}

# Recursively find and encrypt files, excluding .enc, .aes.key, .aes.key.enc, and .gitignore files
find "$directory" -type f -not \( -path "*/.git/*" -o -path "*/.system/*"  \) \
  -not \( -name "*.enc" -o -name "*.aes.key" -o -name "*.aes.key.enc" -o -name ".gitignore" \) -print0 | \
  while IFS= read -r -d $'\0' file; do
  encrypt_file "$file"
done