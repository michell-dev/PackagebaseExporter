#!/bin/bash

# Define the output file name and GitHub repository details
output_file="package-snapshot.txt"
github_username="YourGitHubUsername"
github_repo="YourGitHubRepoName"
github_token="YourGitHubAccessToken"

# Use pacman to list installed packages and save the output to the file
pacman -Qdt > "$output_file"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Package list exported to $output_file"

    # Encode the file content as base64 for GitHub API
    content_base64=$(base64 -w0 "$output_file")

    # Create JSON data for the GitHub API request
    json_data=$(jq -n --arg content "$content_base64" '{ "message": "Update package-snapshot.txt", "content": $content }')

    # Upload the file to GitHub using the GitHub API
    response=$(curl -X PUT \
        -H "Authorization: token $github_token" \
        -H "Content-Type: application/json" \
        --data "$json_data" \
        "https://api.github.com/repos/$github_username/$github_repo/contents/$output_file")

    if [ $? -eq 0 ]; then
        echo "File uploaded to GitHub successfully."
    else
        echo "Error uploading file to GitHub: $response"
    fi
else
    echo "Error exporting package list."
fi
