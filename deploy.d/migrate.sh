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

echo "*** Migrate DB for project: '$proj', context: '$dbc' on '$server' ***"

ssh $server "
    cd $RELEASE_REMOTE_PATH
    ASPNETCORE_ENVIRONMENT=$e dotnet $proj.dll --migrate $dbc
"

echo "*** Migrated. ***"
