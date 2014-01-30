# Change Log

## 1.4.0

*Release date: 1 June 2012*

**FEATURES**

* Completely redone interface
* Save bookmarks within the app
* Search genome features
* Genome feature details page
* BLAST read sequences and contig sequences

## 1.3.0

*Release date: 28 Feb 2012*

**FEATURES**

* Link mapped genes to NCBI pages
* Use MD data from read rather than using JAligner to find Alignment
* Generates contig sequence for a mapped read
* Highlights selected read sequence in contig

**FIXES**

* Trying to send to email to new user when 'use LDAP' selected
* Sample nav item had rounded corners when logged in as non-admin

## 1.2.7

*Release date: 7 Feb 2012*

**FEATURES**

* Tab for Project level statistics to the genome page
* Total number of samples displayed in the project list view
* Cancel Edit link to return to main view without saving
* More descriptive page titles
* Pagination added to tables
* Default Mapped tab changed to Alignment

**FIXES**

* Remove broken Add Sample button on Sample list page
* Broken Edit Alignment button
* Genomes features not displaying even when features existed
* Formatting for Add User popup

## 1.2.6

*Release date: 6 Feb 2012*

**FIXES**

* Mapped alignment positions line up properly with genome positions
* Open new tab when clicking on read in JBrowse
* Adds link to show all samples from genome details page
* Edit User button properly labelled and working
* Added cancer type to sample page
* Users and UserRoles save properly

## 1.2.5

*Release date: 3 Feb 2012*

**FIXES**

* Show reads that map to both reference sets in red

## 1.2.4

*Release date: 2 Feb 2012*

**FIXES**

* Updated README.md
* Corrected JavaScript issues which broke adding users

## 1.2.3

*Release date: 30 Jan 2012*

**FIXES**

* Corrected Config Access issues

## 1.2.2

*Release date: 25 Jan 2012*

**FEATURES**

* Config file can be specified through Java System Property

**FIXES**

* Deploying under Tomcat or Jetty works against
* OpenJDK compatible (No longer requires Oracle JDK)
* 404 issue for reads that didn't map to any gene

## 1.2.1

*Release date: 23 Jan 2012*

**FIXES**

* Errors on JBrowse page

## 1.2

*Release date: 20 Jan 2012*

**FEATURES**

* Simplified installation
* Added embedded Jetty server
* Mapped read details page
* Display read alignment against genome sequence

**FIXES**

* UserRoles not being deleted with User
* Edit button works in FF 3.6
* Statistics tables sorted by max coverage

## 1.1

*Release date: 25 Nov 2011*

**FEATURES**  
* New Admin Interface
* Role have access levels for more control over user access
* LDAP option when creating a new user to stop credentials from being sent to keep login control with the LDAP server
* Project owners can control the visibility of their project and user access levels
* Create Alignments from Project page
* Project/Samples/Alignments and Users can all be edited and delete
* Reads that map to both pathogen and reference genomes are highlighted


**FIXES**
* Popups populated through ajax calls
* Grids refreshed rather than forcing page reload
* Moved Admin link to nav bar

## 1.0.2

*Release date: 28 Oct 2011*

**FIXES**  
* JBrowse unwanted caching of old tracks

## 1.0.1

*Release date: 20 Oct 2011*

**FIXES**  
* Projects seen in JBrowse filtered by access privileges

## 1.0

*Release date: 12 Oct 2011*

* Initial release
