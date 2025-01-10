Version update guide for any Ubuntu version (for the release based installation).
=================================================================================
## The update guide is only applicable for the release based installation of the Monarc FrontOffice.
Means based on the installation steps described [here](https://github.com/monarc-project/MonarcAppFO/blob/master/INSTALL/INSTALL.ubuntu2204.md#2-installation-of-monarc).

## It is recommended to perform database or server backup / snapshot before starting the update process.

## The upgrade process is the following:

```bash
PATH_TO_MONARC='/var/lib/monarc/fo'
PATH_TO_MONARC_DATA='/var/lib/monarc/fo-data'
MONARC_VERSION=$(curl --silent -H 'Content-Type: application/json' https://api.github.com/repos/monarc-project/MonarcAppFO/releases/latest | jq  -r '.tag_name')
MONARCFO_RELEASE_URL="https://github.com/monarc-project/MonarcAppFO/releases/download/$MONARC_VERSION/MonarcAppFO-$MONARC_VERSION.tar.gz"

# Download a new release:
curl -sL $MONARCFO_RELEASE_URL -o /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL`
# Create the new release directory:
mkdir /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'`
# Unarchive the release:
tar -xzf /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL` -C /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'`
# Update the release symlink:
ln -sfn /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'` $PATH_TO_MONARC
# Migrate the DB:
cd $PATH_TO_MONARC; ./scripts/upgrade-db.sh
# Cleanup the cache directories:
rm -rf $PATH_TO_MONARC_DATA/data/cache/* $PATH_TO_MONARC_DATA/data/DoctrineORMModule/Proxy/* $PATH_TO_MONARC_DATA/data/LazyServices/Proxy/*

# Finally restart the apache service:
sudo service apache reload
```
