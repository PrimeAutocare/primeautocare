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
    emp_username  VARCHAR(20)  NOT NULL,
    emp_passhash  VARCHAR(60)  NOT NULL,
    emp_role      CHAR(1)      NOT NULL,
    emp_create_dt DATE         NOT NULL,
    emp_hourly_rate NUMERIC(7, 2) NOT NULL
);
ALTER SEQUENCE employee_seq OWNED BY EMPLOYEE.emp_no;
COMMENT ON COLUMN EMPLOYEE.emp_no        IS 'Unique employee code — EM + 4 digits (e.g. EM0001)';
COMMENT ON COLUMN EMPLOYEE.emp_gname     IS 'Employee given (first) name';
COMMENT ON COLUMN EMPLOYEE.emp_fname     IS 'Employee family (last) name';
COMMENT ON COLUMN EMPLOYEE.emp_phone     IS 'Contact number — format: +94112233445';
COMMENT ON COLUMN EMPLOYEE.emp_email     IS 'Work email address; must be unique across all employees';
COMMENT ON COLUMN EMPLOYEE.emp_username  IS 'Unique login username';
COMMENT ON COLUMN EMPLOYEE.emp_passhash  IS 'Hashed password for system login';
COMMENT ON COLUMN EMPLOYEE.emp_role      IS 'Role code: A = Admin, S = Supervisor, T = Technician';
COMMENT ON COLUMN EMPLOYEE.emp_create_dt IS 'Date the employee account was created in the system';
COMMENT ON COLUMN EMPLOYEE.emp_hourly_rate IS 'Pay rate per hour worked; basis for payroll reporting';
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_email_uq UNIQUE (emp_email);
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_username_uq UNIQUE (emp_username);
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_role_chk CHECK (emp_role IN ('A', 'S', 'T'));
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_no_fmt_chk CHECK (emp_no ~ '^EM[0-9]{4}$');
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_hourly_rate_chk CHECK (emp_hourly_rate >= 0);

-- JOB (job type catalog)
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
    cust_no      VARCHAR(6),
    vehi_license VARCHAR(10) NOT NULL,
    vehi_make    VARCHAR(20) NOT NULL,
    vehi_model   VARCHAR(20) NOT NULL,
    vehi_year    INTEGER     NOT NULL
);
ALTER SEQUENCE vehicle_seq OWNED BY VEHICLE.vehi_id;
COMMENT ON COLUMN VEHICLE.vehi_id      IS 'Unique vehicle code — VE + 4 digits (e.g. VE0001)';
COMMENT ON COLUMN VEHICLE.cust_no      IS 'Reference to the owning CUSTOMER; nullable until a customer is linked';
COMMENT ON COLUMN VEHICLE.vehi_license IS 'Licence plate number. ERD specified VARCHAR(5); extended to VARCHAR(10) to accommodate real-world plate lengths (e.g. CAB-1234)';
COMMENT ON COLUMN VEHICLE.vehi_make    IS 'Vehicle manufacturer (e.g. Toyota, Honda)';
COMMENT ON COLUMN VEHICLE.vehi_model   IS 'Vehicle model name (e.g. Corolla, Civic)';
COMMENT ON COLUMN VEHICLE.vehi_year    IS 'Four-digit manufacture year (e.g. 2021)';
ALTER TABLE VEHICLE ADD CONSTRAINT customer_vehicle_fk FOREIGN KEY (cust_no) REFERENCES CUSTOMER (cust_no);
ALTER TABLE VEHICLE ADD CONSTRAINT vehi_id_fmt_chk CHECK (vehi_id ~ '^VE[0-9]{4}$');
ALTER TABLE VEHICLE ADD CONSTRAINT vehi_license_uq UNIQUE (vehi_license);

-- ── 3. Depends on VEHICLE, JOB, and EMPLOYEE ────────────────────────────────

