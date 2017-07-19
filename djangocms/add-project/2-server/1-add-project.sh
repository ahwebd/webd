#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../../../common-variables
source $script_dir/../../../3-wsgiserver/1-variables
source $script_dir/../1-variables

# create database and its user
#==============================
db=$web_env'_'$project
db_user=$db
db_user_password=$(openssl rand -hex 8);

docker exec $(docker ps -f name=^/dbserver. -q | sed -n 1p) psql -U postgres -c \
  "CREATE USER $db_user WITH PASSWORD '$db_user_password';"
docker exec $(docker ps -f name=^/dbserver. -q | sed -n 1p) psql -U postgres -c \
  "CREATE DATABASE $db OWNER $db_user;"

# install project
#==================

# Python virtual environment
if [ ! -d "$apps_dir/venvs/$project_venv" ]; then
  docker run --rm --user $(id -u):$(id -u) -v $apps_dir:$apps_dir $python bash -c \
    "python -m venv --copies $apps_dir/venvs/$project_venv &&
     source $apps_dir/venvs/$project_venv/bin/activate &&
     pip install --cache-dir $apps_dir/venvs/pipcache --upgrade pip &&
     pip install --cache-dir $apps_dir/venvs/pipcache psycopg2 djangocms-installer==$djangocms_installer_version"
fi

docker run --rm --user $(id -u):$(id -u) -v $apps_dir:$apps_dir -v pgsockets:/var/run/postgresql $python bash -c \
  "source $apps_dir/venvs/$project_venv/bin/activate &&
  djangocms -f \
    --db postgres://$db_user:$db_user_password@%2Fvar%2Frun%2Fpostgresql/$db \
    --timezone $timezone \
    --permissions $permissions \
    --languages $languages \
    --bootstrap $bootstrap \
    --starting-page $starting_page \
    --django-version $django_version \
    --cms-version $cms_version \
    -p $apps_dir/$web_env/$project $project &&
  python $apps_dir/$web_env/$project/manage.py collectstatic --noinput -v 0"

# settings.py
echo "
# Custom

ALLOWED_HOSTS += ['$web_env.$project']
MIDDLEWARE += ('django.contrib.sites.middleware.CurrentSiteMiddleware',)
" | tee -a $apps_dir/$web_env/$project/$project/settings.py

# nginx config file
cp $script_dir/nginx_example.conf $apps_dir/$web_env/$project/nginx_$web_env.$project.conf &&
sed -i "s/projectname/$project/g" $apps_dir/$web_env/$project/nginx_$web_env.$project.conf &&
sed -i "s/web_env/$web_env/g" $apps_dir/$web_env/$project/nginx_$web_env.$project.conf &&
sed -i "s|apps_dir|$apps_dir|g" $apps_dir/$web_env/$project/nginx_$web_env.$project.conf &&
sudo ln -s $apps_dir/$web_env/$project/nginx_$web_env.$project.conf /var/lib/docker/volumes/nginx_conf/_data

# uwsgi config file
cp $script_dir/uwsgi_example.ini $apps_dir/$web_env/$project/uwsgi_$web_env.$project.ini &&
sed -i "s/projectname/$project/g" $apps_dir/$web_env/$project/uwsgi_$web_env.$project.ini &&
sed -i "s/web_env/$web_env/g" $apps_dir/$web_env/$project/uwsgi_$web_env.$project.ini &&
sed -i "s|apps_dir|$apps_dir|g" $apps_dir/$web_env/$project/uwsgi_$web_env.$project.ini &&
sed -i "s/project_venv/$project_venv/g" $apps_dir/$web_env/$project/uwsgi_$web_env.$project.ini &&
sudo ln -s $apps_dir/$web_env/$project/uwsgi_$web_env.$project.ini /var/lib/docker/volumes/uwsgi_vassals/_data

# restart servers
docker stop $(docker ps -f name=^/wsgiserver. -q)
docker stop $(docker ps -f name=^/webserver. -q)
