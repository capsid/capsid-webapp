/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the GNU Public License v3.0.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package ca.on.oicr.capsid

import org.bson.types.ObjectId

/**
 * Service to handle mapped read data access.
 */
class MappedService {

    /**
     * Don't use transactions.
     */
    static transactional = false

    /**
     * Dependency injection for the AuthService.
     */
    def authService

    /**
     * Dependency injection for the ProjectService.
     */
    def projectService

    /**
     * Dependency injection for the SequenceService.
     */
    def sequenceService

    /**
     * Finds a requested mapped read
     *
     * @param id the read identifier.
     * @return the mapped read.
     */
    MappedRead get(String id) {
        return (MappedRead) Mapped.collection.findOne('_id': new ObjectId(id))
    }

    /**
     * Finds other hits against a mapped read
     *
     * @param mappedInstance the mapped read.
     * @return the list of mapped read records.
     */
    ArrayList otherHits(MappedRead mappedInstance) {
        return Mapped.collection.find(
          "readId": mappedInstance['readId']
          , "_id": [$ne: mappedInstance['_id']]
        )
        .collect {
          [
            id: it["_id"].toString()
            , gi: it["genome"]
            , refStart: it["refStart"]
            , refEnd: it["refEnd"]
          ]
        }
    }

  /**
   * Reads the split alignment for a mapped read.
   *
   * @param mappedInstance the mapped read.
   * @return a defining the split alignment.
   */
  Map getSplitAlignment(MappedRead mappedInstance) {

    Map formatted = [
      query: [ seq: [], pos: [] ],
      ref: [ seq: [], pos: [] ],
      markup: []
    ]

    String cigar = sequenceService.tupleToCIGAR(mappedInstance['cigar'])
    String md = mappedInstance['MD']

    if (! md) {
      return formatted
    }
    Map results = sequenceService.calculateAlignment(mappedInstance['sequence'], md, cigar)

    formatted.query.seq = bucket(results['sequence'])
    formatted.ref.seq = bucket(results['reference'])
    formatted.markup = bucket(results['markup'])

    for (i in 0..<formatted.query.seq.size()) {
      int qc = formatted.query.seq[i].findAll {it ==~ /\w/}.size()
      int rc = formatted.ref.seq[i].findAll {it ==~ /\w/}.size()
      formatted.query.pos[i] = i==0?qc:rc+formatted.query.pos[i-1]
      formatted.ref.pos[i] = i==0?rc:rc+formatted.ref.pos[i-1]
    }

    formatted
  }

  /**
   * Turns a sequence string into a set of buckets, splitting by semicolons.
   *
   * @param a sequence string.
   * @return a list of buckets.
   */
  List bucket(String string) {
    string.replaceAll(/.{80}/){all -> all + ';'}.split(';')
  }

  /**
   * Build overlapping read information for a mapped read.
   *
   * @param mappedInstance the mapped read.
   * @return a list of reads.
   */
  ArrayList getOverlappingReads(MappedRead mappedInstance) {
    ArrayList reads = []
    int start = mappedInstance['refStart']
    int end = mappedInstance['refEnd']

    def cursor = Mapped.collection.find(genome: mappedInstance['genome'] as int, alignmentId: mappedInstance['alignmentId'], refStrand: mappedInstance['refStrand'], refStart: [$lte: end], refEnd: [$gte: start])
    List<Map> results = cursor.collect { f ->
      [refStart: f['refStart'],
       refEnd: f['refEnd'],
       sequence: f['sequence']]
    }

    while (true) {
      reads = results.findAll {it.refStart < end && it.refEnd > start }

      if (start == reads.refStart.min() && end == reads.refEnd.max() ) {
        break
      }

      start = reads.refStart.min()
      end = reads.refEnd.max()
    }

    reads.sort{it.refStart}
  }

  /**
   * Build config information for a set of reads.
   *
   * @param reads a list of reads
   * @param mappedInstance the mapped read.
   * @return a list of contig info records.
   */
  List getContig(ArrayList reads, MappedRead mappedInstance) {

    Map seq_array = [:]

    reads.each { read ->
      int pos = read.refStart
      read.sequence.each { base ->
        if (seq_array[pos] != 'N') {
          if (seq_array.containsKey(pos) && seq_array[pos] != base) {
            seq_array[pos] = 'N'
          } else {
            seq_array[pos] = base
          }
        }
        pos++
      }
    }

    seq_array[mappedInstance['refStart']] = '<b>' + seq_array[mappedInstance['refStart']]
    seq_array[mappedInstance['refEnd']] = seq_array[mappedInstance['refEnd']] + '</b>'

    seq_array.collect { it.value }
  }

  /**
   * Calculate and build a histogram for the gene data across the region.
   *
   * @param genome the specified genome
   * @param start start position within the genome.
   * @param end end position within the genome.
   * @param interval interval size.
   * @return a list of histogram buckets.
   */
  def getHistogramRegion(Genome genome, Sample sample, Integer start, Integer end, Integer interval) {

    Integer histogramCount = Math.ceil((end - start) / interval).toInteger()

    Integer[] data = new int[histogramCount]

    // There is a huge performance hit in using GORM for large data blocks. So instead,
    // we use gmongo directly. This appars to be about an order of magnitude faster for
    // the purposes of building a histogram. Using aggregation would probably be faster
    // still, but that can wait.
    def cursor = Mapped.collection.find(genome: genome.gi, sampleId: sample.id, refStart: [$lte: end], refEnd: [$gte: start]).hint(["genome":1, "sampleId":1, "refStart":1])
    cursor.each { f ->
      def bin = Math.floor((f['refStart'] - start) / interval).toInteger()
      data[bin]++
    }

    Integer maximum = data.max()
    if (maximum == 0) {
      maximum = 1;
    }

    List<Map> result = data.collect { count ->
      [start: (start += interval),
       end: start,
       interval: 0,
       absolute: count,
       value: count / maximum]
    }

    return result
  }


  /**
   * Retrieve the mapped read data across the region.
   *
   * @param genome the specified genome
   * @param sample the specified sample
   * @param start start position within the genome.
   * @param end end position within the genome.
   * @return a list of mapped read data records.
   */
  def getMappedRegion(Genome genome, Sample sample, Integer start, Integer end) {

    def cursor = Mapped.collection.find(genome: genome.gi, sampleId: sample.id, refStart: [$lte: end], refEnd: [$gte: start]).hint(["genome":1, "sampleId":1, "refStart":1])

    List<Map> data = cursor.collect { f ->
      [start: f['refStart'], end: f['refEnd'], strand: f['refStrand'], readId: f['readId'], id: f['_id'].toString(), isRef: (f['isRef'] ? true : false) ]
    }

    return [data: data]
  }

}
