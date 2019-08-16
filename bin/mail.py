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
                if pr_url and "13711" in pr_url:
                    pr = pr_url_state_map[pr_url]
                    print(f"Updating: {message['subject']}")
                    del message["Status"]
                    message.add_header("Status", pr["state"])
                    message.add_header("Reviews", pr["reviews"])
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
        u = "/".join(lastline.strip("https://github.com").split("/", 4)[:4])
        return u.split("#")[0]
    return False


def add_pr_state(url):
    if url in pr_url_state_map:
        return
    owner, repo, rtype, number = parse_github_url(url)
    if rtype != "pulls":
        return
    data = graphql(owner, repo, number)
    state, reviews = extract_pr(data)
    print(f"state: {state}, reviews: {reviews}, url: {url}")
    pr_url_state_map[url] = {"state": state, "reviews": reviews}


def read_mail(mail_dir):
    mbox = mailbox.Maildir(mail_dir)
    for message_id, message in mbox.iteritems():
        if "notifications@github.com" in message["from"]:
            content = get_message(message)
            pr_url = get_pull_request_url(content)
            if pr_url:
                add_pr_state(pr_url)
                return


def parse_github_url(url):
    owner, repo, rtype, number = url.split("/")
    if rtype == "pull":
        rtype = "pulls"
    return owner, repo, rtype, number


def graphql(owner, repo, number):
    url = "https://api.github.com/graphql"
    token = os.environ["GITHUB_TOKEN"]
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
    json = {"query": query}
    r = requests.post(
        url=url, json=json, auth=HTTPBasicAuth(os.environ["GITHUB_USER"], token)
    )
    d = r.json()["data"]["repository"]["pullRequest"]
    return d


def extract_pr(d):
    state = d["state"].lower()
    label = None
    reviewers = {}
    for reviewer in d["reviews"]["edges"]:
        reviewers[reviewer["node"]["author"]["login"]] = reviewer["node"][
            "state"
        ].lower()

    for reviewer in d["reviewRequests"]["edges"]:
        reviewers[reviewer["node"]["requestedReviewer"]["login"]] = "requested"

    review_list = []
    for k, v in reviewers.items():
        review_list.append(f"{k}: {v}")

    reviews = ", ".join(review_list)

    for l in d["labels"]["edges"]:
        name = l["node"]["name"]
        if name.startswith("area:"):
            label = name.replace("area:", "")
    status = d["commits"]["edges"][0]["node"]["commit"]["status"]["state"].lower()

    state_string = f"state: {state}, status: {status}"
    if label:
        state_string += ", area: {label}"
    return state_string, reviews


box = "/Users/mick/tmp/mailboxbackup/inbox"
read_mail(box)
update_mbox(box)
