-- SAMPLE_GROUP

-- Requested:
-- Create user schema FASTQC_OWNER
-- Create role 
CREATE TABLE FASTQC_OWNER.QT_SAMPLE_GROUP
(
SAMPLE_GROUP_ID NUMBER (10) NOT NULL PRIMARY KEY,
NAME VARCHAR2(128),
CONTACT_EMAIL VARCHAR2(128),
SAMPLESHEET_CHECKSUM VARCHAR2(128),
DO_READCLEAN VARCHAR2(3),
DATE_MODIFIED DATE NOT NULL
)
COMMENT ON TABLE QT_SAMPLE_GROUP IS 'A SAMPLE_GROUP represents a set of samples (libraries) that were sequenced';
-- GRANT INSERT, SELECT, UPDATE ON  QT_SAMPLE_GROUP TO SEQUEST_USER;
-- GRANT SELECT ON  QT_SAMPLE_GROUP TO SEQUEST_RO;

CREATE SEQUENCE SAMPLEGROUPIDSEQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;

-- GRANT SELECT ON SEQUEST.LCMSRUNIDSEQ TO SEQUEST_USER;


