#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../../../common-variables
source $script_dir/../../../3-wsgiserver/1-variables
source $script_dir/../1-variables

# install tools for development
docker run --rm --user $(id -u):$(id -u) -v $apps_dir:$apps_dir $python bash -c \
  "source $apps_dir/venvs/$project_venv/bin/activate &&
   pip install --cache-dir $apps_dir/venvs/pipcache django-debug-toolbar"

# settings.py

internal_ip=$( docker network inspect -f "{{with index .Containers \"ingress-sbox\"}}{{.IPv4Address}}{{end}}" ingress )
internal_ip=${internal_ip%/*}

echo "
ALLOWED_HOSTS += ['localhost','testserver']
DEBUG_TOOLBAR = True
if DEBUG and DEBUG_TOOLBAR:
    MIDDLEWARE += ('debug_toolbar.middleware.DebugToolbarMiddleware',)
    INSTALLED_APPS += ('debug_toolbar',)
    INTERNAL_IPS = ('$internal_ip',)
" | tee -a $apps_dir/$web_env/$project/$project/settings.py

# urls.py
echo "
# Custom

# Debug toolbar
if settings.DEBUG and settings.DEBUG_TOOLBAR:
    import debug_toolbar
    urlpatterns = [
        url(r'^__debug__/', include(debug_toolbar.urls)),
    ] + urlpatterns
" | tee -a $apps_dir/$web_env/$project/$project/urls.py

# collectstatic
docker run --rm --user $(id -u):$(id -u) -v $apps_dir:$apps_dir $python bash -c \
  "source $apps_dir/venvs/$project_venv/bin/activate &&
  python $apps_dir/$web_env/$project/manage.py collectstatic --noinput -v 0"

# restart wsgiserver
docker stop $(docker ps -f name=^/wsgiserver. -q)
