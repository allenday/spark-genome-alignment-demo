#!/usr/bin/perl
use strict;
use File::Temp qw(tempfile);
use JSON qw(decode_json);

my $template = "@%s/%d\n%s\n+%s/%d\n%s\n";

my ($fh1, $fq1) = tempfile( "fqsplit_XXXXX", SUFFIX => '_1.fq', UNLINK => 1, DIR => "/mapr/ADPPOC/tmp" );
my ($fh2, $fq2) = tempfile( "fqsplit_XXXXX", SUFFIX => '_2.fq', UNLINK => 1, DIR => "/mapr/ADPPOC/tmp" );

#warn $fq1;
#warn $fq2;

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

  my $read2 = sprintf( $template,
    $pair->[1]->{'readName'},
    2,
    $pair->[1]->{'sequence'},
    $pair->[1]->{'readName'},
    2,
    $pair->[1]->{'qual'},
  );

  print $fh1 $read1;
  print $fh2 $read2;
}

close( $fh1 );
close( $fh2 );

open( SAM, "/mapr/ADPPOC/user/aday/src/bowtie-1.1.2/bowtie -p 16 /mapr/ADPPOC/user/aday/data/bms/hg19ERCC/bowtie_index/hg19ERCC -1 $fq1 -2 $fq2 |" );
while ( my $line = <SAM> ) {
  warn $line;
  print $line;
}

close( SAM );
