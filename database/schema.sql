-- =====================================================
-- File:        schema.sql
-- Purpose:     One-shot setup — runs all table migrations
--              for PrimeAutocare in dependency order
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================
-- Identifiers are human-readable codes: a two-letter entity
-- prefix followed by a zero-padded counter (e.g. CU0001).
-- Each table owns a sequence; the column DEFAULT formats the
-- next value, so inserts may omit the key exactly as they did
-- under GENERATED ALWAYS AS IDENTITY.
-- =====================================================

-- ── 1. No dependencies ───────────────────────────────────────────────────────

-- EMPLOYEE
DROP TABLE IF EXISTS EMPLOYEE CASCADE;
DROP SEQUENCE IF EXISTS employee_seq CASCADE;
CREATE SEQUENCE employee_seq;
CREATE TABLE EMPLOYEE (
    emp_no        VARCHAR(6)   CONSTRAINT employee_pk PRIMARY KEY
                               DEFAULT 'EM' || LPAD(NEXTVAL('employee_seq')::TEXT, 4, '0'),
    emp_gname     VARCHAR(15)  NOT NULL,
    emp_fname     VARCHAR(15)  NOT NULL,
    emp_phone     VARCHAR(13)  NOT NULL,
    emp_email     VARCHAR(30)  NOT NULL,
    emp_passhash  VARCHAR(60)  NOT NULL,
    emp_role      CHAR(1)      NOT NULL,
    emp_create_dt DATE         NOT NULL
);
ALTER SEQUENCE employee_seq OWNED BY EMPLOYEE.emp_no;
COMMENT ON COLUMN EMPLOYEE.emp_no        IS 'Unique employee code — EM + 4 digits (e.g. EM0001)';
COMMENT ON COLUMN EMPLOYEE.emp_gname     IS 'Employee given (first) name';
COMMENT ON COLUMN EMPLOYEE.emp_fname     IS 'Employee family (last) name';
COMMENT ON COLUMN EMPLOYEE.emp_phone     IS 'Contact number — format: +94112233445';
COMMENT ON COLUMN EMPLOYEE.emp_email     IS 'Work email address; must be unique across all employees';
COMMENT ON COLUMN EMPLOYEE.emp_passhash  IS 'Hashed password for system login';
COMMENT ON COLUMN EMPLOYEE.emp_role      IS 'Role code: A = Admin, S = Supervisor, T = Technician';
COMMENT ON COLUMN EMPLOYEE.emp_create_dt IS 'Date the employee account was created in the system';
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_email_uq UNIQUE (emp_email);
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_role_chk CHECK (emp_role IN ('A', 'S', 'T'));
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_no_fmt_chk CHECK (emp_no ~ '^EM[0-9]{4}$');

-- JOB
DROP TABLE IF EXISTS JOB CASCADE;
DROP SEQUENCE IF EXISTS job_seq CASCADE;
CREATE SEQUENCE job_seq;
CREATE TABLE JOB (
    job_no   VARCHAR(6)  CONSTRAINT job_pk PRIMARY KEY
                         DEFAULT 'JO' || LPAD(NEXTVAL('job_seq')::TEXT, 4, '0'),
    job_desc VARCHAR(60) NOT NULL
);
ALTER SEQUENCE job_seq OWNED BY JOB.job_no;
COMMENT ON COLUMN JOB.job_no   IS 'Unique job type code — JO + 4 digits (e.g. JO0001)';
COMMENT ON COLUMN JOB.job_desc IS 'Description of the service/job type (e.g. Oil Change, Tyre Rotation)';
ALTER TABLE JOB ADD CONSTRAINT job_no_fmt_chk CHECK (job_no ~ '^JO[0-9]{4}$');

-- CUSTOMER
DROP TABLE IF EXISTS CUSTOMER CASCADE;
DROP SEQUENCE IF EXISTS customer_seq CASCADE;
CREATE SEQUENCE customer_seq;
CREATE TABLE CUSTOMER (
    cust_no    VARCHAR(6)  CONSTRAINT customer_pk PRIMARY KEY
                           DEFAULT 'CU' || LPAD(NEXTVAL('customer_seq')::TEXT, 4, '0'),
    cust_name  VARCHAR(30) NOT NULL,
    cust_phone VARCHAR(13) NOT NULL,
    cust_email VARCHAR(30) NOT NULL
);
ALTER SEQUENCE customer_seq OWNED BY CUSTOMER.cust_no;
COMMENT ON COLUMN CUSTOMER.cust_no    IS 'Unique customer code — CU + 4 digits (e.g. CU0001)';
COMMENT ON COLUMN CUSTOMER.cust_name  IS 'Full name of the customer';
COMMENT ON COLUMN CUSTOMER.cust_phone IS 'Contact number — format: +94112233445';
COMMENT ON COLUMN CUSTOMER.cust_email IS 'Email address; must be unique across all customers';
ALTER TABLE CUSTOMER ADD CONSTRAINT cust_email_uq UNIQUE (cust_email);
ALTER TABLE CUSTOMER ADD CONSTRAINT cust_no_fmt_chk CHECK (cust_no ~ '^CU[0-9]{4}$');

-- ── 2. Depends on CUSTOMER ───────────────────────────────────────────────────

