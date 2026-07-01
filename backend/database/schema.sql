-- =====================================================
-- File:        schema.sql
-- Purpose:     One-shot setup — runs all table migrations
--              for PrimeAutocare in dependency order
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

-- Run in dependency order so foreign key targets always exist first.

-- ── 1. No dependencies ───────────────────────────────────────────────────────
@migrations/employee.sql
@migrations/job.sql
@migrations/vehicle_owner.sql

-- ── 2. Depends on VEHICLE_OWNER ──────────────────────────────────────────────
@migrations/vehicle.sql

-- ── 3. Depends on VEHICLE ────────────────────────────────────────────────────
@migrations/vehicle_visit.sql

-- ── 4. Depends on VEHICLE_VISIT, JOB, and EMPLOYEE ──────────────────────────
@migrations/job_assignment.sql
