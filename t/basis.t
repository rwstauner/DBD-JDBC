# -*-perl-*-
#
# If DBDJDBC_URL is a BASIS url, try to connect to BASIS and read
# some data. Otherwise, skip this test.


# This test will attempt to read some data from
# <tour.all>client. If you don't have the tour database
# installed, this test will fail. When you set the DBDJDBC_URL
# environment varible, include tour_all in the database list. For
# example,
#    jdbc:opentext:basis://host:port/tour_all?host.user=u&host.password=p
# where host, port, u, and p must be replaced with the location
# of your OPIRPC service and a valid host username and password.
# If you do not wish to connect using the BASIS user user1, you
# should also set the DBDJDBC_USER and DBDJDBC_PASSWORD
# environment variables.

unless ($ENV{DBDJDBC_URL} and $ENV{DBDJDBC_URL} =~ /^jdbc:opentext:basis/) {
    print "1..0\n";
    exit 0;
}


require "t/lib.pl";
use DBI;

$| = 1;

print "1..$tests\n";

my $defaults = get_defaults();

if ($ENV{DBDJDBC_URL} =~ /tour_all/i) {
    print "ok 1\n";
} else {
    warn "The URL must include 'tour_all' in the database list\n";
    print "not ok 1\n";
}


my $pid = start_server($defaults->{driver}, $defaults->{port});
if ($pid) {
    print "ok 2\n";
} else {
    warn "Failed to start server; aborting\n";
    print "not ok 2\n";
    exit 0;
}

# Give the server time to attach to the socket before trying to connect.
sleep(3); 


$ENV{DBDJDBC_URL} =~ s/([=;])/uc sprintf("%%%02x",ord($1))/eg;
my $dsn = "dbi:JDBC:hostname=localhost;port=" . $defaults->{port}
        . ";url=$ENV{DBDJDBC_URL}";
my $dbh;

if (!($dbh = DBI->connect($dsn, $defaults->{user}, $defaults->{password},
                       {AutoCommit => 1, PrintError => 0, }))) {
    warn "Connection error: $DBI::errstr\n";
    warn "Make sure your CLASSPATH includes the BASIS JDBC driver.\n"
        if ($DBI::errstr =~ /No suitable driver/);
    warn "Check the host and port values in your URL and ensure that "
        . "OPIRPC is running at that location.\n"
            if ($DBI::errstr =~ /Server communications error/);            
    print "not ok 3\n";
    exit 0;
};
print "ok 3\n";

my $sth = $dbh->prepare("select id, cname from client order by id"); 
if ($sth) {
    print "ok 4\n";
} else {
    warn "$DBI::errstr\n";
    warn "The <TOUR.ALL> database model must be available in order to "
        . "complete this test\n"
        if ($DBI::errstr =~ /database model does not exist/); 
    print "not ok 4\n";
    exit 0;
}

if ($sth->execute()) {
    print "ok 5\n";
} else {
    warn "$DBI::errstr\n";
    print "not ok 5\n";
}

my $row;
if ($row = $sth->fetch()) {
    print "ok 6\n";
} else {
    if ($DBI::errstr) {
        warn "$DBI::errstr\n";
        print "not ok 6\n";
    } else {
        warn "No data found in <tour.all>client table; next test will fail\n";
        print "ok 6\n";
    }
}

if ($row) {
    if ($row->[1] =~ /\w+, \w+/) {
        print "ok 7\n";
    } else {
        warn "Unexpected data in <tour.all>client; expected Last, First; got '"
            . $row->[1] . "'\n";
        print "not ok 7\n";
    }
} else {
    print "not ok 7\n";
}

if ($sth->finish()) {
    print "ok 8\n";
} else {
    print "not ok 8\n";
}


if ($dbh->disconnect()) {
    print "ok 9\n";
} else {
    print "not ok 9\n";
}

exit 0;

BEGIN { $tests = 9 }

END { 
    if (defined $pid) {
        stop_server($pid);
    }
}
