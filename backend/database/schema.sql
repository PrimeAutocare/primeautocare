-- =====================================================
-- File:        schema.sql
-- Purpose:     One-shot setup — runs all table migrations
--              for PrimeAutocare in dependency order
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

-- ── 1. No dependencies ───────────────────────────────────────────────────────
 
-- EMPLOYEE
DROP TABLE IF EXISTS EMPLOYEE CASCADE;
CREATE TABLE EMPLOYEE (
    emp_no        INTEGER GENERATED ALWAYS AS IDENTITY CONSTRAINT employee_pk PRIMARY KEY,
    emp_gname     VARCHAR(15)  NOT NULL,
    emp_fname     VARCHAR(15)  NOT NULL,
    emp_phone     VARCHAR(13)  NOT NULL,
    emp_email     VARCHAR(30)  NOT NULL,
    emp_passhash  VARCHAR(30)  NOT NULL,
    emp_role      CHAR(1)      NOT NULL,
    emp_create_dt DATE         NOT NULL
);
COMMENT ON COLUMN EMPLOYEE.emp_no        IS 'Unique employee number (auto-generated)';
COMMENT ON COLUMN EMPLOYEE.emp_gname     IS 'Employee given (first) name';
COMMENT ON COLUMN EMPLOYEE.emp_fname     IS 'Employee family (last) name';
COMMENT ON COLUMN EMPLOYEE.emp_phone     IS 'Contact number — format: +94112233445';
COMMENT ON COLUMN EMPLOYEE.emp_email     IS 'Work email address; must be unique across all employees';
COMMENT ON COLUMN EMPLOYEE.emp_passhash  IS 'Hashed password for system login';
COMMENT ON COLUMN EMPLOYEE.emp_role      IS 'Role code: A = Admin, S = Supervisor, T = Technician';
COMMENT ON COLUMN EMPLOYEE.emp_create_dt IS 'Date the employee account was created in the system';
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_email_uq UNIQUE (emp_email);
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_role_chk CHECK (emp_role IN ('A', 'S', 'T'));
 
-- JOB
DROP TABLE IF EXISTS JOB CASCADE;
CREATE TABLE JOB (
    job_no   INTEGER GENERATED ALWAYS AS IDENTITY CONSTRAINT job_pk PRIMARY KEY,
    job_desc VARCHAR(60) NOT NULL
);
COMMENT ON COLUMN JOB.job_no   IS 'Unique job type identifier (auto-generated)';
COMMENT ON COLUMN JOB.job_desc IS 'Description of the service/job type (e.g. Oil Change, Tyre Rotation)';
 
-- VEHICLE_OWNER
DROP TABLE IF EXISTS VEHICLE_OWNER CASCADE;
CREATE TABLE VEHICLE_OWNER (
    owner_no    INTEGER GENERATED ALWAYS AS IDENTITY CONSTRAINT vehicle_owner_pk PRIMARY KEY,
    owner_name  VARCHAR(30) NOT NULL,
    owner_phone VARCHAR(13) NOT NULL,
    owner_email VARCHAR(30) NOT NULL
);
COMMENT ON COLUMN VEHICLE_OWNER.owner_no    IS 'Unique vehicle owner number (auto-generated)';
COMMENT ON COLUMN VEHICLE_OWNER.owner_name  IS 'Full name of the vehicle owner';
COMMENT ON COLUMN VEHICLE_OWNER.owner_phone IS 'Contact number — format: +94112233445';
COMMENT ON COLUMN VEHICLE_OWNER.owner_email IS 'Email address; must be unique across all owners';
ALTER TABLE VEHICLE_OWNER ADD CONSTRAINT owner_email_uq UNIQUE (owner_email);
 
-- ── 2. Depends on VEHICLE_OWNER ──────────────────────────────────────────────
 
-- VEHICLE
DROP TABLE IF EXISTS VEHICLE CASCADE;
CREATE TABLE VEHICLE (
    vehi_id      INTEGER GENERATED ALWAYS AS IDENTITY CONSTRAINT vehicle_pk PRIMARY KEY,
    owner_no     INTEGER     NOT NULL,
    vehi_license VARCHAR(10) NOT NULL,
    vehi_make    VARCHAR(20) NOT NULL,
    vehi_model   VARCHAR(20) NOT NULL,
    vehi_year    INTEGER     NOT NULL
);
COMMENT ON COLUMN VEHICLE.vehi_id      IS 'Unique vehicle identifier (auto-generated)';
COMMENT ON COLUMN VEHICLE.owner_no     IS 'Reference to the owning VEHICLE_OWNER';
COMMENT ON COLUMN VEHICLE.vehi_license IS 'Licence plate number. ERD specified VARCHAR(5); extended to VARCHAR(10) to accommodate real-world plate lengths (e.g. CAB-1234)';
COMMENT ON COLUMN VEHICLE.vehi_make    IS 'Vehicle manufacturer (e.g. Toyota, Honda)';
COMMENT ON COLUMN VEHICLE.vehi_model   IS 'Vehicle model name (e.g. Corolla, Civic)';
COMMENT ON COLUMN VEHICLE.vehi_year    IS 'Four-digit manufacture year (e.g. 2021)';
ALTER TABLE VEHICLE ADD CONSTRAINT vehicle_owner_vehicle_fk FOREIGN KEY (owner_no) REFERENCES VEHICLE_OWNER (owner_no);
 
