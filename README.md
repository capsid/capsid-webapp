CaPSID
========
**CaPSID** (Computational Pathogen Sequence IDentification) is a comprehensive open source platform which integrates a high-performance computational pipeline for pathogen sequence identification and characterization in human genomes and transcriptomes together with a scalable results database and a user-friendly web-based software application for managing, querying and visualizing results.

**Project Leader** Vincent Ferretti  
**Development Team** Ivan Borozan, Philippe Laflamme, Shane Wilson, Stuart Watt

Downloading and using CaPSID is free, if you use CaPSID or its code in your work 
please acknowledge CaPSID by referring to its github homepage https://github.com/capsid. 
This is important for us since obtaining grants is one significant way to fund planning 
and implementation for our project. Also if you find CaPSID useful in your research feel 
free to let us know.  


Getting started
---------------
You will need a MongoDB database, a Python 2.7 installation and a Java Web Server. For more details, read the wiki:

  https://github.com/capsid/capsid/wiki/

Running the web application from the command line
-------------------------------------------------

CaPSID now uses Maven for building the web application. We recommend:

```shell
$ mvn 
```

to build the application. Once it is built, you can also use this command to run the web application directly from 
the command line:

```shell
$ mvn verify -Prun-server -pl capsid-webapp-httpd
```

License and copyright
---------------------
Licensed under the GNU General Public License, Version 3.0. See LICENSE for more details.

Copyright 2011 The Ontario Institute for Cancer Research.


Acknowledgement
---------------
This project is supported by the Ontario Institute for Cancer Research
(OICR) through funding provided by the government of Ontario, Canada.
