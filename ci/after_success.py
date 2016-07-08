#!/usr/bin/env python

from __future__ import print_function

import httplib
import json
import os

JSON = 'application/json'

def trigger_appveyor_build():
    payload = {
        'accountName': 'malept',
        'projectSlug': 'rusty-blank',
        'branch': 'master',
    }

    headers = {
        'Accept': JSON,
        'Authorization': 'Bearer {}'.format(os.environ['APPVEYOR_TOKEN']),
        'Content-Type': JSON,
    }

    http = httplib.HTTPSConnection('ci.appveyor.com')
    http.request('POST', '/api/builds', json.dumps(payload), headers)
    print(http.getresponse().read())

def trigger_travis_build():
    msg = "Triggered by {}@{} ({})".format(os.environ['TRAVIS_REPO_SLUG'],
                                           os.environ['TRAVIS_BRANCH'],
                                           os.environ['TRAVIS_COMMIT'])
    payload = {
        "request": {
            "branch": "master",
            "message": msg,
        }
    }

    headers = {
        'Accept': JSON,
        'Authorization': 'token {}'.format(os.environ['TRAVIS_TOKEN']),
        'Content-Type': JSON,
        'Travis-Api-Version': '3',
    }

    http = httplib.HTTPSConnection('api.travis-ci.org')
    http.request('POST', '/repo/malept%2Frusty_blank/requests', json.dumps(payload), headers)
    print(http.getresponse().read())

if __name__ == '__main__':
    if os.environ['TRAVIS_RUBY_VERSION'].startswith('2.3.'):
        trigger_appveyor_build()
        trigger_travis_build()
