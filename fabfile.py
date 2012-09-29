import os
import json
from fabric.api import run, sudo, put, cd, env

settings = {}

FAB_DNA = os.environ.get('FAB_DNA', None)
# Try to load defaults from dna file
try:
    with open("dna/%s.json" % FAB_DNA) as f:
        contents = f.read()
        data = json.loads(contents)
        fab_data = data.get('fab', None)
        if fab_data is None:
            raise Exception("No fab data in dna file")
        settings = fab_data
except:
    print "Error decoding dna for fab defaults"

FAB_USER = os.environ.get('FAB_USER',           settings.get('fab_user', None))
FAB_HOSTNAME = os.environ.get('FAB_HOSTNAME',   settings.get('fab_hostname', None))
FAB_HOST = os.environ.get('FAB_HOST',           settings.get('fab_host', None))
FAB_PASSWORD = os.environ.get('FAB_PASSWORD',   settings.get('fab_password', None))
FAB_CHEF_REPO = os.environ.get('FAB_CHEF_REPO', settings.get('fab_chef_repo', None))

env.connection_attempts = 4
env.password = FAB_PASSWORD
env.host_string = '%s@%s' % (FAB_USER, FAB_HOST)


def test():
    sudo('hostname')


def set_up_new_server():
    bootstrap()
    update()
    chef()


def bootstrap():
    _add_line_if_not_present('/etc/hosts', '127.0.0.1 %s' % FAB_HOST, sudo)

    sudo('hostname %s' % FAB_HOSTNAME)
    sudo('apt-get update')
    sudo('apt-get upgrade -y')
    sudo('apt-get update')
    sudo('apt-get install -y git ruby1.9.1 ruby1.9.1-dev build-essential')
    sudo('gem install chef --no-ri --no-rdoc')


def update():
    run('mkdir ~/.ssh/ || true')
    run('chmod 700 ~/.ssh/')
    put('_keys/id_rsa', '~/.ssh/id_rsa')
    put('_keys/id_rsa.pub', '~/.ssh/id_rsa.pub')
    run('chmod 600 ~/.ssh/id_*')

    run('echo  >> ~/.ssh/known_hosts')

    _add_line_if_not_present('~/.ssh/known_hosts', "github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==")


def chef():
    sudo('apt-get update')
    run('rm -rf ~/deploy/')
    run('git clone %s' % FAB_CHEF_REPO)
    put('dna/%s.json' % FAB_DNA, '~/deploy/%s.json' % FAB_DNA)
    with cd('~/deploy/'):
        run('git pull')

        sudo('chef-solo -j dna/%s.json -c solo-config.rb' % FAB_DNA)


def _add_line_if_not_present(filename, line, run_f=run):
    run_f("grep -q -e '%s' %s || echo '%s' >> %s" % (line, filename, line, filename))
