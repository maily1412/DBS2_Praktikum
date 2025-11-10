REM   	Script Name: 	Hr_main1.SQL
REM   	Purpose:    	To create users and initialise scripts that create schema objects.
REM	Created by:	Nagavalli Pataballa on 16-MAR-2001
REM   	Updated by: 	Lauran K. Serhal on 20-JUL-2007

--Please modify the path based on the location of the scripts.  
SET ECHO ON

@hr_cre.sql
@hr_popul.sql
@hr_idx.sql
@hr_code.sql
@hr_comnt.sql
@dis_trigger.sql
commit;



