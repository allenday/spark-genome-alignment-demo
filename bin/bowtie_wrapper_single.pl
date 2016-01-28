#!/usr/bin/perl
use strict;
use Data::Dumper qw(Dumper);
use File::Temp qw(tempfile);
use JSON qw(decode_json);

die '$DEMO not defined' unless -d $ENV{'DEMO'};

my $template = "@%s\n%s\n+%s\n%s\n";

my ($fh1, $fq1) = tempfile( "fqsplit_XXXXX", SUFFIX => '.fq', UNLINK => 1, DIR => "/tmp" );

my $count = 0;
while (my $line = <>){
  chomp $line;
  $line =~ s/^\(/[/;
  $line =~ s/\)$/]/;
  my $pair = decode_json( $line );
  #warn Dumper($pair);
  my $read1 = sprintf( $template,
    $pair->{'readName'},
    $pair->{'sequence'},
    $pair->{'readName'},
    $pair->{'qual'},
  );

  print $fh1 $read1;
}

close( $fh1 );

open( SAM, $ENV{'DEMO'}."/build/bowtie/bowtie -S ".$ENV{'DEMO'}."/build/data/NC_008253 $fq1 |" );
while ( my $line = <SAM> ) {
  warn $line;
  print $line;
}

close( SAM );
