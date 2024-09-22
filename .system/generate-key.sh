#!/bin/bash

cd $(git rev-parse --show-toplevel)/.system

openssl genrsa -out ../private.pem 4096 
openssl rsa -in private.pem -pubout > public.pem