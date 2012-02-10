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

  Map getSplitAlignment(Mapped mappedInstance) {
    
    String markUp = new String()
    String genome = new String()
    int placeholder = 0

    def m = mappedInstance.md.findAll(/([A-Z]+|\d+)/)

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
    string.replaceAll(/.{55}/){all -> all + ';'}.split(';')
  }
}
