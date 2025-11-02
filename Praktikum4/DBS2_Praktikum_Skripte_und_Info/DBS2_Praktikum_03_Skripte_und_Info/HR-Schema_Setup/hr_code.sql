Rem
Rem 	$Header: hr_code.sql 03-mar-2001.10:05:12 ahunold Exp $
Rem
Rem 	hr_code.sql
Rem
Rem  	Copyright (c) Oracle Corporation 2007. All Rights Reserved.
Rem
Rem    	Script Name: 	hr_code.sql
Rem	Description: 	- Creates procedural objects for the HR schema
Rem     		- Creates a statement level trigger on EMPLOYEES
Rem     		  to allow DML during business hours.
Rem     		- Creates a row level trigger on the EMPLOYEES table,
Rem     		  after UPDATES on the department_id or job_id columns.
Rem     		- Creates a stored procedure to insert a row into the
Rem     		  JOB_HISTORY table. Have the above row level trigger
Rem     		  row level trigger call this stored procedure. 
Rem
Rem
Rem    	Created by:	Nancy Greenberg on 01-JUN-2000
Rem	Updated by:
Rem    	- ahunold on 03-MAR-2001, HR simplification, REGIONS table
Rem    	- ahunold on 20-FEB-2001
Rem    	- Chaitanya Koratamaddi on 05-FEB-2006
Rem	- Lauran K. Serhal on 20-JUL-2007 - Reformatted the script.

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO ON

REM **************************************************************************

REM procedure and statement trigger to allow dmls during business hours:
CREATE OR REPLACE PROCEDURE secure_dml
IS
BEGIN
  IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
        OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
	RAISE_APPLICATION_ERROR (-20205, 
		'You may only make changes during normal office hours');
  END IF;
END secure_dml;
/

CREATE OR REPLACE TRIGGER secure_employees
  BEFORE INSERT OR UPDATE OR DELETE ON employees
BEGIN
  secure_dml;
END secure_employees;
/

REM **************************************************************************
REM procedure to add a row to the JOB_HISTORY table and row trigger 
REM to call the procedure when data is updated in the job_id or 
REM department_id columns in the EMPLOYEES table:

CREATE OR REPLACE PROCEDURE add_job_history
  (  p_emp_id          job_history.employee_id%type
   , p_start_date      job_history.start_date%type
   , p_end_date        job_history.end_date%type
   , p_job_id          job_history.job_id%type
   , p_department_id   job_history.department_id%type 
   )
IS
BEGIN
  INSERT INTO job_history (employee_id, start_date, end_date, 
                           job_id, department_id)
    VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END add_job_history;
/

CREATE OR REPLACE TRIGGER update_job_history
  AFTER UPDATE OF job_id, department_id ON employees
  FOR EACH ROW
BEGIN
  add_job_history(:old.employee_id, :old.hire_date, sysdate, 
                  :old.job_id, :old.department_id);
END;
/

COMMIT;

