# spark-genome-alignment-demo
An example of bioinformatics and bigdata tools nicely playing together.

You can copy and paste the relevant section below (currently Mac OS X only)
to see how the Bowtie aligner can be integrated into an interactive Spark
program for doing bioinformatics work in a BigData environment.

Specifically what is being done below:

1. Build and install prerequisites
  * Java 1.6+
  * Apache Maven
  * perl JSON (`sudo cpan JSON`)
  * package manager (as needed)
  * [Apache Spark](http://spark.apache.org/)
  * [Scala](http://www.scala-lang.org/)
  * [Bowtie](http://bowtie-bio.sourceforge.net/index.shtml)
  * [Big Data Genomics](http://bdgenomics.org/) [ADAM](https://github.com/bigdatagenomics/adam)
2. Index the E.coli genome ([NC_008253](http://www.ncbi.nlm.nih.gov/nuccore/110640213?report=fasta)) that ships with Bowtie
3. Generate a set of positive-control [FastQ](https://en.wikipedia.org/wiki/FASTQ_format) reads from NC_008253
4. Launch spark-shell, the interactive interface to Spark
5. Align the control reads with Bowtie from spark-shell
6. Write the aligned reads out in [SAM](https://samtools.github.io/hts-specs/SAMv1.pdf) format

## Set up the environment

### Mac OS X

If you haven't already, install [Homebrew](http://brew.sh/):

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

    #save time on mac, just use the pre-built bowtie from homebrew
    brew install homebrew/science/bowtie
    bowtie-build data/NC_008253.fna $DEMO/build/data/NC_008253
    cat $DEMO/data/NC_008253.fna | sort | tail -50 | perl -ne 'chomp;$q=$_;$q=~s/./B/g;printf qq(\@read%i\n%s\n+\n%s\n), ($., $_, $q)' > $DEMO/build/data/reads.fq

    #or do it from source...
    #git clone https://github.com/BenLangmead/bowtie.git
    #cd $DEMO/build/bowtie
    #make
    #./bowtie-build genomes/NC_008253.fna $DEMO/build/data/NC_008253
    #cat $DEMO/data/NC_008253.fna | sort | tail -50 | perl -ne 'chomp;$q=$_;$q=~s/./B/g;printf qq(\@read%i\n%s\n+\n%s\n), ($., $_, $q)' > $DEMO/build/data/reads.fq

    #verify bowtie functions as expected
    cat $DEMO/build/data/reads.fq | bowtie $DEMO/build/data/NC_008253 - | md5sum
    #should yield ecd5e41dea9692446fa4ae4170d6a1e1
    cd $DEMO/build
    git clone https://github.com/bigdatagenomics/adam.git
    export SPARK_HOME=/usr/local/Cellar/apache-spark/1.4.1
    cd $DEMO/build/adam
    mvn package install
    export ADAM_HOME=`pwd`

## Run the demo

    cat $DEMO/bin/bowtie_pipe_single.scala | $ADAM_HOME/bin/adam-shell
    reset
    cat $DEMO/build/data/reads.sam | md5sum
    #should yield 6eebbde8d7818136e9ab924d57af8005

    #examine the outputs
    head $DEMO/build/data/reads.sam

## Further reading

Have a look at [bowtie_pipe_single.scala](https://github.com/allenday/spark-genome-alignment-demo/blob/master/bin/bowtie_pipe_single.scala)
if you're curious about how the integration is done.  We're making use of the Spark Resilient Distributed Dataset ([RDD](http://www.thecloudavenue.com/2014/01/resilient-distributed-datasets-rdd.html)) [pipe()](https://spark.apache.org/docs/1.6.0/api/java/org/apache/spark/rdd/RDD.html#pipe(scala.collection.Seq,%20scala.collection.Map,%20scala.Function1,%20scala.Function2,%20boolean)) function to send data out to a subprocess that runs Bowtie, feeds it some data, and collects the results.

You can see another example from [Holden Karau](https://github.com/holdenk) of using the RDD pipe() function [here](https://github.com/databricks/learning-spark/blob/master/src/main/scala/com/oreilly/learningsparkexamples/scala/PipeExample.scala).  It's from the book [Learning Spark](http://shop.oreilly.com/product/0636920028512.do).



