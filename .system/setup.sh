#!/bin/bash

rootPath=$(git rev-parse --show-toplevel)
ln -s $rootPath/.system/post-commit $rootPath/.git/hooks/post-commit
ln -s $rootPath/.system/pre-commit $rootPath/.git/hooks/pre-commit