-- JOBS (merged job creation + job execution; replaces VEHICLE_VISIT + JOB_ASSIGNMENT)
DROP TABLE IF EXISTS JOBS CASCADE;
DROP SEQUENCE IF EXISTS jobs_seq CASCADE;
CREATE SEQUENCE jobs_seq;
CREATE TABLE JOBS (
    job_id       VARCHAR(6)   CONSTRAINT jobs_pk PRIMARY KEY
                              DEFAULT 'JB' || LPAD(NEXTVAL('jobs_seq')::TEXT, 4, '0'),
    job_no       VARCHAR(6)   NOT NULL,
    vehi_id      VARCHAR(6)   NOT NULL,
    emp_no       VARCHAR(6)   NOT NULL,
    performed_by VARCHAR(6),
    status       CHAR(1)      NOT NULL,
    hours        NUMERIC(5, 2),
    cost         NUMERIC(9, 2),
    notes        VARCHAR(100),
    created_by   VARCHAR(6)   NOT NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP    NOT NULL DEFAULT now()
);
ALTER SEQUENCE jobs_seq OWNED BY JOBS.job_id;
COMMENT ON COLUMN JOBS.job_id       IS 'Unique job code — JB + 4 digits (e.g. JB0001)';
COMMENT ON COLUMN JOBS.job_no       IS 'Reference to the JOB type being performed';
COMMENT ON COLUMN JOBS.vehi_id      IS 'Reference to the VEHICLE being serviced';
COMMENT ON COLUMN JOBS.emp_no       IS 'emp_no of the employee assigned to this job';
COMMENT ON COLUMN JOBS.performed_by IS 'emp_no of the technician who carried out the work; NULL until work starts';
COMMENT ON COLUMN JOBS.status       IS 'Status code: P = Pending, I = In-progress, C = Completed, X = Cancelled';
COMMENT ON COLUMN JOBS.hours        IS 'Labour hours logged against this job; basis for utilization and invoicing';
COMMENT ON COLUMN JOBS.cost         IS 'Cost charged for this job; NULL until finalised';
COMMENT ON COLUMN JOBS.notes        IS 'Optional free-text notes on the job';
COMMENT ON COLUMN JOBS.created_by   IS 'emp_no of the employee who created this job';
COMMENT ON COLUMN JOBS.created_at   IS 'Timestamp the job record was created';
COMMENT ON COLUMN JOBS.updated_at   IS 'Timestamp the job record was last updated';
ALTER TABLE JOBS ADD CONSTRAINT job_jobs_fk FOREIGN KEY (job_no) REFERENCES JOB (job_no);
ALTER TABLE JOBS ADD CONSTRAINT vehicle_jobs_fk FOREIGN KEY (vehi_id) REFERENCES VEHICLE (vehi_id);
ALTER TABLE JOBS ADD CONSTRAINT employee_jobs_fk FOREIGN KEY (emp_no) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOBS ADD CONSTRAINT performer_jobs_fk FOREIGN KEY (performed_by) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOBS ADD CONSTRAINT creator_jobs_fk FOREIGN KEY (created_by) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOBS ADD CONSTRAINT jobs_status_chk CHECK (status IN ('P', 'I', 'C', 'X'));
ALTER TABLE JOBS ADD CONSTRAINT jobs_id_fmt_chk CHECK (job_id ~ '^JB[0-9]{4}$');
ALTER TABLE JOBS ADD CONSTRAINT jobs_hours_chk CHECK (hours IS NULL OR hours > 0);
-- Work that has started or finished must name the technician who did it,
-- otherwise utilization silently under-reports.
ALTER TABLE JOBS ADD CONSTRAINT jobs_performer_req_chk
    CHECK (status NOT IN ('I', 'C') OR performed_by IS NOT NULL);
-- Completed work must have logged hours, otherwise payroll silently under-pays.
ALTER TABLE JOBS ADD CONSTRAINT jobs_hours_req_chk
    CHECK (status <> 'C' OR hours IS NOT NULL);

-- ── 4. Depends on JOBS ───────────────────────────────────────────────────────

-- INVOICE
-- One bill per job: the customer settles the total for that individual job.
DROP TABLE IF EXISTS INVOICE CASCADE;
DROP SEQUENCE IF EXISTS invoice_seq CASCADE;
CREATE SEQUENCE invoice_seq;
CREATE TABLE INVOICE (
    inv_no     VARCHAR(6)    CONSTRAINT invoice_pk PRIMARY KEY
                             DEFAULT 'IN' || LPAD(NEXTVAL('invoice_seq')::TEXT, 4, '0'),
    job_id     VARCHAR(6)    NOT NULL,
    inv_date   DATE          NOT NULL,
    inv_total  NUMERIC(10, 2) NOT NULL,
    inv_status CHAR(1)       NOT NULL
);
ALTER SEQUENCE invoice_seq OWNED BY INVOICE.inv_no;
COMMENT ON COLUMN INVOICE.inv_no     IS 'Unique invoice code — IN + 4 digits (e.g. IN0001)';
COMMENT ON COLUMN INVOICE.job_id     IS 'Reference to the JOBS row being billed; one invoice per job';
COMMENT ON COLUMN INVOICE.inv_date   IS 'Date the invoice was raised';
COMMENT ON COLUMN INVOICE.inv_total  IS 'Total billed for the job';
COMMENT ON COLUMN INVOICE.inv_status IS 'Status: U = Unpaid, P = Partially paid, S = Settled, V = Void';
ALTER TABLE INVOICE ADD CONSTRAINT jobs_invoice_fk FOREIGN KEY (job_id) REFERENCES JOBS (job_id);
ALTER TABLE INVOICE ADD CONSTRAINT inv_job_uq UNIQUE (job_id);
ALTER TABLE INVOICE ADD CONSTRAINT inv_status_chk CHECK (inv_status IN ('U', 'P', 'S', 'V'));
ALTER TABLE INVOICE ADD CONSTRAINT inv_total_chk CHECK (inv_total >= 0);
ALTER TABLE INVOICE ADD CONSTRAINT inv_no_fmt_chk CHECK (inv_no ~ '^IN[0-9]{4}$');

