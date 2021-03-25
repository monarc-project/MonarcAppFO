version=$(cat ./VERSION.json)
version_affected='{"major":2, "minor":10, "hotfix":3}'
if [[ $version == "$version_affected" ]]; then
  $conf_file='./config/autoload/local.php'
  if [ -f "$conf_file" ]; then
    sed -i 's/https:\/\/objects.monarc.lu\/api\/v1\//https:\/\/objects.monarc.lu\/api\//g' "$conf_file"
    echo "Done for $conf_file"
  fi
fi
