# Try to start the server, connect, and disconnect.  -*-perl-*-


require "t/lib.pl";

my $defaults = get_defaults();

unless ($defaults && $defaults->{driver}) {
    warn "No driver name found; check your environment variables\n";
    print "1..0\n";
    exit(0);
}


use DBI;

$| = 1;

print "1..$tests\n";

print "\n#Attempting to test server with the following values: \n",
    "#\tJava: ", $ENV{DBDJDBC_JAVA_BIN} || "java", "\n",
    "#\tClasspath: $ENV{CLASSPATH}\n", 
    "#\tJDBC url: $ENV{DBDJDBC_URL}\n",
    "#\tDriver name: ", $defaults->{driver}, "\n",
    "#\tUser name: ",  $defaults->{user}, "\n",
    "#\tPassword: ",  $defaults->{password}, "\n",
    "#\tServer port: ",  $defaults->{port}, "\n";


my $pid = start_server($defaults->{driver}, $defaults->{port});
if ($pid) {
    print "ok 1\n";
} else {
    warn "Failed to start server; aborting\n";
    print "not ok 1\n";
    exit 0;
}

# Give the server time to start listening to the socket before
# trying to connect.
sleep(3); 

$ENV{DBDJDBC_URL} =~ s/([=;])/uc sprintf("%%%02x",ord($1))/eg;
my $dsn = "dbi:JDBC:hostname=localhost;port=" . $defaults->{port} . 
    ";url=$ENV{DBDJDBC_URL}";
my $dbh;
if ($dbh = DBI->connect($dsn, $defaults->{user}, $defaults->{password},
                    {AutoCommit => 1, PrintError => 0, })) {
    print "ok 2\n";
}
else {
    warn "Connection error: $DBI::errstr\n";
    warn "Make sure your CLASSPATH includes your JDBC driver.\n"
        if ($DBI::errstr =~ /No suitable driver/);
    print "not ok 2\n";
}


if ($dbh && $dbh->disconnect()) {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}


if (stop_server($pid)) {
    print "ok 4\n";
    $pid = undef;
} else {
    warn "Server may not have been stopped\n";
    print "not ok 4\n";
}

exit 0;

BEGIN { $tests = 4 }

# Catch unexpected errors and kill the server anyway.
END { if ($pid) { stop_server($pid); } }
