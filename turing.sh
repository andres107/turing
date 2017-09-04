#!/bin/bash
path="$(dirname $(readlink -f $0))"
source "${path}/lib/icons.sh"
source "${path}/lib/color.sh"

env='default.env'
logo="${dir_base}logo.txt"

print_logo()
{
  eval "cat ${path}/$logo"
}

up()
{
  eval "docker-compose up -d"
}

logs()
{
  eval "docker-compose logs -f -t"
}

down()
{
  eval "docker-compose stop"
}

check_dir_django()
{
  exist=false
  if [ -d "src/${PROJECT_NAME}" ]
  then
    echo -e "${red}The directory src/$PROJECT_NAME already exist, please fix it before to run turing."
    exist=true
  fi
  if [ -d "src/${APP_NAME}" ]
  then
    echo -e "${red}The directory src/$APP_NAME already exist, please fix it before to run turing."
    exist=true
  fi
  if [ -e "src/manage.py" ]
  then
    echo -e "${red}The file src/manage.py already exist, please fix it before to run turing."
    exist=true
  fi

  if $exist
  then
    exit
  fi
}

mv_docker_compose()
{
  eval "cp ${dir_base}/docker-compose/${IMAGE}/docker-compose.yml ${PWD}/"
}

build_rails()
{
  if [ $IMAGE == 'rails' ]
  then
    echo -e -n "${green}${empty_start} Creating project in rails..."
    eval "(docker run -it --rm --user "$(id -u):$(id -g)" -v "$PWD":/usr/src/app -w /usr/src/app rails rails new --skip-bundle src >& error.log && echo -e '...done  $five_start') || (echo -e '${red}...failed' && exit)"
  else
    echo -e "\n\t${red}The file default.env no exist.${esc}"
    exit
  fi
}

build_django()
{
  if [ $IMAGE == 'django' ]
  then
    check_dir_django
    echo -e -n "${green}${empty_start} Creating project in django..."
    eval "(docker-compose run $IMAGE django-admin startproject $PROJECT_NAME . >& error.log && echo -e '...done  $five_start') || (echo -e '${red}...failed' && exit)"
    echo  -e -n "${green}${empty_start} Creating APP..."
    eval "(docker-compose run $IMAGE python manage.py startapp $APP_NAME >& error.log  && echo -e '...done ${five_start}') || (echo -e '${red}...failed' && exit)"
  else
    echo -e "\n\t${red}The file default.env no exist.${esc}"
    exit
  fi
}



build()
{
  select project in `ls $path/docker-compose`;
  do
    case $project in
      'django')
        build_django
        break
        ;;
      'rails')
        build_rails
        break
        ;;
    esac
  done
}

export_env()
{
  if [ -e $env ]
  then
    while read line
    do
      eval "export $line"
    done < $env
  fi
}

do_action()
{
  if [ $1 == 'build' ]
  then
    echo -e "\n${yellow}${empty_start} Building the project..."
    build
    echo -e "${yellow} ...done $five_start"
  elif [ $1 == 'up' ]
  then
    up
  elif [ $1 == 'down' ]
  then
    down
  elif [ $1 == 'logs' ]
  then
    logs
  fi
}

check_parameters()
{
  if [ $1 != 1 ]
  then
    echo -e "\n Use"
    echo -e "\t$0 [OPTION]"
    echo -e " Options"
    echo -e "\tbuild   Build a new project."
    echo -e "\trun     run the project."
    echo -e "\tlogs    show the project's logs."
    echo -e "\tdown    stop the project's containers.\n"
    exit
  fi
}

print_logo
check_parameters $#
export_env
SCRIPT=$(readlink -f $0);
dir_base=`dirname $SCRIPT`;
mv_docker_compose
do_action $1
