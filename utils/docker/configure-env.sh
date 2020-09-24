PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

NAME=$(id -u -n)
GID=$(id -g)

rm $PARENT_PATH/../.env 2> /dev/null

echo USER_UID=$UID >> $PARENT_PATH/../.env
echo USER_GID=$GID >> $PARENT_PATH/../.env
echo USER_NAME=$NAME >> $PARENT_PATH/../.env
