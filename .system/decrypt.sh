#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <directory> <private_pem_file>"
  exit 1
fi

# Directory to search for encrypted files
directory="$1"

# Private PEM file path
private_pem="$2"

# Check if the private PEM file exists
if [ ! -f "$private_pem" ]; then
  echo "Private PEM file not found: $private_pem"
  exit 1
fi

# Function to decrypt a file using hybrid encryption (AES + RSA)
decrypt_file() {
  local encrypted_file="$1"
  local decrypted_file="${encrypted_file%.enc}"
  local encrypted_aes_key_file="${decrypted_file}.aes.key"
  local aes_key_file="${decrypted_file}.aes"

  # Step 1: Decrypt the AES key using the RSA private key
  openssl pkeyutl -decrypt -inkey "$private_pem" -in "$encrypted_aes_key_file" -out "$aes_key_file" -pkeyopt rsa_padding_mode:pkcs1

  # Step 2: Decrypt the file using the decrypted AES key
  openssl enc -pbkdf2 -aes-256-cbc -d -in "$encrypted_file" -out "$decrypted_file" -pass file:"$aes_key_file"

  # Remove the encrypted file and the decrypted AES key file for security
  rm -f "$encrypted_file"
  rm -f "$encrypted_aes_key_file"
  rm -f "$aes_key_file"

  echo "Decrypted $encrypted_file -> $decrypted_file"
}

# Find and decrypt .enc files recursively within the specified directory
find "$directory" -type f -name "*.enc" -print0 | while IFS= read -r -d $'\0' file; do
  decrypt_file "$file"
done