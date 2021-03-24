version=$(cat ./VERSION.json)
version_affected='{"major":2, "minor":10, "hotfix":3}'
if [[ $version == "$version_affected" ]]; then
  for conf_file in /var/www/*/local.php
  do
    if [ -f "$conf_file" ]; then
      sed -i 's/https:\/\/objects.monarc.lu\/api\/v1\//https:\/\/objects.monarc.lu\/api\//g' "$conf_file"
      echo "Done for $conf_file."
    else
      sed -i 's/https:\/\/objects.monarc.lu\/api\/v1\//https:\/\/objects.monarc.lu\/api\//g' "./config/autoload/local.php"
      echo "Done for ./config/autoload/local.php"
    fi
  done
fi
