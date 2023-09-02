![Image](https://github.com/michell-dev/PackagebaseExporter/blob/main/preview.png?raw=true)

This script simplifies the process of exporting currently installed Pacman packages, condensing the list of software into a convenient and manageable format. It ensures quick and efficient retrieval of package information, making system maintenance and backups a breeze.

## Creation 
##### 01. Create the Bash file:

~~~ 
sudo touch yourpackagebasename.sh
~~~

##### 02. Make it executable:

~~~
sudo chmod +x yourpackagebasename.sh
~~~

##### 03. Copy and paste this code into the file and save:

~~~ 
#!/bin/bash

# Define the output file name
output_file="package-snapshot.txt"

# Use pacman to list installed packages and save the output to the file
pacman -Qdt > "$output_file"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Package list exported to $output_file"
else
    echo "Error exporting package list."
fi
~~~

##### 04. run it using `./export-packages.sh`. This will create a `package-snapshot.txt` file containing the list of installed Pacman packages in the current directory.


## Automation

To make the script run just before you turn off your PC, utilize a systemd service that triggers the script during the shutdown process. Here's how you can create and configure a systemd service for this purpose:

##### 01. Create a new systemd service unit file. Run the following command to create the service unit file:

~~~
sudo nano /etc/systemd/system/export-packages.service
~~~

##### 02. Add the following content to the `export-packages.service` file:

~~~
[Unit]
Description=Export Pacman packages list before shutdown
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/bin/true
ExecStop=/path/to/your/export-packages.sh

[Install]
WantedBy=shutdown.target
~~~

Replace `/path/to/your/export-packages.sh` with the actual path to your script.

##### 03. Enable the service:

~~~
sudo systemctl enable export-packages.service
~~~

##### 04. Create a systemd target that runs the service before shutdown:

~~~
sudo nano /etc/systemd/system/export-packages.target
~~~

##### 05. Add the following content to the `export-packages.target` file:

~~~
[Unit]
Description=Run export-packages service before shutdown
Documentation=man:systemd.special(7)

[Install]
WantedBy=multi-user.target
~~~

##### 06. Set the new target as the default target before shutdown:

~~~
sudo systemctl set-default export-packages.target
~~~


Now, when you shut down your PC, the `export-packages.sh` script will be executed, and the list of installed Pacman packages will be exported to the `package-snapshot.txt` file just before the system turns off.

## GitHub Integration

To automatically upload the `package-snapshot.txt` file to your GitHub repository after running the script, you can use the GitHub API and create a personal access token.

##### 01. **Generate a Personal Access Token:**

- Go to your GitHub account settings.
- Click on "Developer settings" or "Developer settings" > "Personal access tokens" (depending on your GitHub version).
- Click on "Generate token."
- Give it a name and select the necessary scopes (likely "repo" or "public_repo" for uploading to a repository).
- Generate the token and make sure to save it securely.

##### 02. Modify The Script:

You need to modify your `export-packages.sh` script to upload the file to your GitHub repository. You can use the `curl` command along with the GitHub API for this:

~~~
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
~~~

Replace `"YourGitHubUsername"`, `"YourGitHubRepoName"`, and `"YourGitHubAccessToken"` with your actual GitHub username, repository name, and the personal access token generated in step 1.

##### 03. Running The Script:

Save the modified script and make it executable using `chmod +x export-packages.sh`. Then, you can run it using `./export-packages.sh`. This script will first export the package list to `package-snapshot.txt` and then upload it to your specified GitHub repository.

