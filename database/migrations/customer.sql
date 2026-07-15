-- =====================================================
-- File:        customer.sql
-- Purpose:     Creates the CUSTOMER table for PrimeAutocare
-- Depends on:  (none)
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

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
