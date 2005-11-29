# -*-perl-*-
#
# In all cases test with hsqldb. 


require "t/lib.pl";
use DBI;
use Test::More;
$| = 1;

BEGIN {
    plan tests => 8;
}

$ENV{DBDJDBC_URL} = "jdbc:hsqldb:file:t/hsqldb/testdb";
my $pid;
SKIP: {
    my $defaults = get_defaults();
    my $fatal = 0; 
    $pid = start_server($defaults->{driver}, $defaults->{port});
    ok($pid, "server started") or $fatal++;
    skip "Server failed to start; remaining tests will fail", 7 if $fatal;
    # Give the server time to attach to the socket before trying to connect.
    sleep(3); 

    $ENV{DBDJDBC_URL} =~ s/([=;])/uc sprintf("%%%02x",ord($1))/eg;
    my $dsn = "dbi:JDBC:hostname=localhost;port=" . $defaults->{port}
        . ";url=$ENV{DBDJDBC_URL}";
    my $dbh = DBI->connect($dsn, $defaults->{user}, $defaults->{password},
                           {AutoCommit => 1, PrintError => 0, }); 
    ok($dbh, "connected") or do {
        diag("Connection error: $DBI::errstr\n");
        $fatal++;
    };
    skip "Connection failed", 6 if $fatal;

    my $sth = $dbh->prepare("select id, value from testtable order by id"); 
    ok ($sth, "prepare") or do {
        diag("Connection error: $DBI::errstr\n");
        $fatal++;
    };
    skip "Prepare failed", 5 if $fatal;

    ok ($sth->execute(), "execute") or do {
        diag $sth->errstr;
        $fatal++; 
    }; 
    skip "Execute failed", 4 if $fatal;

    my $row = $sth->fetch(); 
    ok ($row, "fetch") or do {
        diag $sth->errstr;
        $fatal++; 
    }; 
    skip "No data in row", 3 if $fatal; 

    like($row->[1], qr/value/i, "read data");

    ok($sth->finish(), "finish");

    $dbh->do("shutdown") or warn $dbh->errstr;

    ok($dbh->disconnect(), "disconnect");
};

exit 1;

END { 
    if (defined $pid) {
        stop_server($pid);
    }
}
