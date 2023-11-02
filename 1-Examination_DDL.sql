
--------------------- DDL --------------------------->
----------------------------  Create DataBse ------------>
create database examination_system;
---------use the database-------------
use examination_system;

-----file groups -------


ALTER DATABASE examination_system
ADD FILEGROUP FG1;
GO
ALTER DATABASE examination_system
ADD FILEGROUP FG2;
GO

ALTER DATABASE examination_system
ADD FILEGROUP FG3;
--------create file in FG1 ---------------
ALTER DATABASE examination_system 
ADD FILE 
(
    NAME = examfile1,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\examfile1.ndf',
    SIZE = 30MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 5MB
),
(
    NAME = examfile2,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\examfile2.ndf',
    SIZE = 20MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP FG1;

--------------------create file in FG2 -----------------
ALTER DATABASE examination_system 
ADD FILE 
(
    NAME = examfile3,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\examfile3.ndf',
    SIZE = 30MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 5MB
),
(
    NAME = examfile4,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\examfile4.ndf',
    SIZE = 20MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP FG2;

-------------------create files in FG3--------------
ALTER DATABASE examination_system 
ADD FILE 
(
    NAME = examfile5,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\examfile5.ndf',
    SIZE = 30MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 5MB
),
(
    NAME = examfile6,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\examfile6.ndf',
    SIZE = 20MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)
TO FILEGROUP FG3;
--------------------Create tables --------------------------->
create table Departments(
dep_name varchar(100) not null primary key
);

-------
create table Tracks(
track_name varchar(100) not null primary key
);
-------
create table instructors(
	inst_ssn char(14) not null primary key ,
	full_name nvarchar(50) not null ,
	email varchar(50) unique ,
	phone varchar(11) ,
	inst_address varchar(100),
	hire_date date ,
	branch_name varchar(100) not null
); 
---------
create table branches(
branch_name varchar(100) not null,
inst_ssn char(14) not null references instructors(inst_ssn),
constraint inst_manage_branch primary key (branch_name,inst_ssn) 
);
--------------create table to works_for Realtionship---------------


create table works_for(
branch_name varchar(100) not null references branches(branch_name),
inst_ssn char(14) not null  references instructors(inst_ssn),
constraint inst_worksfor_branch primary key (branch_name,inst_ssn)
);

---------------------Intake-----
create table intakes(
round_num int not null primary key,
str_date date ,
end_date date,
dep_name varchar(100) not null references Departments(dep_name) , 
track_name varchar(100) not null references Tracks(track_name)  , 
branch_name varchar(100) not null references branches(branch_name)
)


------------------   Questions   -------------------------
create table questions(
q_id int not null primary key identity,
q_type char(5) not null,
crs_code varchar(20) not null,
q_text varchar(max) not null ,
correct_ans varchar(100) not null,
op_a varchar(100) ,
op_b varchar(100),
op_c varchar(100),
op_d varchar(100)
);
--------Alter add check constraints -------------------
alter table questions
Add constraint check_Quest_type  check (q_type in ('mcq' ,'t/f' , 'text'))
-----------------alter to add foregn key constraints----
alter table questions
add constraint FK_question_course foreign key(crs_code) references courses(crs_code)

---------------------Exam table --------
create table exams(
ex_id int not null primary key identity(1,1),
ex_type char(10) not null check (ex_type in ('exam' , 'corrective')),
ex_year date ,
str_time datetime,
end_time datetime,
total_time decimal(2,2),
inst_ssn char(14) not null references instructors(inst_ssn),
round_num int not null references intakes(round_num)
);
-----------------------courses table -----------
create table courses(
crs_code varchar(20) not null primary key,
crs_name varchar(50) not null unique,
crs_desc varchar(max) ,
min_deg numeric not null,
max_deg numeric not null,
inst_ssn char(14) not null references instructors(inst_ssn)
);
------------------Students table----------------
create table students(
std_ssn char(14) not null primary key,
std_email varchar(50) unique,
full_name varchar(50) not null,
std_phone char(11) not null check(LEN(std_phone)=11),
std_address varchar(100),
round_num int not null references intakes(round_num)
);
--------------------------students courses--------------->
create table student_courses(
std_ssn  char(14) not null references students(std_ssn),
crs_code varchar(20) not null references courses(crs_code)
constraint stdSSN_crsCODE primary key(std_ssn , crs_code)
);

-----------------student Answers-------------
create table student_answers(
ex_id int references exams(ex_id),
q_id   int references questions(q_id),
std_ssn char(14)references students(std_ssn),
std_ans varchar(100),
degree numeric DEFAULT 0,
constraint exID_qID_stdSSN primary key(ex_id,q_id,std_ssn)
);


--------------------------QuestionExamCourses---------Relationship-----------
create table question_exam_course(
q_id   int references questions(q_id),
ex_id int references exams(ex_id),
crs_code varchar(20) not null references courses(crs_code),
constraint qID_exID primary key(q_id, ex_id)
);


---------------------select Student to Exam table(Relationship)------
create table  student_exam(
ex_id int references exams(ex_id),
std_ssn char(14) not null references students(std_ssn),
inst_ssn char(14) not null references instructors(inst_ssn),
constraint exID_stdSSN_instSSN primary key(ex_id,std_ssn)
);



-------------Move tables to other file group -----------
------------------move Tracks table to FG1 ----------

CREATE UNIQUE CLUSTERED INDEX [PK__Tracks__7BE54951114D707D]
ON dbo.Tracks([track_name])
WITH (DROP_EXISTING = ON)
ON FG1;
------------------move branch table to FG1 ----------
CREATE UNIQUE CLUSTERED INDEX [PK_branches_1]
ON [dbo].[branches]([branch_name])
WITH (DROP_EXISTING = ON)
ON FG1;


------------------move departments table to FG1 ----------
CREATE UNIQUE CLUSTERED INDEX [PK__Departme__7BE5495159823B52]
ON [dbo].[Departments]([dep_name])
WITH (DROP_EXISTING = ON)
ON FG1;


------------------move exams table to FG2 ----------
CREATE UNIQUE CLUSTERED INDEX [PK__exams__F6D3E4893FE844E6]
ON [dbo].[exams]([ex_id])
WITH (DROP_EXISTING = ON)
ON FG2;


------------------move worksFor table to FG2 ----------
CREATE UNIQUE CLUSTERED INDEX [inst_worksfor_branch]
ON [dbo].[works_for](branch_name,inst_ssn)
WITH (DROP_EXISTING = ON)
ON FG2;


------------------move Question table to FG3 ----------
CREATE UNIQUE CLUSTERED INDEX [PK__question__3D59B310FC87E2C3]
ON [dbo].[questions]([q_id])
WITH (DROP_EXISTING = ON)
ON FG3;


------------------move Question table to FG3 ----------
CREATE UNIQUE CLUSTERED INDEX [PK__question__3D59B310FC87E2C3]
ON [dbo].[questions]([q_id])
WITH (DROP_EXISTING = ON)
ON FG3;

------------------move Student Courses table to FG3 ----------
CREATE UNIQUE CLUSTERED INDEX [stdSSN_crsCODE]
ON [dbo].[student_courses]([std_ssn],[crs_code])
WITH (DROP_EXISTING = ON)
ON FG3;




