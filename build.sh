set -e

PROJECTS=()
SERVICES=()

while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
            v="${1/--/}"
            declare $v="$2"

            if [[ $1 == *"--proj"* ]]; then
                PROJECTS+=($2)
            fi
    fi

    shift
done

for pair in "${PROJECTS[@]}"
do
    proj=($pair | cut -d ';' -f1)
    port=($pair | cut -d ';' -f2)

    service=$(echo "$proj" | awk '{print tolower($0)}')
    SERVICES+=($service)

    echo "*** Building dotnet project: '$proj' rev: '$b' ***"
    dotnet publish ./src/$proj \
        -c Release \
        /p:BuildNumber=$b \
        -o ../../build/services/$service

    echo "*** Generating systemd unit for '$service' ***"
    ./scripts/gservice.sh \
        --e $e \
        --s $service \
        --rservdir $rservdir \
        --dll $proj.dll \
        --user $user \
        --port $port \
        --env DOTNET_PRINT_TELEMETRY_MESSAGE=false \
        --o ./build/services/$service
done

args=${SERVICES[@]}
echo "*** Generate serve.sh ($args) *** "
./scripts/gserve.sh $args
