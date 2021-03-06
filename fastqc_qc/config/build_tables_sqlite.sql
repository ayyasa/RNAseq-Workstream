CREATE TABLE QT_BCL_DIRECTORY
(
BCL_DIRECTORY_ID  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
NAME VARCHAR2(128),
PATH VARCHAR2(128),
STATUS VARCHAR2(3),
DATE_MODIFIED DATE NOT NULL,
UNIQUE (NAME) ON CONFLICT IGNORE
);

CREATE TABLE QT_SAMPLE_GROUP
(
SAMPLE_GROUP_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
BCL_DIRECTORY_ID INTEGER,
NAME VARCHAR2(128),
USERNAME VARCHAR2(128),
SAMPLESHEET_CHECKSUM VARCHAR2(128),
DO_READCLEAN VARCHAR2(3),
NUM_READS INTEGER,
DATE_MODIFIED DATE NOT NULL,
UNIQUE (NAME) ON CONFLICT ABORT,
FOREIGN KEY (BCL_DIRECTORY_ID) REFERENCES QT_BCL_DIRECTORY (BCL_DIRECTORY_ID) 
          ON DELETE CASCADE  
);

CREATE TABLE QT_SAMPLE
(
SAMPLE_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
SAMPLE_GROUP_ID INTEGER NOT NULL,
LIMS_ID VARCHAR2(128), 
FASTQ_PREFIX VARCHAR2(128),
SS_SAMPLE_NAME VARCHAR2(128),
SS_SAMPLE_ID VARCHAR2(128),
SS_SAMPLE_PLATE VARCHAR2(128),
SS_SAMPLE_WELL VARCHAR2(128),
SS_I7_INDEX_ID VARCHAR2(128),
SS_INDEX VARCHAR2(128),
SS_SAMPLE_PROJECT VARCHAR2(128),
SS_DESCRIPTION VARCHAR2(128),
SS_ORDER INTEGER,
FOREIGN KEY (SAMPLE_GROUP_ID) REFERENCES QT_SAMPLE_GROUP (SAMPLE_GROUP_ID) 
          ON DELETE CASCADE  
);

CREATE TABLE QT_SAMPLE_ATTRIB
(
SAMPLE_ATTRIB_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
SAMPLE_ID INTEGER NOT NULL,
NAME VARCHAR2(128), 
VALUE VARCHAR2(128),
AORDER INTEGER,
FOREIGN KEY (SAMPLE_ID) REFERENCES QT_SAMPLE (SAMPLE_ID) 
          ON DELETE CASCADE  
);

CREATE TABLE QT_BCL2FASTQ_RUN
(
BCL2FASTQ_RUN_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
BCL_DIRECTORY_ID INTEGER NOT NULL, 
OUTPUT_DIR VARCHAR2(256),
LOADING_THREADS INTEGER,
DEMULTX_THREADS INTEGER,
PROC_THREADS INTEGER,
WRITE_THREADS INTEGER,
STATUS VARCHAR2(3),
DATE_MODIFIED DATE NOT NULL,
COMMAND VARCHAR2(256),
FOREIGN KEY (BCL_DIRECTORY_ID) REFERENCES QT_BCL_DIRECTORY (BCL_DIRECTORY_ID) 
          ON DELETE CASCADE  
);

CREATE TABLE QT_RAW_FASTQ_FILE
(
RAW_FASTQ_FILE_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
SAMPLE_ID INTEGER NOT NULL,
BCL2FASTQ_RUN_ID INTEGER,
READ_NUMBER INTEGER NOT NULL,
NAME VARCHAR2(256) NOT NULL,
PATH VARCHAR2(256) NOT NULL,
STATUS VARCHAR2(3) NOT NULL,
DATE_MODIFIED DATE NOT NULL,
FOREIGN KEY (SAMPLE_ID) REFERENCES QT_SAMPLE (SAMPLE_ID) 
	ON DELETE CASCADE,
UNIQUE (PATH, NAME) ON CONFLICT IGNORE
);

CREATE TABLE QT_CLEAN_FASTQ_FILE
(
CLEAN_FASTQ_FILE_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
RAW_FASTQ_FILE_ID INTEGER NOT NULL,
READCLEAN_RUN_ID INTEGER NOT NULL,
READ_NUMBER INTEGER NOT NULL,
TYPE VARCHAR2(64) NOT NULL,
NAME VARCHAR2(256) NOT NULL,
PATH VARCHAR2(256) NOT NULL,
STATUS VARCHAR2(3) NOT NULL,
DATE_MODIFIED DATE NOT NULL,
FOREIGN KEY (RAW_FASTQ_FILE_ID) REFERENCES QT_RAW_FASTQ_FILE (RAW_FASTQ_FILE_ID) 
	ON DELETE CASCADE,
FOREIGN KEY (READCLEAN_RUN_ID) REFERENCES QT_READCLEAN_RUN (READCLEAN_RUN_ID) 
	ON DELETE CASCADE
);

CREATE TABLE QT_QC_REPORT
(
QC_REPORT_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
USERNAME VARCHAR2(128) NOT NULL,
STATUS VARCHAR2(3) NOT NULL,
NAME VARCHAR2(256),
PATH VARCHAR2(256) NOT NULL,
FASTQC_OUTDIR VARCHAR2(256),
FASTQC_EXTRACT VARCHAR2(256),
DATE_MODIFIED DATE NOT NULL
);

CREATE TABLE QT_QCREP_2_FASTQ
(
QCREP_2_FASTQ_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
QC_REPORT_ID  INTEGER NOT NULL,
FASTQ_TYPE VARCHAR2(64) NOT NULL,
FASTQ_FILE_ID INTEGER NOT NULL,
FOREIGN KEY (QC_REPORT_ID) REFERENCES QT_QC_REPORT (QC_REPORT_ID) 
          ON DELETE CASCADE
);

CREATE TABLE QT_READCLEAN_RUN
(
READCLEAN_RUN_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
RAW_FASTQ_FILE_1_ID INTEGER NOT NULL,
RAW_FASTQ_FILE_2_ID INTEGER,
CLEAN_METHOD VARCHAR2(128),
OUTPUT_SELECTION VARCHAR2(128),
PARAM01 VARCHAR2(256),
PARAM02 VARCHAR2(256),
PARAM03 VARCHAR2(256),
PARAM04 VARCHAR2(256),
PARAM05 VARCHAR2(256),
PARAM06 VARCHAR2(256),
PARAM07 VARCHAR2(256),
STATUS VARCHAR2(3),
DATE_MODIFIED DATE NOT NULL
);



