set -e

while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
            v="${1/--/}"
            declare $v="$2"
    fi

    shift
done

SERVICES=($(ls $lservdir))

for service in "${SERVICES[@]}"
do
    LOCAL_PATH=$lservdir/$service/*
    RELEASE_REMOTE_PATH=$rservdir/$service/releases/$stamp
    SHARED_REMOTE_PATH=$rservdir/$service/shared
    SHARED_LOGS_REMOTE_PATH=$SHARED_REMOTE_PATH/logs

    echo "*** Release service: '$LOCAL_PATH' -> '$RELEASE_REMOTE_PATH' ***"
    ssh $server /bin/bash << EOF
      mkdir -p $RELEASE_REMOTE_PATH $SHARED_REMOTE_PATH $SHARED_LOGS_REMOTE_PATH;
      ln -sf $SHARED_REMOTE_PATH/* $RELEASE_REMOTE_PATH/
    EOF
    rsync -az --stats --delete $LOCAL_PATH $server:$RELEASE_REMOTE_PATH
done

echo "*** Release systemd '$lservdir/../systemd/serve.sh' -> '$server:$rservdir/$stamp.sh' ***"
rsync -avz $lservdir/../systemd/serve.sh $server:$rservdir/$stamp.sh
ssh $server "sudo /bin/chmod +x $rservdir/$stamp.sh"
