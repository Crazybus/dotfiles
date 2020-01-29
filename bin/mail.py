#!/usr/bin/env python3

import mailbox
import requests
import os
from requests.auth import HTTPBasicAuth

pr_url_state_map = {}


def update_mbox(mail_dir):
    mbox = mailbox.Maildir(mail_dir)
    mbox.lock()
    try:
        for message_id, message in mbox.iteritems():
            if "notifications@github.com" in message["from"]:
                content = get_message(message)
                pr_url = get_pull_request_url(content)
                if pr_url and pr_url in pr_url_state_map:
                    pr = pr_url_state_map[pr_url]
                    print(f"Updating: {message['subject']}")
                    del message["Status"]
                    del message["Users"]
                    if "state" in pr:
                        message.add_header("Status", pr["state"])
                    if "users" in pr:
                        message.add_header("Users", pr["users"])
                    mbox[message_id] = message
    finally:
        mbox.flush()
        mbox.unlock()


def get_message(message):
    maintype = message.get_content_maintype()
    if maintype == "multipart":
        for part in message.get_payload():
            if part.get_content_maintype() == "text":
                return part.get_payload()
        return ""
    elif maintype == "text":
        return message.get_payload()


def get_pull_request_url(content):
    lastline = content.strip().split("\n")[-1]
    if "https://github.com" in lastline:
        u = "/".join(lastline.replace("https://github.com/", "", 1).split("/", 4)[:4])
        return u.split("#")[0].strip()
    return False


def add_pr_state(url):
    if url in pr_url_state_map:
        return
    owner, repo, rtype, number = parse_github_url(url)
    if rtype == "pulls":
        data = graphql_pr(owner, repo, number)
        if not data:
            return
        state, users = extract_pr(data)
        print(f"state: {state}, users: {users}, url: {url}")
        pr_url_state_map[url] = {"state": state, "users": users}
    elif rtype == "issues":
        data = graphql_issue(owner, repo, number)
        if not data:
            return
        state, users = extract_issue(data)
        pr_url_state_map[url] = {"state": state, "users": users}
        print(f"state: {state}, users: {users}, url: {url}")


def read_mail(mail_dir):
    mbox = mailbox.Maildir(mail_dir)
    for message_id, message in mbox.iteritems():
        if "notifications@github.com" in message["from"]:
            content = get_message(message)
            pr_url = get_pull_request_url(content)
            if pr_url:
                add_pr_state(pr_url)


def parse_github_url(url):
    owner, repo, rtype, number = url.split("/")
    if rtype == "pull":
        rtype = "pulls"
    return owner, repo, rtype, number


def graphql(query):
    json = {"query": query}
    r = requests.post(
        url="https://api.github.com/graphql",
        json=json,
        auth=HTTPBasicAuth(os.environ["GITHUB_USER"], os.environ["GITHUB_TOKEN"]),
    )

    try:
        return r.json()["data"]
    except:
        return None


def graphql_pr(owner, repo, number):
    query = """
    { repository(owner: "%s", name: "%s") {
        pullRequest(number: %s) {
          state
          commits(last: 1) {
            edges {
              node {
                commit {
                  status{
                    state
                  }
                }
              }
            }
          }
          labels(first: 100) {
            edges {
              node {
                name
              }
            }
          }
          reviewRequests(first: 100) {
            edges{
              node {
                requestedReviewer {
                  ... on User {
                    login
                  }
                  ... on Team {
                    name
                  }
                }
              }
            }
          }
          reviews(first: 100) {
            edges {
              node {
                state
                author {
                  login
                }
              }
            }
          }
        }
      }
    }
    """ % (
        owner,
        repo,
        number,
    )
    data = graphql(query)
    if data == None or data["repository"] == None:
        return False
    return data["repository"]["pullRequest"]


def graphql_issue(owner, repo, number):
    query = """
{
  repository(owner: "%s", name: "%s") {
    issue(number: %s) {
      state
      labels(first: 100) {
        nodes {
          name
        }
      }
      author {
        login
      }
      assignees(first: 100) {
        nodes {
          login
        }
      }
      participants(last: 10) {
        nodes {
          login
        }
      }
    }
  }
}
    """ % (
        owner,
        repo,
        number,
    )
    data = graphql(query)
    if data == None or data["repository"] == None:
        return False
    return data["repository"]["issue"]


def extract_issue(d):
    state = d["state"].lower()
    label = None
    participants = []
    for participant in d["participants"]["nodes"]:
        participants.append(participant["login"])
    participants = ",".join(participants)

    assignees = []
    for a in d["assignees"]["nodes"]:
        assignees.append(a["login"])
    assignees = ",".join(assignees)

    author = d["author"]["login"]

    for l in d["labels"]["nodes"]:
        name = l["name"]
        if name.startswith("area:"):
            label = name.replace("area:", "")

    state_string = f"{state}, author: {author}, owners: {assignees}"
    users = f"{participants}"
    if label:
        state_string += f", area: {label}"
    return state_string, users


def extract_pr(d):
    state = d["state"].lower()
    label = None
    reviewers = {}
    for reviewer in d["reviews"]["edges"]:
        reviewers[reviewer["node"]["author"]["login"]] = reviewer["node"][
            "state"
        ].lower()

    for reviewer in d["reviewRequests"]["edges"]:
        if "login" in reviewer["node"]["requestedReviewer"]:
            name = reviewer["node"]["requestedReviewer"]["login"]
        if "name" in reviewer["node"]["requestedReviewer"]:
            name = reviewer["node"]["requestedReviewer"]["name"]
        reviewers[name] = "requested"

    review_list = []
    for k, v in reviewers.items():
        review_list.append(f"{k}: {v}")

    reviews = ", ".join(review_list)

    for l in d["labels"]["edges"]:
        name = l["node"]["name"]
        if name.startswith("area:"):
            label = name.replace("area:", "")

    status = d["commits"]["edges"][0]["node"]["commit"]["status"]
    if status == None:
        status = "unknown"
    else:
        status = status["state"].lower()

    state_string = f"state: {state}, status: {status}"
    if label:
        state_string += f", area: {label}"
    return state_string, reviews


if __name__ == "__main__":
    for b in ['inbox','today']:
        box = "/home/mick/.mail/elastic/" + b
        read_mail(box)
        update_mbox(box)