-- VEHICLE
DROP TABLE IF EXISTS VEHICLE CASCADE;
DROP SEQUENCE IF EXISTS vehicle_seq CASCADE;
CREATE SEQUENCE vehicle_seq;
CREATE TABLE VEHICLE (
    vehi_id      VARCHAR(6)  CONSTRAINT vehicle_pk PRIMARY KEY
                             DEFAULT 'VE' || LPAD(NEXTVAL('vehicle_seq')::TEXT, 4, '0'),
    cust_no      VARCHAR(6)  NOT NULL,
    vehi_license VARCHAR(10) NOT NULL,
    vehi_make    VARCHAR(20) NOT NULL,
    vehi_model   VARCHAR(20) NOT NULL,
    vehi_year    INTEGER     NOT NULL
);
ALTER SEQUENCE vehicle_seq OWNED BY VEHICLE.vehi_id;
COMMENT ON COLUMN VEHICLE.vehi_id      IS 'Unique vehicle code — VE + 4 digits (e.g. VE0001)';
COMMENT ON COLUMN VEHICLE.cust_no      IS 'Reference to the owning CUSTOMER';
COMMENT ON COLUMN VEHICLE.vehi_license IS 'Licence plate number. ERD specified VARCHAR(5); extended to VARCHAR(10) to accommodate real-world plate lengths (e.g. CAB-1234)';
COMMENT ON COLUMN VEHICLE.vehi_make    IS 'Vehicle manufacturer (e.g. Toyota, Honda)';
COMMENT ON COLUMN VEHICLE.vehi_model   IS 'Vehicle model name (e.g. Corolla, Civic)';
COMMENT ON COLUMN VEHICLE.vehi_year    IS 'Four-digit manufacture year (e.g. 2021)';
ALTER TABLE VEHICLE ADD CONSTRAINT customer_vehicle_fk FOREIGN KEY (cust_no) REFERENCES CUSTOMER (cust_no);
ALTER TABLE VEHICLE ADD CONSTRAINT vehi_id_fmt_chk CHECK (vehi_id ~ '^VE[0-9]{4}$');

-- ── 3. Depends on VEHICLE ────────────────────────────────────────────────────

-- VEHICLE_VISIT
DROP TABLE IF EXISTS VEHICLE_VISIT CASCADE;
DROP SEQUENCE IF EXISTS vehicle_visit_seq CASCADE;
CREATE SEQUENCE vehicle_visit_seq;
CREATE TABLE VEHICLE_VISIT (
    visit_id           VARCHAR(6) CONSTRAINT vehicle_visit_pk PRIMARY KEY
                                  DEFAULT 'VI' || LPAD(NEXTVAL('vehicle_visit_seq')::TEXT, 4, '0'),
    vehi_id            VARCHAR(6) NOT NULL,
    visit_check_in_dt  DATE       NOT NULL,
    visit_check_out_dt DATE,
    visit_status       CHAR(1)    NOT NULL
);
ALTER SEQUENCE vehicle_visit_seq OWNED BY VEHICLE_VISIT.visit_id;
COMMENT ON COLUMN VEHICLE_VISIT.visit_id           IS 'Unique visit code — VI + 4 digits (e.g. VI0001)';
COMMENT ON COLUMN VEHICLE_VISIT.vehi_id            IS 'Reference to the VEHICLE being serviced';
COMMENT ON COLUMN VEHICLE_VISIT.visit_check_in_dt  IS 'Date the vehicle was checked in for service';
COMMENT ON COLUMN VEHICLE_VISIT.visit_check_out_dt IS 'Date the vehicle was collected by the customer; NULL until the vehicle is picked up';
COMMENT ON COLUMN VEHICLE_VISIT.visit_status       IS 'Visit status: C = Checked-In, I = In-progress, D = Done, O = Out / Picked Up';
ALTER TABLE VEHICLE_VISIT ADD CONSTRAINT vehicle_vehicle_visit_fk FOREIGN KEY (vehi_id) REFERENCES VEHICLE (vehi_id);
ALTER TABLE VEHICLE_VISIT ADD CONSTRAINT visit_status_chk CHECK (visit_status IN ('C', 'I', 'D', 'O'));
ALTER TABLE VEHICLE_VISIT ADD CONSTRAINT visit_id_fmt_chk CHECK (visit_id ~ '^VI[0-9]{4}$');

-- ── 4. Depends on VEHICLE_VISIT, JOB, and EMPLOYEE ──────────────────────────

-- JOB_ASSIGNMENT
DROP TABLE IF EXISTS JOB_ASSIGNMENT CASCADE;
DROP SEQUENCE IF EXISTS job_assignment_seq CASCADE;
CREATE SEQUENCE job_assignment_seq;
CREATE TABLE JOB_ASSIGNMENT (
    jobassign_id          VARCHAR(6)   CONSTRAINT job_assignment_pk PRIMARY KEY
                                       DEFAULT 'JA' || LPAD(NEXTVAL('job_assignment_seq')::TEXT, 4, '0'),
    visit_id              VARCHAR(6)   NOT NULL,
    job_no                VARCHAR(6)   NOT NULL,
    jobassign_assigned_by VARCHAR(6)   NOT NULL,
    jobassign_assign_dt   DATE         NOT NULL,
    jobassign_start_dt    DATE,
    jobassign_complete_dt DATE,
    jobassign_status      CHAR(1)      NOT NULL,
    jobassign_cost        NUMERIC(9, 2),
    jobassign_notes       VARCHAR(100)
);
ALTER SEQUENCE job_assignment_seq OWNED BY JOB_ASSIGNMENT.jobassign_id;
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_id          IS 'Unique job assignment code — JA + 4 digits (e.g. JA0001)';
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
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT jobassign_id_fmt_chk CHECK (jobassign_id ~ '^JA[0-9]{4}$');
