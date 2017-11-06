NAME
====

Config::Minimal - A minimal config manager

SYNOPSIS
========

    use Config::Minimal;

    my %config = Config::Minimal.load(program-name => "name of the program", default-config => "key = value\nkey1 = value");

DESCRIPTION
===========

Config::Minimal is a minimalistic config manager. It expect a program-name. This name is used to create a folder in ~/.config and create a file in it if not already exists. If default-config was set it is written to the newly created config file and for each load it checks if all settings found in default-config exists in the config file as well.

AUTHOR
======

wbiker <wbiker@gmx.at>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 wbiker

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
