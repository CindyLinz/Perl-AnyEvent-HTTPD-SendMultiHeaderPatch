use strict;
use warnings;

use Test::More tests => 2;
use AnyEvent::Impl::Perl;
use AE;
use AnyEvent::HTTPD;
use AnyEvent::HTTPD::SendMultiHeaderPatch;
use AnyEvent::HTTPD::Util;

my $h = AnyEvent::HTTPD->new (port => 19090);

$h->reg_cb (
   '/header-multi' => sub {
      my ($httpd, $req) = @_;
      my %header;
      header_add(\%header, 'Test', 'a');
      header_add(\%header, 'Test', 'b');
      $req->respond (
         [200, 'OK', \%header, "Test response"]);
   },
);

my $c1 = AnyEvent::HTTPD::Util::test_connect ('127.0.0.1', $h->port,
    "GET\040/header-multi\040HTTP/1.0\015\012\015\012");
my $r1 = $c1->recv;

like($r1, qr/^Test: a\r\n/m, "Has Test: a");
like($r1, qr/^Test: b\r\n/m, "Has Test: b");
