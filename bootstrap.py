import json
import os
import sys

CWD = os.getcwd()
HOME = os.getenv('HOME')


def link(source_path, link_path):
    file_exists = os.access(link_path, os.F_OK)
    if not file_exists or (file_exists and
                           not (os.readlink(link_path) == source_path)):
        os.symlink(source_path, link_path)


def main():
    config_dir = os.path.dirname(sys.argv[0])
    links = {}
    with open(os.path.join(config_dir, 'config.json'), 'r') as f:
        try:
            links = json.load(f)
        except ValueError as json_exception:
            print >> sys.stderr, json_exception
            sys.exit(1)

    for source, link_name in links.iteritems():
        source_path = os.path.join(CWD, source)
        link_path = os.path.join(HOME, link_name)
        link(source_path, link_path)

if __name__ == '__main__':
    main()
