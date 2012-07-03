import json
import os
import sys

CWD = os.getcwd()
HOME = os.getenv('HOME')

links = {}
with open('config.json', 'r') as f:
    try:
        links = json.load(f)
    except ValueError as json_exception:
        print >> sys.stderr, json_exception
        sys.exit(1)

for source, link_name in links.iteritems():
    source_path = os.path.join(CWD, source)
    link_path = os.path.join(HOME, link_name)
    if os.access(link_path, os.F_OK) and \
            not (os.readlink(link_path) == source_path):
        os.symlink(source_path, link_path)
