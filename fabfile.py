# -*- coding: utf-8 -*-
from fabric.api import env
from fabric.contrib.project import rsync_project, run, cd, local, sudo

env.hosts = ['10.100.0.51']

env.dstpath = '/var/www/test.tolkachyov.name'

virtual_env = "/var/www/virtualenvs/test.tolkachyov.name/"
python = "%sbin/python" % virtual_env
pip = "%sbin/pip" % virtual_env


def deploy():
    env.user = 'deploy'
    rsync_project(remote_dir=env.dstpath, local_dir=".", exclude=[".*", "node_modules", "*.pyc", "db.sqlite3"])
    with cd(env.dstpath):
        run("%s manage.py collectstatic --noinput" % python)
        run("touch uwsgi.ini")


def update_virtualenv():
    with cd(env.dstpath):
        run("%s install -r requirements.txt" % pip)


def migrate():
    with cd(env.dstpath):
        run("%s manage.py migrate --noinput" % python)
