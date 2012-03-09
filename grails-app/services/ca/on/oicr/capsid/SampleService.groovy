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

import grails.plugins.springsecurity.Secured

class SampleService {

    static transactional = false

    def authService
    def projectService

    void update(Sample sample, Map params) {
        sample.properties = params
        sample.save()
    }

    Sample get(String name) {
        Sample.findByName name
    }

    List<Sample> getAllowedSamples() {
        if (authService.isCapsidAdmin()) {
            Sample.list()
        } else {
            Sample.security(projectService.getAllowedProjects()?.label)?.list()
        }
    }

    Sample save(Map params) {
        if (get(params.name)) {
            return false
        }

        Sample sample = new Sample(params)
        sample.save(flush:true)
    }

    void delete(Sample sample) {
        String name = sample.name
        sample.delete()
        Alignment.findAllBySample(name).each { it.delete(flush: true) }
        Mapped.findAllBySample(name).each { it.delete(flush: true) }
    }
}
