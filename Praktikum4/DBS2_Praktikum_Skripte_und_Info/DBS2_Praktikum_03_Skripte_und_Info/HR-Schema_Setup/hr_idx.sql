Rem
Rem 	$Header: hr_idx.sql 03-mar-2001.10:05:15 ahunold Exp $
Rem
Rem 	hr_idx.sql
Rem
Rem  	Copyright (c) Oracle Corporation 2007. All Rights Reserved.
Rem
Rem    	SCRIPT NAME: 	hr_idx.sql
Rem    	DESCRIPTION:  	Creates indexes for the HR schema.
Rem
Rem
Rem    	NOTES
Rem
Rem
Rem    	CREATED by: 	Nancy Greenberg on 01-JUN-2000
Rem    	Updated by: 
Rem	- ahunold on 20-FEB-2001 - New header
Rem    	- vpatabal on 02-MAR-2001 - Removed DROP INDEX statements
Rem    	- Chaitanya Koratamaddi on 05-FEB-2006
Rem	- Lauran K. Serhal on 20-JUL-2007

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO ON 

CREATE INDEX emp_department_ix
       ON employees (department_id);

CREATE INDEX emp_job_ix
       ON employees (job_id);

CREATE INDEX emp_manager_ix
       ON employees (manager_id);

CREATE INDEX emp_name_ix
       ON employees (last_name, first_name);

CREATE INDEX dept_location_ix
       ON departments (location_id);

CREATE INDEX jhist_job_ix
       ON job_history (job_id);

CREATE INDEX jhist_employee_ix
       ON job_history (employee_id);

CREATE INDEX jhist_department_ix
       ON job_history (department_id);

CREATE INDEX loc_city_ix
       ON locations (city);

CREATE INDEX loc_state_province_ix	
       ON locations (state_province);

CREATE INDEX loc_country_ix
       ON locations (country_id);

COMMIT;

