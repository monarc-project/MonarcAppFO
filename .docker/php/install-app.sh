
if [ ! -d "../../module" ]; then
  mkdir -p ../../module/Monarc
  cd ../../module/Monarc
  ln -sfn ./../../../../vendor/monarc/core Core
  ln -sfn ./../../../../vendor/monarc/frontoffice FrontOffice
  cd .
fi

if [ ! -d "../../node_modules" ]; then
  mkdir -p ../../node_modules
  cd ../../node_modules
  git clone --config core.fileMode=false https://github.com/monarc-project/ng-client.git ng_client
  git clone --config core.fileMode=false https://github.com/monarc-project/ng-anr.git ng_anr
  cd ng_client
  npm ci
  cd .
fi

if [ ! -f "../../config/autoload/local.php" ]; then
  cp ./local.php ../../config/autoload/
fi
