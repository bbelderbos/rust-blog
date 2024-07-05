#!/bin/bash

# Prompt for the title
read -p "Enter the title: " title

# Convert the title to a slug
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]' '-' | tr -cd '[:alnum:]-' | sed 's/-$//')

# Prompt for the slug with the default value
read -p "Enter the slug (default: $slug): " input_slug

# Use the user-provided slug or the default
slug=${input_slug:-$slug}

# Get today's date
date=$(date +"%Y-%m-%d")

# Define the file path
file_path="content/${slug}.md"

# Create the new markdown file with front matter
cat <<EOL > $file_path
+++
title = "${title}"
date = ${date}
+++

EOL

echo "New post created at $file_path, opening in vim..."
vim $file_path
