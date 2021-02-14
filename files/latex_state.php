#!/usr/bin/env php

<?php

$toolpath = $argv[1];
$latex    = ( strtolower($argv[2]) == 'yes' or strtolower($argv[2]) == 'y');

$configfile = $toolpath . DIRECTORY_SEPARATOR . 'config/config.json';

$config = json_decode (file_get_contents($configfile), true);

if ($latex) {
    $config["xelatexPath"]  = '/usr/bin/xelatex';
    $config["xdvipdfmx"]    = '/usr/bin/xdvipdfmx';
    $config["pdfunitePath"] = '/usr/bin/pdfunite';
}
else {
    if (isset($config["xelatexPath"])) {
        unset($config["xelatexPath"]);
    }
    if (isset($config["xdvipdfmx"])) {
        unset($config["xdvipdfmx"]);
    }
    if (isset($config["pdfunitePath"])) {
        unset($config["pdfunitePath"]);
    }
}

file_put_contents ($configfile, json_encode($config, JSON_PRETTY_PRINT));