-- ── 3. Depends on VEHICLE ────────────────────────────────────────────────────
 
-- VEHICLE_VISIT
DROP TABLE IF EXISTS VEHICLE_VISIT CASCADE;
CREATE TABLE VEHICLE_VISIT (
    visit_id           INTEGER GENERATED ALWAYS AS IDENTITY CONSTRAINT vehicle_visit_pk PRIMARY KEY,
    vehi_id            INTEGER NOT NULL,
    visit_check_in_dt  DATE    NOT NULL,
    visit_check_out_dt DATE,
    visit_status       CHAR(1) NOT NULL
);
COMMENT ON COLUMN VEHICLE_VISIT.visit_id           IS 'Unique visit identifier (auto-generated)';
COMMENT ON COLUMN VEHICLE_VISIT.vehi_id            IS 'Reference to the VEHICLE being serviced';
COMMENT ON COLUMN VEHICLE_VISIT.visit_check_in_dt  IS 'Date the vehicle was checked in for service';
COMMENT ON COLUMN VEHICLE_VISIT.visit_check_out_dt IS 'Date the vehicle was collected by the owner; NULL until the vehicle is picked up';
COMMENT ON COLUMN VEHICLE_VISIT.visit_status       IS 'Visit status: C = Checked-In, I = In-progress, D = Done, O = Out / Picked Up';
ALTER TABLE VEHICLE_VISIT ADD CONSTRAINT vehicle_vehicle_visit_fk FOREIGN KEY (vehi_id) REFERENCES VEHICLE (vehi_id);
ALTER TABLE VEHICLE_VISIT ADD CONSTRAINT visit_status_chk CHECK (visit_status IN ('C', 'I', 'D', 'O'));
 
-- ── 4. Depends on VEHICLE_VISIT, JOB, and EMPLOYEE ──────────────────────────
 
-- JOB_ASSIGNMENT
DROP TABLE IF EXISTS JOB_ASSIGNMENT CASCADE;
CREATE TABLE JOB_ASSIGNMENT (
    jobassign_id          INTEGER GENERATED ALWAYS AS IDENTITY CONSTRAINT job_assignment_pk PRIMARY KEY,
    visit_id              INTEGER      NOT NULL,
    job_no                INTEGER      NOT NULL,
    jobassign_assigned_by INTEGER      NOT NULL,
    jobassign_assign_dt   DATE         NOT NULL,
    jobassign_start_dt    DATE,
    jobassign_complete_dt DATE,
    jobassign_status      CHAR(1)      NOT NULL,
    jobassign_cost        NUMERIC(9, 2),
    jobassign_notes       VARCHAR(100)
);
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_id          IS 'Unique job assignment identifier (auto-generated)';
COMMENT ON COLUMN JOB_ASSIGNMENT.visit_id              IS 'Reference to the VEHICLE_VISIT this assignment belongs to';
COMMENT ON COLUMN JOB_ASSIGNMENT.job_no                IS 'Reference to the JOB type being performed';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_assigned_by IS 'emp_no of the employee who created this assignment';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_assign_dt   IS 'Date the job was assigned';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_start_dt    IS 'Date work started; NULL until the technician begins';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_complete_dt IS 'Date work was completed; NULL until finished';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_status      IS 'Status code: P = Pending/Not yet started, I = In-progress, C = Completed, X = Cancelled';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_cost        IS 'Cost charged for this assignment; NULL until finalised';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_notes       IS 'Optional free-text notes on the assignment';
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT vehicle_visit_job_assignment_fk FOREIGN KEY (visit_id) REFERENCES VEHICLE_VISIT (visit_id);
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT job_job_assignment_fk FOREIGN KEY (job_no) REFERENCES JOB (job_no);
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT employee_job_assignment_fk FOREIGN KEY (jobassign_assigned_by) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT jobassign_status_chk CHECK (jobassign_status IN ('P', 'I', 'C', 'X'));

ALTER TABLE EMPLOYEE ALTER COLUMN emp_no ADD GENERATED ALWAYS AS IDENTITY;
ALTER TABLE JOB ALTER COLUMN job_no ADD GENERATED ALWAYS AS IDENTITY;
ALTER TABLE VEHICLE_OWNER ALTER COLUMN owner_no ADD GENERATED ALWAYS AS IDENTITY;
ALTER TABLE VEHICLE ALTER COLUMN vehi_id ADD GENERATED ALWAYS AS IDENTITY;
ALTER TABLE VEHICLE_VISIT ALTER COLUMN visit_id ADD GENERATED ALWAYS AS IDENTITY;
ALTER TABLE JOB_ASSIGNMENT ALTER COLUMN jobassign_id ADD GENERATED ALWAYS AS IDENTITY;