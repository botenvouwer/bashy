E_WRONG_ARGS=85

script_parameters="-a -h -m -z"

#get directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo $DIR

#-a = all, -h = help, etc.
if [ $# -ne 4 ]
then

  echo "Usage: `basename $0` $script_parameters"

  # `basename $0` is the script's filename.
  exit $E_WRONG_ARGS

fi

