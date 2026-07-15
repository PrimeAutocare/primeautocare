-- =====================================================
-- File:        payment.sql
-- Purpose:     Creates the PAYMENT table for PrimeAutocare
-- Depends on:  INVOICE
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

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
