set -e

PROJECTS=()

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

for proj in "${PROJECTS[@]}"
do

  service=$(echo "$proj" | awk '{print tolower($0)}')

  echo "*** Finish service '$service' ***"

  release_dir=$rservdir/$service/releases/$stamp
  current_dir=$rservdir/$service/current
  systemd_unit_path=/etc/systemd/system/$service.service

  echo "**** Ln '$release_dir' -> '$current_dir' ****"
  ssh $server "
      rm -f $current_dir
      ln -sf $release_dir $current_dir

      sudo rm -f $systemd_unit_path
      sudo ln -sf $current_dir/$service.service $systemd_unit_path
    "

done

echo "*** Done. ***"
