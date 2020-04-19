set -ex

sed -i -e "s/'macdeployqt'//g" osxcross-extras/install_extras.sh

TAG=osxcross
docker build -t $TAG  .
docker run -dit $TAG
CONTAINER_ID=$(docker ps -alq)
FILE=$(docker exec $CONTAINER_ID sh -c "ls /opt/osxcross/*.tar.xz")
docker cp $CONTAINER_ID:$FILE .
docker stop $CONTAINER_ID
