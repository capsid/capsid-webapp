/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the GNU Public License v3.0.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program.  If not, see <http://www.gnu.org/licenses/>.
 */

includeTargets << grailsScript("Init")

target(main: "Downloads and installs the required Dojo SDK") {
  // TODO: Figure out where to place this. application.properties?
  dojoVersion="1.6.1"
  dojoTar="${projectWorkDir}/dojo.tar.gz"
  // Download Dojo SDK if required
  if(new File(dojoTar).exists() == false) {
    ant.get(src:"http://download.dojotoolkit.org/release-${dojoVersion}/dojo-release-${dojoVersion}-src.tar.gz", dest:dojoTar)
  }
  ant.exec(executable:"tar") {
    ant.arg(value:"-zxf")
    ant.arg(value:dojoTar)
    ant.arg(value:"--directory")
    ant.arg(value:"${basedir}/web-app/js/src/")
  }
  ant.delete(file:"${basedir}/web-app/js/src/dojo-sdk")
  ant.move(file:"${basedir}/web-app/js/src/dojo-release-${dojoVersion}-src", tofile:"${basedir}/web-app/js/src/dojo-sdk")
}

setDefaultTarget(main)
