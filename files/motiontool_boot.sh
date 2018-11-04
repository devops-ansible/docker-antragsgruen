###
## motion.tool specific things
###

cd $APACHE_WORKDIR
sudo -u $WORKINGUSER composer global require "fxp/composer-asset-plugin:1.3.1"
sudo -u $WORKINGUSER composer install --prefer-dist
sudo -u $WORKINGUSER npm install
sudo -u $WORKINGUSER npm run build

if [ -f $APACHE_WORKDIR/config/config.json ]; then
    sudo -u $WORKINGUSER expect -c "spawn $APACHE_WORKDIR/yii migrate; expect -re \"Apply the above migrations?.*\"; send 'yes\r\n';"
else
    sudo -u $WORKINGUSER touch $WORKINGDIR/config/INSTALLING
fi
