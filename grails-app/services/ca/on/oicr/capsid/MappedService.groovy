/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*   This program and the accompanying materials are made available under the
*   terms of the GNU Public License v3.0.
*
*   You should have received a copy of the GNU General Public License along with
*   this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import grails.plugins.springsecurity.Secured

import jaligner.Alignment as jAlignment
import jaligner.Sequence as jSequence
import jaligner.SmithWatermanGotoh
import jaligner.formats.*
import jaligner.matrix.MatrixLoader
import jaligner.util.SequenceParser

class MappedService {

    static transactional = false

    def authService
    def projectService

    Mapped get(String id) {
        Mapped.get id
    }

    List<Mapped> getAllowedMappeds() {
        if (authService.isCapsidAdmin()) {
            Mapped.list()
        } else {
            Mapped.security(projectService.getAllowedProjects()?.label)?.list()
        }
    }

  Map getSplitAlignment(String query, String ref) {
    /* Sequence and Alignment from jAligner */
    jaligner.Sequence s1 = SequenceParser.parse(query)
    jaligner.Sequence s2 = SequenceParser.parse(ref)
    jaligner.Alignment alignment = SmithWatermanGotoh.align(s1, s2, MatrixLoader.load("BLOSUM62"), 10f, 0.5f)

    Map formatted = [
      query: [ seq: [], pos: [] ],
      ref: [ seq: [], pos: [] ],
      markup: []
    ]

    formatted.query.seq = bucket(alignment.getSequence1().toString())
    formatted.ref.seq = bucket(alignment.getSequence2().toString())
    formatted.markup = bucket(alignment.getMarkupLine().toString())

    for (i in 0..<formatted.query.seq.size()) {
      int qc = formatted.query.seq[i].findAll {it ==~ /\w/}.size()
      int rc = formatted.ref.seq[i].findAll {it ==~ /\w/}.size()
      formatted.query.pos[i] = i==0?qc:rc+formatted.query.pos[i-1]
      formatted.ref.pos[i] = i==0?rc:rc+formatted.ref.pos[i-1]
    }

    formatted
  }

  List bucket(String string) {
    string.replaceAll(/.{55}/){all -> all + ';'}.split(';')
  }
}
