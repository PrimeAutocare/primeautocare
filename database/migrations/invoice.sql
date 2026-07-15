-- =====================================================
-- File:        invoice.sql
-- Purpose:     Creates the INVOICE table for PrimeAutocare
-- Depends on:  VEHICLE_VISIT
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

-- One bill per workshop visit: the customer collects the vehicle and settles
-- the total of the completed jobs on that visit.
DROP TABLE IF EXISTS INVOICE CASCADE;
DROP SEQUENCE IF EXISTS invoice_seq CASCADE;
CREATE SEQUENCE invoice_seq;
CREATE TABLE INVOICE (
    inv_no     VARCHAR(6)    CONSTRAINT invoice_pk PRIMARY KEY
                             DEFAULT 'IN' || LPAD(NEXTVAL('invoice_seq')::TEXT, 4, '0'),
    visit_id   VARCHAR(6)    NOT NULL,
    inv_date   DATE          NOT NULL,
    inv_total  NUMERIC(10, 2) NOT NULL,
    inv_status CHAR(1)       NOT NULL
);
ALTER SEQUENCE invoice_seq OWNED BY INVOICE.inv_no;
COMMENT ON COLUMN INVOICE.inv_no     IS 'Unique invoice code — IN + 4 digits (e.g. IN0001)';
COMMENT ON COLUMN INVOICE.visit_id   IS 'Reference to the VEHICLE_VISIT being billed; one invoice per visit';
COMMENT ON COLUMN INVOICE.inv_date   IS 'Date the invoice was raised';
COMMENT ON COLUMN INVOICE.inv_total  IS 'Total billed — sum of completed JOB_ASSIGNMENT costs on the visit';
COMMENT ON COLUMN INVOICE.inv_status IS 'Status: U = Unpaid, P = Partially paid, S = Settled, V = Void';
ALTER TABLE INVOICE ADD CONSTRAINT vehicle_visit_invoice_fk FOREIGN KEY (visit_id) REFERENCES VEHICLE_VISIT (visit_id);
ALTER TABLE INVOICE ADD CONSTRAINT inv_visit_uq UNIQUE (visit_id);
ALTER TABLE INVOICE ADD CONSTRAINT inv_status_chk CHECK (inv_status IN ('U', 'P', 'S', 'V'));
ALTER TABLE INVOICE ADD CONSTRAINT inv_total_chk CHECK (inv_total >= 0);
ALTER TABLE INVOICE ADD CONSTRAINT inv_no_fmt_chk CHECK (inv_no ~ '^IN[0-9]{4}$');
