drop table emp_account;

create table emp_account (
  employee_id NUMBER,
  iban VARCHAR(28)
);
                                 
insert into emp_account values (198, 'DE87648045234485030332');
insert into emp_account values (199, 'DE89370400440532013000');
insert into emp_account values (200, 'DE87648045234485030332');
insert into emp_account values (201, 'DE08700901001234467890');
insert into emp_account values (202, 'DE73500105175749995145');
insert into emp_account values (203, 'DE64500105179932457894');
insert into emp_account values (204, 'DE47500105172371723845');
insert into emp_account values (205, 'DE25500105176825282913');
insert into emp_account values (206, 'DE71500105173839853139');
insert into emp_account values (101, 'DE19500105171414233372');
insert into emp_account values (102, 'DE70502702940475714235');
insert into emp_account values (103, 'DE05897254850420485858');
insert into emp_account values (104, 'DE88547760555786844532');
insert into emp_account values (105, 'DE40370613041566552776');
insert into emp_account values (106, 'DE29974969917403954322');

commit;