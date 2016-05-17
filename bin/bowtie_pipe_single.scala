import htsjdk.samtools.SAMLineParser
import org.apache.commons.io.IOUtils
import org.apache.spark._
import org.bdgenomics.adam.rdd.ADAMContext
import org.bdgenomics.adam.rdd.ADAMContext._
import org.bdgenomics.adam.converters.SAMRecordConverter
import org.seqdoop.hadoop_bam.util.SAMHeaderReader
import org.bdgenomics.adam.models.RecordGroupDictionary
import org.bdgenomics.adam.models.SequenceDictionary

val ac = new org.bdgenomics.adam.rdd.ADAMContext(sc)

val reads = ac.loadAlignments(sys.env("DEMO")+"/build/data/reads.fq").rdd
val relative_script = "bowtie_wrapper_single.pl"
val absolute_script = sys.env("DEMO")+"/bin/" + relative_script
val piped_reads = reads.pipe(absolute_script)

val samHeaderString = piped_reads.filter( x => x.startsWith("@") ).collect.mkString("\n")
val samHeader = SAMHeaderReader.readSAMHeaderFrom( IOUtils.toInputStream(samHeaderString, "UTF-8"), sc.hadoopConfiguration )
val samLineParser = new SAMLineParser(samHeader)
val samLineStrings = piped_reads.filter( x => ! x.startsWith("@") )
val sd = SequenceDictionary(samHeader)
val rg = RecordGroupDictionary.fromSAMHeader(samHeader)
val samRecordConverter = new SAMRecordConverter

val samRecords = samLineStrings.map( x => x.split("\t") ).map( x => { 
    val y = new htsjdk.samtools.SAMRecord(samHeader)
    y.setReadName(x(0))
    y.setFlags(x(1).toInt)
    y.setReferenceName(x(2))
    y.setAlignmentStart(x(3).toInt)
    y.setMappingQuality(x(4).toInt)
    y.setCigarString(x(5))
    //no mate, x(6)
    //no mate, x(7)
    //no mate, x(8)
    y.setInferredInsertSize(x(8).toInt)
    y.setReadString(x(9)) 
    y.setBaseQualityString(x(10)) 
    //TODO process tags/attributes in x(11) and beyond

    y.setHeader(samHeader)

    y 
} )

val alignmentRecords = samRecords.map(x=>samRecordConverter.convert(x,sd,rg))
alignmentRecords.saveAsSam(sys.env("DEMO")+"/build/data/reads.sam",sd,rg,asSam=true,asSingleFile=true)
