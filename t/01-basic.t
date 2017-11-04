use v6.c;
use Test;
use Config::Minimal;

plan 7;

my $test-config = IO::Spec::Unix.catfile($*HOME, '.config', 'test', 'config');
$test-config.IO.unlink if $test-config.IO.e;

# Create file ~/.config/test/config
my %config = Config::Minimal.load(program-name => "test", do-not-prompt => True);
ok $test-config.IO.e, "test config exists";
is %config.keys.elems, 0, "empty config returned.";
$test-config.IO.unlink;

my %default-config = Config::Minimal.load(program-name => "test", default-config => "wolf=gang", do-not-prompt => True);
is %default-config<wolf>, "gang", "default config was used.";
$test-config.IO.unlink;

my %default-config-with-spaces = Config::Minimal.load(program-name => "test", default-config => "wolf = gang", do-not-prompt => True);
is %default-config-with-spaces<wolf>, "gang", "default config with spaces was found.";
$test-config.IO.unlink;

dies-ok { Config::Minimal.load() }, "Dies without program-name";
is $test-config.IO.e, False, "Test config not created if exception was thrown.";

dies-ok {Config::Minimal.load(program-name => "test", default-config => "wolf = dummy", do-not-prompt => True)}, "dies when expected setting has got dummy string as value.";
