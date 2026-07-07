-- =====================================================
-- File:        test_data.sql
-- Purpose:     Test data for the database
-- Author:      Senuka Wijerathna
-- Created:     2026-07-07
-- =====================================================

-- IDs are NOT specified — Postgres assigns them automatically starting at 1.

-- EMPLOYEE
INSERT INTO EMPLOYEE (emp_gname, emp_fname, emp_phone, emp_email, emp_passhash, emp_role, emp_create_dt)
VALUES ('Kasun', 'ABCD', '+94771234567', 'kasun@primeautocare.com', 'placeholder_hash', 'A', '2026-07-01');

-- JOB
INSERT INTO JOB (job_desc) VALUES ('Oil Change');
INSERT INTO JOB (job_desc) VALUES ('Brake Inspection');

-- VEHICLE_OWNER
INSERT INTO VEHICLE_OWNER (owner_name, owner_phone, owner_email)
VALUES ('Kusan Perera', '+94771112233', 'kusan@example.com');

INSERT INTO VEHICLE_OWNER (owner_name, owner_phone, owner_email)
VALUES ('Nilu Fernando', '+94772223344', 'nilu@example.com');

-- VEHICLE (owner_no 1 = Kusan, owner_no 2 = Nilu)
INSERT INTO VEHICLE (owner_no, vehi_license, vehi_make, vehi_model, vehi_year)
VALUES (1, 'CAB-1234', 'Toyota', 'Corolla', 2019);

INSERT INTO VEHICLE (owner_no, vehi_license, vehi_make, vehi_model, vehi_year)
VALUES (2, 'CAR-5678', 'Honda', 'Civic', 2021);

-- VEHICLE_VISIT (vehi_id 1 = Corolla, vehi_id 2 = Civic)
INSERT INTO VEHICLE_VISIT (vehi_id, visit_check_in_dt, visit_check_out_dt, visit_status)
VALUES (1, '2026-07-01', NULL, 'I');

INSERT INTO VEHICLE_VISIT (vehi_id, visit_check_in_dt, visit_check_out_dt, visit_status)
VALUES (2, '2026-07-03', '2026-07-04', 'O');

-- JOB_ASSIGNMENT (visit_id 1 = Corolla visit, visit_id 2 = Civic visit; job_no 1 = Oil Change, 2 = Brake Inspection; emp_no 1 = Inuka)
INSERT INTO JOB_ASSIGNMENT (visit_id, job_no, jobassign_assigned_by, jobassign_assign_dt, jobassign_start_dt, jobassign_complete_dt, jobassign_status, jobassign_cost, jobassign_notes)
VALUES (1, 1, 1, '2026-07-01', '2026-07-01', NULL, 'I', NULL, 'Customer requested full synthetic oil');

INSERT INTO JOB_ASSIGNMENT (visit_id, job_no, jobassign_assigned_by, jobassign_assign_dt, jobassign_start_dt, jobassign_complete_dt, jobassign_status, jobassign_cost, jobassign_notes)
VALUES (2, 2, 1, '2026-07-03', '2026-07-03', '2026-07-04', 'C', 4500.00, 'Front brake pads replaced');