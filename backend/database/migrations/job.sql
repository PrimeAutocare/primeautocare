DROP TABLE JOB CASCADE CONSTRAINTS;

CREATE TABLE JOB (
    job_no   NUMBER(2)   CONSTRAINT job_pk PRIMARY KEY,
    job_desc VARCHAR(60) NOT NULL
);

COMMENT ON COLUMN JOB.job_no   IS 'Unique job type identifier';
COMMENT ON COLUMN JOB.job_desc IS 'Description of the service/job type (e.g. Oil Change, Tyre Rotation)';
