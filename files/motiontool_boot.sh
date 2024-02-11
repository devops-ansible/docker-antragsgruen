###
## motion.tool specific things
###

cd "${APACHE_WORKDIR}"

chown -R "${WORKINGUSER}" "${APACHE_WORKDIR}"

# only run `composer install` if `vendor` not present
if [ ! -d "./vendor" ]; then
    sudo -u "${WORKINGUSER}" composer install --prefer-dist
fi

# only run `npm` stuff if `node_modules` are not present
if [ ! -d "./node_modules" ]; then
    sudo -u "${WORKINGUSER}" npm install
    sudo -u "${WORKINGUSER}" npm run build
    # sudo -u "${WORKINGUSER}" gulp
fi

if [ -s "${APACHE_WORKDIR}/config/config.json" ]; then
    
    sudo -u "${WORKINGUSER}" "${APACHE_WORKDIR}/yii" cache/flush-all
    sudo -u "${WORKINGUSER}" printf "
    set timeout -1
    spawn \"${APACHE_WORKDIR}/yii\" migrate
    expect {
       \"Apply the above\" { send \"yes\\\n\"; }
    }
    expect eof
    " | expect

    if [ "${LATEX_ENABLE}" == "yes" ]; then
      php /latex.php "${APACHE_WORKDIR}" yes
    else
      php /latex.php "${APACHE_WORKDIR}" no
    fi

else
    sudo -u "${WORKINGUSER}" touch "${APACHE_WORKDIR}/config/INSTALLING"
fi

chown -R "${WORKINGUSER}" "${APACHE_WORKDIR}"
