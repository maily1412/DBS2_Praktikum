//Aufgabe 1
//Geben Sie eine Liste der Mitarbeiter aus, die $1500 verdienen.

db.emp.find({sal: 1500});
// Ausgabe:
//{ "_id" : ObjectId("694129da12bf142f0d710089"), "empno" : "7844", "ename" : "TURNER", "job" : "SALESMAN", "mgr" : "7698", "hiredate" : "08-SEP-81", "sal" : 1500, "comm" : "0", "dept" : "SALES" }

//Aufgabe 2
//Geben Sie eine Liste der Mitarbeiternamen aus, die mehr als $2500 und weniger als $2900 verdienen.

db.emp.find({sal: 
    {$gt: 2500, 
    $lt: 2900}});

// Ausgabe:
//{ "_id" : ObjectId("69412cb4190a2bb484ce3982"), "empno" : "7698", "ename" : "BLAKE", "job" : "MANAGER", "mgr" : "7839", "hiredate" : "01-MAY-81", "sal" : 2850, "dept" : "SALES" }

//Aufgabe 3
//Fügen Sie folgenden Mitarbeiter in die Datenbank ein:
//Name: John Doe
//Gehalt: $3100
//Job: Verkäufer
//Qualifikation: Ausbildung

db.emp.insert({
    ename: "John Doe",
    sal: 3100,
    job: "Verkäufer",
    qualifikation: "Ausbildung"
});
// Ausgabe:
//WriteResult({ "nInserted" : 1 })

//Aufgabe 4
//Aktualisieren Sie das Gehalt vom Mitarbeiter King auf $5300.

db.emp.update(
    {ename: "KING"},
     {$set: {sal: 5300}}
);

// Ausgabe:
//WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

//Aufgabe 5
//Geben Sie eine Liste der Mitarbeiter mit Ihren kompletten Abteilungsdaten aus, die mehr als $1000 verdienen

db.emp.aggregate([
  {$match: {sal: {$gt: 1000}}},
  {$lookup: {
    from: "dept",
    localField: "deptno",
    foreignField: "deptno",
    as: "department"
  }}
]);

// Ausgabe:
//{ "_id" : ObjectId("69412cb4190a2bb484ce397e"), "empno" : "7499", "ename" : "ALLEN", "job" : "SALESMAN", "mgr" : "7698", "hiredate" : "20-FEB-81", "sal" : 1600, "comm" : "300", "dept" : "SALES", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce397f"), "empno" : "7521", "ename" : "WARD", "job" : "SALESMAN", "mgr" : "7698", "hiredate" : "22-FEB-81", "sal" : 1250, "comm" : "500", "dept" : "SALES", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3980"), "empno" : "7566", "ename" : "JONES", "job" : "MANAGER", "mgr" : "7839", "hiredate" : "02-APR-81", "sal" : 2975, "dept" : "RESEARCH", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3981"), "empno" : "7654", "ename" : "MARTIN", "job" : "SALESMAN", "mgr" : "7698", "hiredate" : "28-SEP-81", "sal" : 1250, "comm" : "1400", "dept" : "SALES", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3982"), "empno" : "7698", "ename" : "BLAKE", "job" : "MANAGER", "mgr" : "7839", "hiredate" : "01-MAY-81", "sal" : 2850, "dept" : "SALES", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3983"), "empno" : "7782", "ename" : "CLARK", "job" : "MANAGER", "mgr" : "7839", "hiredate" : "09-JUN-81", "sal" : 2450, "dept" : "ACCOUNTING", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3984"), "empno" : "7788", "ename" : "SCOTT", "job" : "ANALYST", "mgr" : "7566", "hiredate" : "09-DEC-82", "sal" : 3000, "dept" : "RESEARCH", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3985"), "empno" : "7839", "ename" : "KING", "job" : "PRESIDENT", "hiredate" : "17-NOV-81", "sal" : 5300, "dept" : "ACCOUNTING", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3986"), "empno" : "7844", "ename" : "TURNER", "job" : "SALESMAN", "mgr" : "7698", "hiredate" : "08-SEP-81", "sal" : 1500, "comm" : "0", "dept" : "SALES", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3987"), "empno" : "7876", "ename" : "ADAMS", "job" : "CLERK", "mgr" : "7788", "hiredate" : "12-JAN-83", "sal" : 1100, "dept" : "RESEARCH", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce3989"), "empno" : "7902", "ename" : "FORD", "job" : "ANALYST", "mgr" : "7566", "hiredate": "03-DEC-81", "sal" : 3000, "dept" : "RESEARCH", "department" : [ ] }
//{ "_id" : ObjectId("69412cb4190a2bb484ce398a"), "empno" : "7934", "ename" : "MILLER", "job" : "CLERK", "mgr" : "7782", "hiredate": "23-JAN-82", "sal" : 1300, "dept" : "ACCOUNTING", "department" : [ ] }
//{ "_id" : ObjectId("69412e17190a2bb484ce398f"), "ename" : "John Doe", "sal" : 3100, "job" : "Verkäufer", "qualifikation" : "Ausbildung", "department" : [ ] }