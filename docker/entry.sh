#!/bin/sh

# run b2 authorize then commands from user
b2 authorize-account $KEY_ID $APPLICATION_KEY &&
    b2 $@
