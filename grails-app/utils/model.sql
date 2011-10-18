CREATE TABLE `alignment` (  `id` int(11),  `aligner` varchar(100),  `input_file` varchar(255),  `output_file` varchar(255),  `timestamp` datetime,  `sequencing_id` smallint(6) ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `cancer` (  `id` smallint,  `name` varchar(64) ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `class` (  `id` smallint,  `name` varchar(128) ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `feature` (  `id` smallint,  `name` varchar(128) ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `mapped` (  `id` bigint, `sequencing_id` smallint,  `read_id` char(100),  `sequencing_type` char(5),  `read_lgth` smallint(6),  `min_qual` tinyint(4),  `avg_qual` float,  `miscalls` tinyint(4),  `alignment_id` int(11),  `project_id` smallint,  `is_human` char(1),  `refgenome_id` int(11),  `read_start` smallint(5),  `ref_start` int(11),  `ref_strand` char(7),  `align_lgth` smallint(6),  `score` tinyint(3),  `mismatch` tinyint(4), `platform` char(8), `sample_id` smallint) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `project` (  `id` smallint,  `name` varchar(64),  `description` varchar(255),  `wiki_link` varchar(64) ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `refdb` (  `id` smallint,  `name` varchar(64) ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `refgenome` (  `id` int(11),  `parent_id` int(11),  `xseq_id` varchar(32),  `xseq_version` varchar(32),  `name` varchar(255),  `description` char(255),  `feature_id` smallint,  `start` int(11),  `stop` int(11),  `strand` char(1),  `class_id` smallint,  `refdb_id` smallint,  `is_active` tinyint(3),  `created` datetime,  `updated` datetime,  `seq_id` int(11) ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `sample` (  `id` smallint,  `name` varchar(128),  `source` char(1),  `description` varchar(255),  `role` char(4),  `cancer_id` smallint,  `project_id` smallint ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `seq` (`id` int(11), `seq` varchar(8000)) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `sequencing` (  `id` smallint,  `name` varchar(255),  `platform` char(8),  `type` char(5),  `sample_id` smallint ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;
CREATE TABLE `unmapped` (  `id` bigint, `sequencing_id` smallint,  `read_id` char(100),  `sequencing_type` char(4),  `read_lgth` smallint(6),  `min_qual` tinyint(4),  `avg_qual` float,  `miscalls` tinyint(4),  `alignment_id` int(11),  `project_id` smallint, `platform` char(8), `sample_id` smallint ) ENGINE=InfiniDB DEFAULT CHARSET=latin1;