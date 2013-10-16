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

import groovy.time.*
import grails.plugins.springsecurity.Secured

class MappedService {

    static transactional = false

    def authService
    def projectService

    Mapped get(String id) {
        Mapped.get id
    }

    ArrayList otherHits(Mapped mappedInstance) {
        return Mapped.collection.find(
          "readId": mappedInstance.readId
          , "_id": [$ne: mappedInstance.id]
        )
        .collect {
          [
            id: it._id.toString()
            , gi: it.genome 
            , refStart: it.refStart
            , refEnd: it.refEnd
          ]
        }
    }

    List<Mapped> getAllowedMappeds() {
        if (authService.isCapsidAdmin()) {
            Mapped.list()
        } else {
            Mapped.security(projectService.getAllowedProjects()?.label)?.list()
        }
    }

  Map getSplitAlignment(Mapped mappedInstance) {

    String markUp = new String()
    String genome = new String()
    int placeholder = 0

    def m = mappedInstance.MD.findAll(/([A-Z]+|\d+)/)

    m.each {
      if (it.isNumber()) {
        it = it as int
        if (it > 0) {
          genome = genome + mappedInstance.sequence[placeholder..placeholder + (it - 1)]
          markUp = markUp + '|'*it
          placeholder = placeholder + it
        }
      } else {
        placeholder++
        markUp = markUp + '.'
        genome = genome + it
      }
    }

    Map formatted = [
      query: [ seq: [], pos: [] ],
      ref: [ seq: [], pos: [] ],
      markup: []
    ]

    formatted.query.seq = bucket(mappedInstance.sequence)
    formatted.ref.seq = bucket(genome)
    formatted.markup = bucket(markUp)

    for (i in 0..<formatted.query.seq.size()) {
      int qc = formatted.query.seq[i].findAll {it ==~ /\w/}.size()
      int rc = formatted.ref.seq[i].findAll {it ==~ /\w/}.size()
      formatted.query.pos[i] = i==0?qc:rc+formatted.query.pos[i-1]
      formatted.ref.pos[i] = i==0?rc:rc+formatted.ref.pos[i-1]
    }

    formatted
  }

  List bucket(String string) {
    string.replaceAll(/.{80}/){all -> all + ';'}.split(';')
  }

  ArrayList getOverlappingReads(Mapped mappedInstance) {
    ArrayList reads = []
    int start = mappedInstance.refStart
    int end = mappedInstance.refEnd

    ArrayList readsQuery = Mapped.collection.find(
        [
        alignment: mappedInstance.alignment
        , genome: mappedInstance.genome as int
        , refStrand: mappedInstance.refStrand
        ]
      ).collect {
        [
          refStart: it.refStart
          , refEnd: it.refEnd
          , sequence: it.sequence
        ]
      } 

    while (true) {
      reads = readsQuery.findAll {it.refStart < end && it.refEnd > start }
        
      if (start == reads.refStart.min() && end == reads.refEnd.max() ) {
        break
      }

      start = reads.refStart.min()
      end = reads.refEnd.max()
    }

    reads.sort{it.refStart}
  }

  List getContig(ArrayList reads, Mapped mappedInstance) {

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

    seq_array[mappedInstance.refStart] = '<b>' + seq_array[mappedInstance.refStart]
    seq_array[mappedInstance.refEnd] = seq_array[mappedInstance.refEnd] + '</b>'
    
    seq_array.collect { it.value }
  }

  // Calculate and build a histogram for the gene data across the region.
  def getHistogramRegion(Genome genome, Sample sample, Integer start, Integer end, Integer interval) {

    Integer histogramCount = Math.ceil((end - start) / interval).toInteger()

    Integer[] data = new int[histogramCount]

    def criteria = Mapped.createCriteria();
    List<Mapped> results = criteria.list {
      eq("genome", genome.gi)
      eq("sampleId", sample.id)
      le("refStart", end)
      ge("refEnd", start)
    }

    for(Mapped f in results) {
      Integer box = Math.floor((f.refStart - start) / interval).toInteger()
      data[box]++
    }

    Integer maximum = data.max()

    List<Map> result = data.collect { count ->
      [start: (start += interval),
       end: start,
       interval: 0,
       absolute: count,
       value: count / maximum]
    }

    return result
  }


  // Calculate and build a histogram for the read data across the region.
  def getMappedRegion(Genome genome, Sample sample, Integer start, Integer end) {

    def criteria = Mapped.createCriteria();
    List<Mapped> results = criteria.list {
      eq("genome", genome.gi)
      eq("sampleId", sample.id)
      le("refStart", end)
      ge("refEnd", start)
    }

    log.info("Results: " + results)

    List<Map> data = results.collect { Mapped m ->
      [start: m.refStart, end: m.refEnd, strand: m.refStrand, id: m.readId]
    }

    return [data: data]
  }

}
