-- =====================================================
-- File:        employee.sql
-- Purpose:     Creates the EMPLOYEE table for PrimeAutocare
-- Depends on:  (none)
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE IF EXISTS EMPLOYEE CASCADE;
 
CREATE TABLE EMPLOYEE (
    emp_no        INTEGER      CONSTRAINT employee_pk PRIMARY KEY,
    emp_gname     VARCHAR(15)  NOT NULL,
    emp_fname     VARCHAR(15)  NOT NULL,
    emp_phone     VARCHAR(13)  NOT NULL,
    emp_email     VARCHAR(30)  NOT NULL,
    emp_passhash  VARCHAR(30)  NOT NULL,
    emp_role      CHAR(1)      NOT NULL,
    emp_create_dt DATE         NOT NULL
);
 
COMMENT ON COLUMN EMPLOYEE.emp_no        IS 'Unique employee number';
COMMENT ON COLUMN EMPLOYEE.emp_gname     IS 'Employee given (first) name';
COMMENT ON COLUMN EMPLOYEE.emp_fname     IS 'Employee family (last) name';
COMMENT ON COLUMN EMPLOYEE.emp_phone     IS 'Contact number — format: +94112233445';
COMMENT ON COLUMN EMPLOYEE.emp_email     IS 'Work email address; must be unique across all employees';
COMMENT ON COLUMN EMPLOYEE.emp_passhash  IS 'Hashed password for system login';
COMMENT ON COLUMN EMPLOYEE.emp_role      IS 'Role code: A = Admin, S = Supervisor, T = Technician';
COMMENT ON COLUMN EMPLOYEE.emp_create_dt IS 'Date the employee account was created in the system';
 
ALTER TABLE EMPLOYEE
    ADD CONSTRAINT emp_email_uq UNIQUE (emp_email);
 
ALTER TABLE EMPLOYEE
    ADD CONSTRAINT emp_role_chk CHECK (emp_role IN ('A', 'S', 'T'));
 