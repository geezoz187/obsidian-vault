#!/bin/bash

rootPath=$(git rev-parse --show-toplevel)

# Check if post-commit file exists
if [ -e "$rootPath/.git/hooks/post-commit" ]; then
  # Delete the existing post-commit file
  rm "$rootPath/.git/hooks/post-commit"
fi

# Check if pre-commit file exists
if [ -e "$rootPath/.git/hooks/pre-commit" ]; then
  # Delete the existing pre-commit file
  rm "$rootPath/.git/hooks/pre-commit"
fi

# Create symlinks for post-commit and pre-commit
ln -s "$rootPath/.system/post-commit" "$rootPath/.git/hooks/post-commit"
ln -s "$rootPath/.system/pre-commit" "$rootPath/.git/hooks/pre-commit"
