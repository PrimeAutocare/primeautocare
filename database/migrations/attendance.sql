-- =====================================================
-- File:        attendance.sql
-- Purpose:     Creates the ATTENDANCE table for PrimeAutocare
-- Depends on:  EMPLOYEE
-- Author:      Senuka Wijerathna
-- Created:     2026-07-23
-- =====================================================

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
