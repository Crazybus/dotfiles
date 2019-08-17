#!/usr/bin/env python3

import pytest

from mail import *


def test_parse_github_url_pull():
    url = "owner/repo/pull/12345"
    owner, repo, rtype, number = parse_github_url(url)
    assert owner == "owner"
    assert repo == "repo"
    assert rtype == "pulls"
    assert number == "12345"


def test_parse_github_url_issue():
    url = "owner/repo/issue/12345"
    owner, repo, rtype, number = parse_github_url(url)
    assert owner == "owner"
    assert repo == "repo"
    assert rtype == "issue"
    assert number == "12345"


def test_get_pull_request_url():
    content = "https://github.com/owner/repo/pull/12345"
    assert get_pull_request_url(content) == "owner/repo/pull/12345"


def test_get_pull_request_url_ignore_extra():
    content = "https://github.com/owner/repo/pull/12345/otherstuff"
    assert get_pull_request_url(content) == "owner/repo/pull/12345"


def test_get_pull_request_url_ignore_after_hash():
    content = "https://github.com/owner/repo/pull/12345#otherstuff"
    assert get_pull_request_url(content) == "owner/repo/pull/12345"


def test_get_pull_request_url_multiline():
    content = """
    some other stuff 
    https://github.com/owner/repo/pull/12345"""
    assert get_pull_request_url(content) == "owner/repo/pull/12345"


def test_get_pull_request_url_no_github_url():
    content = "no github"
    assert get_pull_request_url(content) == False


def test_extract_issue():
    d = {
        "state": "CLOSED",
        "participants": {"nodes": [{"login": "Crazybus"}, {"login": "OtherBus"}]},
        "assignees": {"nodes": [{"login": "AssignedBus"}]},
        "author": {"login": "AuthorBus"},
        "labels": {"nodes": [{"name": "area:test"}]},
    }
    state_string, users = extract_issue(d)

    assert state_string == "closed, author: AuthorBus, owners: AssignedBus, area: test"
    assert users == "Crazybus,OtherBus"


def test_extract_pr():
    d = {
        "state": "MERGED",
        "reviews": {
            "edges": [{"node": {"state": "APPROVED", "author": {"login": "Crazybus"}}}]
        },
        "reviewRequests": {
            "edges": [{"node": {"requestedReviewer": {"login": "CrazyRequest"}}}]
        },
        "labels": {"edges": [{"node": {"name": "area:test"}}]},
        "commits": {"edges": [{"node": {"commit": {"status": {"state": "FAILED"}}}}]},
    }
    state_string, reviews = extract_pr(d)

    assert state_string == "state: merged, status: failed, area: test"
    assert reviews == "Crazybus: approved, CrazyRequest: requested"
