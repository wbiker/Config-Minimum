use v6.c;
unit class Config::Minimal:ver<0.0.1>;

=begin pod

=head1 NAME

Config::Minimal - A minimal config manager

=head1 SYNOPSIS

  use Config::Minimal;

=head1 DESCRIPTION

Config::Minimal is ...

=head1 AUTHOR

wbiker <wbiker@gmx.at>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 wbiker

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

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

        if $line ~~ /$<key>=<-[=\s]>+ \s? '=' \s? $<value>=.*/ {
            my $key = ~$<key>;
            my $value = ~$<value>;
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

    %config;
}
