set -e

find ./test/**/*.csproj | xargs -i dotnet test {} /p:CollectCoverage=true | grep '%' | awk '{ print $0 }{ sum += substr($4, 1, length($4)-1) } END { if (NR > 0) print "Total coverage: " sum / NR "%" }'
