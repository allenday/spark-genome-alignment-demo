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

## Installation script

### Mac OS X

If you haven't already, install Homebrew (http://brew.sh/):

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Now we're ready to get to work:

    brew install apache-spark
    brew install scala
    git clone https://github.com/allenday/spark-genome-alignment-demo.git
    cd spark-genome-alignment-demo
    mkdir -p build/data
    cd build
    git clone https://github.com/BenLangmead/bowtie.git
    cd bowtie
    make
    ./bowtie-build genomes/NC_008253.fna ../data/NC_008253
    cat genomes/NC_008253.fna | sort | tail -50 | perl -ne 'chomp;$q=$_;$q=~s/./B/g;printf qq(\@read%i\n%s\n+\n%s\n), ($., $_, $q)' > ../data/reads.fq
    #verify bowtie functions as expected
    cat ../data/reads.fq | ./bowtie ../data/NC_008253 - | md5sum
    #should yield ecd5e41dea9692446fa4ae4170d6a1e1
    cd ..
    git clone https://github.com/bigdatagenomics/adam.git
    export SPARK_HOME=/usr/local/Cellar/apache-spark/1.4.1
    cd adam
    mvn package install


## How to run the demo.
