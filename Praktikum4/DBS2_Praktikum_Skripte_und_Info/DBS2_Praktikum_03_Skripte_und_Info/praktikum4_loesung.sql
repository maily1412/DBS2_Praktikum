
-- Aufgabe 1
-- Höchste Abteilungsnummer ermitteln
DECLARE
  v_max_deptno NUMBER;
BEGIN 
    SELECT MAX(department_id)
    INTO v_max_deptno
    FROM departments;

    DBMS_OUTPUT.PUT_LINE('Die höchste Abteilungsnummer ist: ' || v_max_deptno);
END;