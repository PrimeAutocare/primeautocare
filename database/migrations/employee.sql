-- =====================================================
-- File:        employee.sql
-- Purpose:     Creates the EMPLOYEE table for PrimeAutocare
-- Depends on:  (none)
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

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
    emp_create_dt DATE         NOT NULL,
    emp_hourly_rate NUMERIC(7, 2) NOT NULL
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
COMMENT ON COLUMN EMPLOYEE.emp_hourly_rate IS 'Pay rate per hour worked; basis for payroll reporting';
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_email_uq UNIQUE (emp_email);
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_role_chk CHECK (emp_role IN ('A', 'S', 'T'));
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_no_fmt_chk CHECK (emp_no ~ '^EM[0-9]{4}$');
ALTER TABLE EMPLOYEE ADD CONSTRAINT emp_hourly_rate_chk CHECK (emp_hourly_rate >= 0);