-- ── 5. Depends on INVOICE ───────────────────────────────────────────────────

-- PAYMENT
-- An invoice may be settled over several payments, so this is its own table
-- rather than a paid flag on INVOICE.
DROP TABLE IF EXISTS PAYMENT CASCADE;
DROP SEQUENCE IF EXISTS payment_seq CASCADE;
CREATE SEQUENCE payment_seq;
CREATE TABLE PAYMENT (
    pay_no     VARCHAR(6)    CONSTRAINT payment_pk PRIMARY KEY
                             DEFAULT 'PY' || LPAD(NEXTVAL('payment_seq')::TEXT, 4, '0'),
    inv_no     VARCHAR(6)    NOT NULL,
    pay_date   DATE          NOT NULL,
    pay_amount NUMERIC(10, 2) NOT NULL,
    pay_method CHAR(1)       NOT NULL
);
ALTER SEQUENCE payment_seq OWNED BY PAYMENT.pay_no;
COMMENT ON COLUMN PAYMENT.pay_no     IS 'Unique payment code — PY + 4 digits (e.g. PY0001)';
COMMENT ON COLUMN PAYMENT.inv_no     IS 'Reference to the INVOICE being paid';
COMMENT ON COLUMN PAYMENT.pay_date   IS 'Date the payment was received';
COMMENT ON COLUMN PAYMENT.pay_amount IS 'Amount received in this payment; an invoice may take several';
COMMENT ON COLUMN PAYMENT.pay_method IS 'Method: C = Cash, R = Card, T = Bank Transfer, Q = Cheque';
ALTER TABLE PAYMENT ADD CONSTRAINT invoice_payment_fk FOREIGN KEY (inv_no) REFERENCES INVOICE (inv_no);
ALTER TABLE PAYMENT ADD CONSTRAINT pay_method_chk CHECK (pay_method IN ('C', 'R', 'T', 'Q'));
ALTER TABLE PAYMENT ADD CONSTRAINT pay_amount_chk CHECK (pay_amount > 0);
ALTER TABLE PAYMENT ADD CONSTRAINT pay_no_fmt_chk CHECK (pay_no ~ '^PY[0-9]{4}$');

-- ── 6. Depends on EMPLOYEE ───────────────────────────────────────────────────

-- ATTENDANCE
DROP TABLE IF EXISTS ATTENDANCE CASCADE;
DROP SEQUENCE IF EXISTS attendance_seq CASCADE;
CREATE SEQUENCE attendance_seq;
CREATE TABLE ATTENDANCE (
    att_id      VARCHAR(6)  CONSTRAINT attendance_pk PRIMARY KEY
                            DEFAULT 'AT' || LPAD(NEXTVAL('attendance_seq')::TEXT, 4, '0'),
    emp_no      VARCHAR(6)  NOT NULL,
    clock_in    TIMESTAMP   NOT NULL,
    clock_out   TIMESTAMP,
    att_date    DATE        NOT NULL,
    total_hours NUMERIC(5, 2),
    created_at  TIMESTAMP   NOT NULL DEFAULT now()
);
ALTER SEQUENCE attendance_seq OWNED BY ATTENDANCE.att_id;
COMMENT ON COLUMN ATTENDANCE.att_id      IS 'Unique attendance record code — AT + 4 digits (e.g. AT0001)';
COMMENT ON COLUMN ATTENDANCE.emp_no      IS 'Reference to the EMPLOYEE clocking in/out';
COMMENT ON COLUMN ATTENDANCE.clock_in    IS 'Timestamp the employee clocked in';
COMMENT ON COLUMN ATTENDANCE.clock_out   IS 'Timestamp the employee clocked out; NULL until clock-out';
COMMENT ON COLUMN ATTENDANCE.att_date    IS 'Calendar date of the shift, for daily grouping/lookup';
COMMENT ON COLUMN ATTENDANCE.total_hours IS 'Hours worked; computed on clock-out';
ALTER TABLE ATTENDANCE ADD CONSTRAINT employee_attendance_fk FOREIGN KEY (emp_no) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE ATTENDANCE ADD CONSTRAINT attendance_id_fmt_chk CHECK (att_id ~ '^AT[0-9]{4}$');
ALTER TABLE ATTENDANCE ADD CONSTRAINT attendance_total_hours_chk CHECK (total_hours IS NULL OR total_hours >= 0);
