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
                if pr_url:
                    state = pr_url_state_map.get(pr_url, "unknown")
                    print(f"Updating: {message['subject']}")
                    del message["Status"]
                    message.add_header("Status", state)
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
    lastline = content.split("\n")[-1]
    if "https://github.com" in lastline and "/pull/" in lastline:
        return lastline.split("#")[0]
    return False


def add_pr_state(url):
    if url not in pr_url_state_map:
        print(f"Adding url: {url}")
        pr_url_state_map[url] = get_pr_state(url)
    else:
        print(f"skipping url: {url}")


def read_mail(mail_dir):
    mbox = mailbox.Maildir(mail_dir)
    for message_id, message in mbox.iteritems():
        if "notifications@github.com" in message["from"]:
            content = get_message(message)
            pr_url = get_pull_request_url(content)
            if pr_url:
                add_pr_state(pr_url)


def get_pr_state(url):
    org, repo, number = parse_github_url(url)
    token = os.environ["GITHUB_TOKEN"]
    response = requests.get(
        f"https://api.github.com/repos/{org}/{repo}/pulls/{number}",
        auth=HTTPBasicAuth("Crazybus", token),
    )
    d = response.json()

    try:
        state = d["state"]
        if d["merged"]:
            state = "merged"
    except:
        state = "unknown"
    return state


def parse_github_url(url):
    u = url.strip("https://github.com")
    org, repo, _, number = u.split("/")
    return org, repo, number


box = "/Users/mick/.mail/elastic/inbox"
read_mail(box)
update_mbox(box)
