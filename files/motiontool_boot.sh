###
## motion.tool specific things
###

cd $APACHE_WORKDIR
sudo -u $WORKINGUSER composer global require "fxp/composer-asset-plugin:1.3.1"
sudo -u $WORKINGUSER composer install --prefer-dist
sudo -u $WORKINGUSER npm install
sudo -u $WORKINGUSER npm run build

if [ -s $APACHE_WORKDIR/config/config.json ]; then
    
    sudo -u $WORKINGUSER printf "
    set timeout -1
    spawn $APACHE_WORKDIR/yii migrate
    expect {
       \"Apply the above\" { send \"yes\\\n\"; }
    }
    expect eof
    " | expect

    if [ "$LATEX_ENABLE" == "yes" ]; then
      php /latex.php $APACHE_WORKDIR yes
    else
      php /latex.php $APACHE_WORKDIR no
    fi

else
    sudo -u $WORKINGUSER touch $APACHE_WORKDIR/config/INSTALLING
fi
