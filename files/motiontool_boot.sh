###
## motion.tool specific things
###

cd $APACHE_WORKDIR
sudo -u $WORKINGUSER composer global require fxp/composer-asset-plugin hirak/prestissimo
sudo -u $WORKINGUSER composer install --prefer-dist
sudo -u $WORKINGUSER npm install
sudo -u $WORKINGUSER npm run build

if [ -s $APACHE_WORKDIR/config/config.json ]; then
    
    sudo -u $WORKINGUSER expect -c "spawn $APACHE_WORKDIR/yii migrate; expect -re \"Apply the above migrations?.*\"; send 'yes\r\n';"

    if [ "$LATEX_ENABLE" == "yes" ]; then
      php /latex.php $APACHE_WORKDIR yes
    else
      php /latex.php $APACHE_WORKDIR no
    fi

else
    sudo -u $WORKINGUSER touch $APACHE_WORKDIR/config/INSTALLING
fi
