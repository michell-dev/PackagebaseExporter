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

To run your script after every successful package installation using `pacman`, you can use the `pacman.d` hook system:

##### 01. **Create a Hook Script:**

Create a shell script that will be executed after each successful `pacman` package installation. You can name this script, for example, `mypostinstallhook.sh`, and place it in a suitable location (e.g., `/etc/pacman.d/hooks/`).

~~~
sudo nano /etc/pacman.d/hooks/mypostinstallhook.sh
~~~

###### Add the following content to the `mypostinstallhook.sh` script:

~~~
#!/bin/bash

# Define the path to your script
script_path="/path/to/your/script.sh"

# Check if the script is executable
if [ -x "$script_path" ]; then
    # Execute the script
    "$script_path"
fi
~~~

Replace `/path/to/your/script.sh` with the actual path to your script.

##### 02. Make the Hook Script Executable:

~~~
sudo chmod +x /etc/pacman.d/hooks/mypostinstallhook.sh
~~~

##### 03.**Create the Hook File**

Create a hook file in `/etc/pacman.d/hooks/` that specifies when the hook script should be executed. You can name the hook file something like `mypostinstallhook.hook`.

~~~
sudo nano /etc/pacman.d/hooks/mypostinstallhook.hook
~~~

######  Add the following content to the `mypostinstallhook.hook` file:

~~~
[Trigger]
Operation = Install
Type = Package
Target = *

[Action]
Description = Execute mypostinstallhook script
When = PostTransaction
Exec = /etc/pacman.d/hooks/mypostinstallhook.sh
~~~


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
github_username="michell-dev"
github_repo="archstation-dotfiles"
github_token="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"

# Use pacman to list installed packages and save the output to the file
pacman -Qdt > "$output_file"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Package list exported to $output_file"

    # Encode the file content as base64 for GitHub API
    content_base64=$(base64 -w0 "$output_file")

    # Create JSON data for the GitHub API request
    json_data=$(jq -n --arg content "$content_base64" '{ "message": "Update package-snapshot.txt", "content": $content }')

    # Get the SHA of the existing file (if it exists)
    sha=$(curl -H "Authorization: token $github_token" -s "https://api.github.com/repos/$github_username/$github_repo/contents/$output_file" | jq -r .sha)

    # Create JSON data with the SHA for the GitHub API request
    json_data=$(jq -n --arg content "$content_base64" --arg sha "$sha" '{ "message": "Update package-snapshot.txt", "content": $content, "sha": $sha }')

    # Upload the file to GitHub using the GitHub API with the SHA
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

