# spark-genome-alignment-demo
An example of bioinformatics and bigdata tools can playing nicely together

## Requirements

Specific commands will be given below to do these.

0. Install Homebrew (Mac OS X only)
1. Install Spark
2. Download and get ADAM working
3. Download and compile Bowtie.
4. Download the E.coli genome
5. Index the E.coli genome with Bowtie

## Installation

### Mac OS X

If you haven't already, install Homebrew (http://brew.sh/):

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Now we're ready to get to work:

    brew install apache-spark
    brew install scala
    git clone https://github.com/allenday/spark-genome-alignment-demo.git
    cd spark-genome-alignment-demo
    #we'll assume that wherever you are now is where you want to work
    export DEMO=`pwd`
    mkdir -p build/data
    cd $DEMO/build
    git clone https://github.com/BenLangmead/bowtie.git
    cd $DEMO/build/bowtie
    make
    ./bowtie-build genomes/NC_008253.fna $DEMO/build/data/NC_008253
    cat genomes/NC_008253.fna | sort | tail -50 | perl -ne 'chomp;$q=$_;$q=~s/./B/g;printf qq(\@read%i\n%s\n+\n%s\n), ($., $_, $q)' > $DEMO/build/data/reads.fq
    #verify bowtie functions as expected
    cat $DEMO/build/data/reads.fq | ./bowtie $DEMO/build/data/NC_008253 - | md5sum
    #should yield ecd5e41dea9692446fa4ae4170d6a1e1
    cd $DEMO/build
    git clone https://github.com/bigdatagenomics/adam.git
    export SPARK_HOME=/usr/local/Cellar/apache-spark/1.4.1
    cd $DEMO/build/adam
    mvn package install
    export ADAM_HOME=`pwd`

## How to run the demo.

    cat $DEMO/bin/bowtie_pipe_single.scala | $ADAM_HOME/bin/adam-shell
    cat $DEMO/build/data/reads.sam | md5sum
    #should yield 6eebbde8d7818136e9ab924d57af8005

    #examine the outputs
    head $DEMO/build/data/reads.sam

