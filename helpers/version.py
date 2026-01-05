import os
import subprocess

from flask import Flask, render_template_string

app = Flask(__name__)

REPO_PARENT_DIR = "/usr/local/tahti/repos"


def run_git_command(repo_path, command):
    try:
        return subprocess.check_output(
            command, cwd=repo_path, shell=True, text=True
        ).strip()
    except subprocess.CalledProcessError:
        return "N/A"


@app.route("/")
def git_status():
    repo_statuses = []
    for repo in os.listdir(REPO_PARENT_DIR):
        repo_path = os.path.join(REPO_PARENT_DIR, repo)

        if os.path.isdir(repo_path) and os.path.isdir(os.path.join(repo_path, ".git")):
            branch = run_git_command(repo_path, "git rev-parse --abbrev-ref HEAD")
            tag = run_git_command(repo_path, "git describe --tags --exact-match HEAD")
            commit = run_git_command(repo_path, "git rev-parse --short HEAD")

            repo_statuses.append(
                {"name": repo, "branch": branch, "tag": tag, "commit": commit}
            )

    html_template = """<!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>Git Repository Status</title>
       <style>
           body { font-family: Arial, sans-serif; }
           table { width: 100%%; border-collapse: collapse; }
           th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
           th { background-color: #333; color: white; }
       </style>
   </head>
   <body>
       <h2>Git Repository Status</h2>
       <table>
           <tr>
               <th>Repository</th>
               <th>Branch</th>
               <th>Tag</th>
               <th>Commit</th>
           </tr>
           {% for repo in repo_statuses %}
           <tr>
               <td>{{ repo.name }}</td>
               <td>{{ repo.branch }}</td>
               <td>{{ repo.tag }}</td>
               <td>{{ repo.commit }}</td>
           </tr>
           {% endfor %}
       </table>
   </body>
   </html>"""

    return render_template_string(html_template, repo_statuses=repo_statuses)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5080)
