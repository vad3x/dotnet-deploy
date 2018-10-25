set -e

ENV_VARS=()

while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
            v="${1/--/}"
            declare $v="$2"

            if [[ $1 == *"--env"* ]]; then
                ENV_VARS+=($2)
            fi
    fi

    shift
done

SERVICE_FILE_PATH=$o/$s.service
WORK_DIR=$rservdir/$s/current

echo "  Creating service '$s' ..."
echo "  Working directory '$WORK_DIR'"
echo "  Creating file '$SERVICE_FILE_PATH'..."

mkdir -p $o
rm -f $SERVICE_FILE_PATH
touch $SERVICE_FILE_PATH

echo "  Filling file '$SERVICE_FILE_PATH'..."

{
    echo "[Unit]"
    echo "Description=$s Service" 
    echo ""
    echo "[Service]"
    echo "WorkingDirectory=$WORK_DIR"
    echo "ExecStart=/usr/bin/dotnet $WORK_DIR/$dll --environment $e"
    echo "Restart=always"
    echo "RestartSec=10"
    echo "User=$user"
    echo "SyslogIdentifier=$s"
    if [[ $port ]]; then
        echo "Environment=ASPNETCORE_URLS=http://+:$port"
    fi

    for env in "${ENV_VARS[@]}"
    do
        echo "Environment=$env"
    done

    echo ""
    echo "[Install]"
    echo "WantedBy=multi-user.target"
} >> $SERVICE_FILE_PATH

echo "  Done."
