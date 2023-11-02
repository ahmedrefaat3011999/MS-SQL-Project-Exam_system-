use examination_system;


------------View To Display all Instructor---------

ِAlter VIEW displayAllInstructors
AS
	SELECT [inst_ssn] as [Instructor SSN],
	[full_name] as [Full Name],
    [email] as [Email],
	[phone] as [Phone],
	[inst_address] as [Address],
	[hire_date] as [Hire Date] 
	FROM instructors

select * from displayAllInstructors;

------------View To Display all Students---------

CREATE VIEW displayAllStudents
WITH ENCRYPTION
AS
	SELECT [std_ssn]as [Student SSN],
	[full_name] as [Full Name],
    [std_email] as [Email],
	[std_phone] as [Phone],
	[std_address] as [Address],
	[round_num] as [Round Number] 
	FROM students
	with check option;

select * from displayAllStudents;


-------------------triggers -----------on deleting or inerting Student -------
create table students_audit(
std_ssn char(14) not null primary key,
std_email varchar(50) unique,
full_name varchar(50) not null,
std_phone char(11) not null check(LEN(std_phone)=11),
std_address varchar(100),
round_num int not null references intakes(round_num),
updated_at DATETIME NOT NULL,
operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL')
);
select * from students_audit;

ALTER TRIGGER trg_student_audit
ON [dbo].[students]
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO students_audit(
        std_ssn,
		std_email,
		full_name,
		std_phone,
		std_address,
		round_num,
        updated_at, 
        operation
    )
    SELECT
        i.std_ssn,
		i.std_email,
		i.full_name,
		i.std_phone,
		i.std_address,
		i.round_num,
        GETDATE(),
        'INS'
    FROM
        inserted i
    UNION ALL
    SELECT
		d.std_ssn,
		d.std_email,
		d.full_name,
		d.std_phone,
		d.std_address,
		d.round_num,
		GETDATE(),
        'DEL'
    FROM
        deleted d;
END



-------------------triggers -----------on  inerting Exam -------

CREATE table exams_audit(
ex_id int not null primary key ,
ex_type char(10) not null check (ex_type in ('exam' , 'corrective')),
ex_year date ,
str_time datetime,
end_time datetime,
total_time numeric(18,2),
inst_ssn char(14) not null references instructors(inst_ssn),
round_num int not null references intakes(round_num),
crs_code varchar(25) not null,
updated_at DATETIME NOT NULL,
operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS')
);

drop table exams_audit
ALTER TRIGGER trg_exam_audit
ON [dbo].[exams]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO exams_audit(
	ex_id,
	[ex_type],
	[ex_year],
	[str_time],
	[end_time],
	[total_time],
	[inst_ssn],[round_num],
	[crs_code],updated_at,operation
	)
	SELECT 
	i.ex_id,
	i.ex_type,
	i.ex_year,
	i.str_time,
	i.end_time,
	i.total_time,
	i.inst_ssn,
	i.round_num,
	i.crs_code,
	GETDATE(),
      'INS' 
	FROM 
	inserted i
End