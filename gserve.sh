set -e

SERVICES=()

for var in "$@"
do
    SERVICES+=($var)
done

SERVE_FILE_PATH=./build/systemd/serve.sh

echo "Creating serve file for services:"
for s in "${SERVICES[@]}"
do
    echo "-- $s"
done
echo "Creating file '$SERVE_FILE_PATH'..."

mkdir -p ./build/systemd
rm -f $SERVE_FILE_PATH
touch $SERVE_FILE_PATH

echo "Filling file '$SERVE_FILE_PATH'..."

{
    echo "echo Reloading Daemon..."
    echo "systemctl daemon-reload"

    for s in "${SERVICES[@]}"
    do
        echo "echo -- '$s' ^ ..."
        echo "systemctl enable $s.service"

        echo "echo -- '$s' - ..."
        echo "systemctl stop $s.service"

        echo "echo -- '$s' + ..."
        echo "systemctl start $s.service"
    done
} >> $SERVE_FILE_PATH

echo "Done."
