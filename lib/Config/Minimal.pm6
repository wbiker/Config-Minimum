use v6.c;
unit class Config::Minimal:ver<0.0.2>;

=begin pod

=head1 NAME

Config::Minimal - A minimal config manager

=head1 SYNOPSIS

  use Config::Minimal;

  my %config = Config::Minimal.load(program-name => "name of the program", default-config => "key = value\nkey1 = value");

=head1 DESCRIPTION

Config::Minimal is a minimalistic config manager.
It expect a program-name. This name is used to create a folder in  ~/.config and create a file in it if not already exists.
If default-config was set it is written to the newly created config file and for each load it checks if all settings found
in default-config exists in the config file as well.

=head1 AUTHOR

wbiker <wbiker@gmx.at>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 wbiker

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

my regex KEY_VALUE_REGEX { $<key>=<-[=\s]>+ \s? '=' \s? $<value>=.* }

method load(:$program-name, :$default-config = "", :$do-not-prompt = False) {
    unless $program-name {
        die "program-name must be set.";
    }
    my $config-dir = $*SPEC.catdir($*HOME, '.config');
    $config-dir.IO.mkdir unless $config-dir.IO.e;

    my $config-program-dir = $*SPEC.catdir($config-dir, $program-name);
    $config-program-dir.IO.mkdir unless $config-program-dir.IO.e;

    my $config-program-file = $*SPEC.catfile($config-program-dir, 'config').IO;
    if not $config-program-file.e {
        # does not exist.
        $config-program-file.spurt($default-config);

        unless $do-not-prompt {
            my $answer = prompt "Create new config file '$config-program-file'. Do you want to change this? (y|N) ";
            if $answer ~~ /:i 'y'/ {
                shell "\$EDITOR $config-program-file";
            }
        }
    }

    my %config;
    for $config-program-file.lines -> $line {
        next if $line ~~ /^^ '#'/;
        next if $line ~~ /^$/;

        if $line ~~ /<KEY_VALUE_REGEX>/ {
            my $key = ~$<KEY_VALUE_REGEX><key>;
            my $value = ~$<KEY_VALUE_REGEX><value>;
            if %config{$key}:exists {
                my $tmp = %config{$key};
                if $tmp ~~ Array {
                    $tmp.push: $value;
                    %config{$key} = $tmp;
                }
                else {
                    my @new = ($tmp, $value);
                    %config{$key} = @new;
                }
            }
            else {
                %config{$key} = $value;
            }
        }
        else {
            die "Config $config-program-file file error: $line not recognized";
        }
    }

    check-config(config => %config, settings-to-check => get-settings($default-config), config-file => $config-program-file);

    return %config;
}

sub get-settings($default-config) {
    return [] unless $default-config;

    my @default-settings;
    for $default-config.split('\n') -> $line {
        if $line ~~ /<KEY_VALUE_REGEX>/ {
            @default-settings.push(~$<KEY_VALUE_REGEX><key>);
        }
    }

    return @default-settings;
}

sub check-config(:%config, :$config-file, :@settings-to-check = [] ) {
    return unless @settings-to-check;

    for @settings-to-check -> $key {
        unless %config{$key}:exists {
            die "Config setting '$key' not found in config file $config-file";
        }

        unless %config{$key} !~~ /dummy/ {
            die "Config setting '$key' not set in config file $config-file";
        }
    }
}
