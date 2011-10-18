-- Add platform and sample_id columns to mapped
alter table mapped add column platform char(8);
alter table mapped add column  sample_id smallint(6);
update mapped, sequencing set mapped.platform = sequencing.platform, mapped.sample_id = sequencing.sample_id where sequencing.id = mapped.sequencing_id;

-- Add platform and sample_id columns to unmapped
alter table unmapped add column platform char(8);
alter table unmapped add column sample_id smallint(6);
update unmapped, sequencing set unmapped.platform = sequencing.platform, unmapped.sample_id = sequencing.sample_id where sequencing.id = unmapped.sequencing_id;

-- Create an entry in refgenome for unmapped contigs
SET @NEXT :=(select max(id)+1 from refgenome);
SET @STOP :=(select max(read_lgth + ref_start) from mapped where refgenome_id = 0);
insert into refgenome(`id`, `parent_id`, `xseq_id`, `xseq_version`, `name`, `description`, `feature_id`,  `start`,  `stop`,  `strand`,  `class_id`,  `refdb_id`,  `is_active`,  `created`,  `updated`,  `seq_id`)
VALUES( @NEXT, @NEXT, 'unmapped', 'unmapped.1', 'Unmapped contigs', 'Unmapped contigs', 1, 1,@STOP, 'P', 1, null, 1, now(), now(), null);

-- Update rows from mapped to point to new refgenome
update mapped set refgenome_id = @NEXT where refgenome_id = 0;

-- make a list of duplicated alignments
-- a duplicate alignment is one for which the same read aligns multiple times to the same genome at the same position on the same strand.
-- this query returns one of the alignment's ID (the first) and the number of duplicated alignments
select min(id), count(alignment_id) as dups from mapped group by alignment_id, read_id, refgenome_id, ref_start, ref_strand;

alter table mapped add column reference tinyint;
update mapped set reference = 0;

update mapped, duplicate
set mapped.reference = 1 where 
mapped.id = duplicate.id;

-- Delete duplicate reads from mapped
delete from mapped where reference = 0;

alter table mapped drop column reference;