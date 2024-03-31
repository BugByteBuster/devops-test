import getpass
import random
import string
import datetime
import git
from github import Github

# Update the specified key with a new value in a file
def update_terraform_tfvars(file_path, key, new_value):
    updated_lines = []
    with open(file_path, 'r') as f:
        for line in f:
            if line.strip().startswith(key):
                line = f"{key} = \"{new_value}\"\n"
            updated_lines.append(line)

    with open(file_path, 'w') as f:
        f.writelines(updated_lines)

# Generate a random string
def generate_random_string(length=6):
    return ''.join(random.choice(string.ascii_lowercase) for _ in range(length))

# Generate a dynamic branch name
def generate_branch_name():
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    username = getpass.getuser()
    random_string = generate_random_string()
    return f"update-{username}-{timestamp}-{random_string}"

# Create a new branch in the Git repository
def create_branch():
    branch_name = generate_branch_name()
    repo = git.Repo(search_parent_directories=True)
    repo.git.checkout("-b", branch_name)
    return branch_name

# Commit and push changes to the Git repository
def commit_and_push_changes(file_path, key, new_value, branch_name):
    update_terraform_tfvars(file_path, key, new_value)
    repo = git.Repo(search_parent_directories=True)
    repo.index.add([file_path])
    repo.index.commit(f"Update {key} to {new_value}")
    origin = repo.remote(name='origin')
    origin.push(refspec=branch_name)

# Create a pull request on GitHub
def create_pull_request(repo_owner, repo_name, base_branch, head_branch, title, body, access_token):
    g = Github(access_token)
    repo = g.get_repo(f"{repo_owner}/{repo_name}")
    pr = repo.create_pull(title=title, body=body, base=base_branch, head=head_branch)
    return pr

# Main function
def main():
    file_path = input("Enter the path to the terraform.tfvars file: ")
    key = "nginx_image"
    new_value = input("Enter the new version for nginx_image: ")
    access_token = input("Enter your GitHub personal access token: ")
    repo_owner, repo_name = input("Enter repo owner and name in this format ex: username reponame: ").split()

    branch_name = create_branch()
    commit_and_push_changes(file_path, key, new_value, branch_name)
    pr_title = f"Update {key} to {new_value}"
    pr_body = "Please review and merge this pull request."
    pr = create_pull_request(repo_owner, repo_name, base_branch="main", head_branch=branch_name, title=pr_title, body=pr_body, access_token=access_token)
    print(f"Pull request raised for changes in branch: {branch_name}")
    print(f"Pull request URL: {pr.html_url}")

if __name__ == "__main__":
    main()
