set -e

while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
            v="${1/--/}"
            declare $v="$2"
    fi

    shift
done


service=$(echo "$proj" | awk '{print tolower($0)}')

RELEASE_REMOTE_PATH=$rservdir/$service/releases/$stamp

echo "*** Building migrations for project: '$proj', context: '$dbc' on '$server' ***"
echo "***** Determine first pending migration for: '$service', context: '$dbc' *****"

first_pending=$(ssh $server "
    cd $RELEASE_REMOTE_PATH
    ASPNETCORE_ENVIRONMENT=$e ASPNETCORE_URLS=http://+:$port dotnet $proj.dll --pending-migrations --first $dbc
")

echo "      first migration: '$first_pending'"

if [[ $first_pending != '' ]]; then
    mkdir -p ./build/migrations

    echo "***** Creating migration script for context: '$dbc': '$first_pending' -> latest *****"
    cd ./src/$proj

    dotnet ef migrations script $first_pending \
        -c $dbc \
        -o ../../build/migrations/$dbc.sql
fi

echo "***** Done. *****"
