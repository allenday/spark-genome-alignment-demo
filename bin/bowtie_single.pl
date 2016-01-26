#!/usr/bin/perl
use strict;
use File::Temp qw(tempfile);
use JSON qw(decode_json);

die '$DEMO not defined' unless -d $ENV{'DEMO'};

my $template = "@%s/%d\n%s\n+%s/%d\n%s\n";

my ($fh1, $fq1) = tempfile( "fqsplit_XXXXX", SUFFIX => '.fq', UNLINK => 1, DIR => "/tmp" );

my $count = 0;
while (my $line = <>){
  chomp $line;
  $line =~ s/^\(/[/;
  $line =~ s/\)$/]/;
  my $pair = decode_json( $line );

  my $read1 = sprintf( $template,
    $pair->[0]->{'readName'},
    1,
    $pair->[0]->{'sequence'},
    $pair->[0]->{'readName'},
    1,
    $pair->[0]->{'qual'},
  );
}

close( $fh1 );

open( SAM, $ENV{'DEMO'}."/build/bowtie/bowtie ".$ENV{'DEMO'}."/build/data/NC_008253 $fq1 |" );
while ( my $line = <SAM> ) {
  warn $line;
  print $line;
}

close( SAM );
