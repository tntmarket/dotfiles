# from __future__ import unicode_literals

import getpass
import os
import requests
from addict import Dict
from bs4 import BeautifulSoup
from collections import namedtuple
from workflow import Workflow3
from workflow import MATCH_STARTSWITH
from workflow import MATCH_ATOM
from workflow import MATCH_SUBSTRING
from workflow.background import run_in_background
from workflow.background import is_running


TTL = 60 * 60 * 24 * 7
JenkinsJob = namedtuple('JenkinsJob', 'name url cluster')
ShortUrl = namedtuple('ShortUrl', 'name target')
PypiPackage = namedtuple('PypiPackage', 'name target version_text')


def normalize_string(string):
    return string.replace('-', '').replace('_', '')


def update_cache(wf, args):
    cache = args[0]
    data_func = {
        'jenkins': get_jenkins_jobs,
        'shorturl': get_shortlinks,
        'pypi': get_pypi,
        'confludex': get_confludex,
    }
    wf.cached_data(cache, data_func[cache], max_age=TTL)


def cached_data(wf, cache):
    if not wf.cached_data_fresh(cache, max_age=TTL):
        run_in_background('update', ['venv/bin/python', wf.workflowfile('yelp.py'), 'update-cache', cache])

    if is_running('update'):
        wf.add_item('Updating cache...', valid=False)

    return wf.cached_data(cache, None, max_age=0)


def get_jenkins_jobs():
    r = requests.get('https://jenkins.yelpcorp.com/api_v1.json')
    r.raise_for_status()

    jenkins_jobs = Dict(r.json())
    jobs = [
        JenkinsJob(name, job.url, cluster_name)
        for cluster_name, cluster in jenkins_jobs.clusters.items()
        for name, job in cluster.jobs.items()
    ]
    views = [
        JenkinsJob(name, job.url, cluster_name)
        for cluster_name, cluster in jenkins_jobs.clusters.items()
        for name, job in cluster.views.items()
    ]
    return jobs + views


def jenkins(wf, args):
    result = cached_data(wf, 'jenkins')

    if result and args:
        query = normalize_string(args[0])
        result = wf.filter(
            query,
            result,
            key=lambda x: normalize_string('{} {}'.format(x.cluster, x.name)),
            max_results=10,
            min_score=60,
            match_on=MATCH_STARTSWITH ^ MATCH_ATOM ^ MATCH_SUBSTRING,
        )

    for i in result:
        wf.add_item(
            title=i.name,
            subtitle=i.url,
            arg=i.url,
            valid=True,
        )

    wf.send_feedback()


def get_shortlinks():
    r = requests.get('https://y.yelpcorp.com/api/list')
    r.raise_for_status()

    shorturl = Dict(r.json())
    result = [
        ShortUrl(name, target)
        for name, target in shorturl.data
    ]
    return result


def shorturl(wf, args):
    result = cached_data(wf, 'shorturl')

    if result and args:
        query = normalize_string(args[0])
        result = wf.filter(
            query,
            result,
            key=lambda x: normalize_string(x.name),
            max_results=10,
            min_score=60,
        )

    for i in result:
        wf.add_item(
            title=i.name,
            subtitle=i.target,
            arg=i.target,
            valid=True,
        )

    wf.send_feedback()


def get_pypi():
    pypi_url = 'https://pypi.yelpcorp.com/'
    r = requests.get(pypi_url)
    r.raise_for_status()

    soup = BeautifulSoup(r.text)
    packages = [
        PypiPackage(i['data-name'], pypi_url + i['href'], i.text.strip())
        for i in soup.select('#packages a')
    ]
    return packages


def pypi(wf, args):
    result = cached_data(wf, 'pypi')

    if result and args:
        query = normalize_string(args[0])
        result = wf.filter(
            query,
            result,
            key=lambda x: normalize_string(x.name),
            max_results=10,
            min_score=60,
        )

    for i in result:
        wf.add_item(
            title=i.name,
            subtitle=i.version_text,
            arg=i.target,
            valid=True,
        )

    wf.send_feedback()


def get_confludex():
    confludex = 'https://people.yelpcorp.com/~tzhu/confludex/dump.json'
    r = requests.get(confludex)
    r.raise_for_status()

    pages = r.json()
    return pages


def confludex(wf, args):
    result = cached_data(wf, 'confludex')

    if result and args:
        query = normalize_string(args[0])
        result = wf.filter(
            query,
            result,
            key=lambda x: normalize_string(x[1]),
            max_results=10,
            min_score=60,
        )

    for space, page in result:
        wf.add_item(
            title=page,
            subtitle=space,
            arg='https://yelpwiki.yelpcorp.com/display/{}/{}'.format(space, page),
            valid=True,
        )

    wf.add_item(
        title='Search in Confluence...',
        arg='https://yelpwiki.yelpcorp.com/dosearchsite.action?queryString={}'.format(' '.join(args)),
        valid=True,
    )

    wf.send_feedback()


def love_get_api_key():
    return os.environ['yelplove_api_key']


def love_autocomplete(wf, search_name):
    search_name = ' '.join(search_name)
    r = requests.get('https://yelplove.appspot.com/api/autocomplete', params={
        'api_key': love_get_api_key(),
        'term': search_name,
    })
    r.raise_for_status()

    result = [
        (i['value'], i['label'])
        for i in r.json()
    ]

    result = wf.filter(
        search_name,
        result,
        key=lambda x: ' '.join(x),
        max_results=10,
        min_score=60,
    )

    for name, title in result:
        wf.add_item(
            title='Send love to {}'.format(name),
            subtitle=title,
            autocomplete=name,
            valid=True,
            arg=name,
        )

    wf.send_feedback()


def love_send(wf, message):
    requests.post('https://yelplove.appspot.com/api/love', data={
        'api_key': love_get_api_key(),
        'sender': getpass.getuser(),
        'recipient': os.environ['recipient'],
        'message': message,
    })


def main(wf):
    subcommand_mapping = {
        'jenkins': jenkins,
        'shorturl': shorturl,
        'pypi': pypi,
        'confludex': confludex,
        'love_autocomplete': love_autocomplete,
        'love_send': love_send,
        'update-cache': update_cache,
    }
    subcommand = subcommand_mapping.get(wf.args[0])

    if subcommand:
        subcommand(wf, wf.args[1:])
    else:
        raise NotImplementedError('Not supported keyword: {}'.format(wf.args[0]))


if __name__ == u"__main__":
    wf = Workflow3()
    wf.run(main)
