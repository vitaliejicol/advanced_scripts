#!/bin/bash

name=$(date +%y-%m-%d.%H:%m)
echo $name

tar -cvf /backups/My_scripts.$name.tar /My_scripts/*