--------------------------Training Manager ------------------------>



----------------------AbdElwahab ----------------------------
CREATE PROCEDURE AddCourse
    @crs_code VARCHAR(25),
    @crs_name NVARCHAR(50),
    @crs_desc VARCHAR(MAX),
    @min_deg numeric(18, 0),
    @max_deg numeric(18, 0),
    @inst_ssn CHAR(14)
AS
BEGIN
    BEGIN TRY
        IF (ISNULL(@crs_code, '') = '' OR ISNULL(@crs_name, '') = '')
        BEGIN
            THROW 50030, 'Please provide course code and name!', 16;
        END
		 IF (EXISTS (SELECT 1 FROM [dbo].[courses] WHERE [inst_ssn] = @inst_ssn))
        BEGIN
            THROW 50033, 'Instructor is already teaching another course!', 16;
        END
        
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[instructors] WHERE [inst_ssn] = @inst_ssn))
        BEGIN
            THROW 50031, 'Instructor not found!', 16;
        END
		 IF (EXISTS (SELECT 1 FROM [dbo].[courses] WHERE [crs_code] = @crs_code))
        BEGIN
            THROW 50032, 'Course already exists!', 16;
        END
        
        INSERT INTO [dbo].[courses] ([crs_code], [crs_name], [crs_desc], [min_deg], [max_deg], [inst_ssn])
        VALUES (@crs_code, @crs_name, @crs_desc, @min_deg, @max_deg, @inst_ssn);
        
        PRINT 'Course added successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error ' + @ErrorMessage;
    END CATCH;
END;


CREATE PROCEDURE DeleteCourse
    @crs_code VARCHAR(25)
AS
BEGIN
    BEGIN TRY
        IF (ISNULL(@crs_code, '') = '')
        BEGIN
            THROW 50040, 'Please provide course code!', 16;
        END
        
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[courses] WHERE [crs_code] = @crs_code))
        BEGIN
            THROW 50041, 'Course not found!', 16;
        END
        
        DELETE FROM [dbo].[courses] WHERE [crs_code] = @crs_code;
        
        PRINT 'Course deleted successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error ' + @ErrorMessage;
    END CATCH;
END;


CREATE PROCEDURE UpdateCourse
    @crs_code VARCHAR(25),
    @NewCourseName VARCHAR(50),
    @NewCourseDesc VARCHAR(MAX),
    @NewMinDeg numeric(18, 0),
    @NewMaxDeg numeric(18, 0),
    @NewInstSsn CHAR(14)
AS
BEGIN
    BEGIN TRY
        IF (ISNULL(@crs_code, '') = '')
        BEGIN
            THROW 50050, 'Please provide course code!', 16;
        END
        
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[courses] WHERE [crs_code] = @crs_code))
        BEGIN
            THROW 50051, 'Course not found!', 16;
        END
        
        IF (ISNULL(@NewCourseName, '') = '')
        BEGIN
            THROW 50052, 'Please provide the new course name!', 16;
        END
        
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[instructors] WHERE [inst_ssn] = @NewInstSsn))
        BEGIN
            THROW 50053, 'Instructor not found!', 16;
        END
        
        UPDATE [dbo].[courses]
        SET [crs_name] = @NewCourseName,
            [crs_desc] = @NewCourseDesc,
            [min_deg] = @NewMinDeg,
            [max_deg] = @NewMaxDeg,
            [inst_ssn] = @NewInstSsn
        WHERE [crs_code] = @crs_code;
        
        PRINT 'Course updated successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error ' + @ErrorMessage;
    END CATCH;
END;

--------------
CREATE PROCEDURE Addinstructor
    @instssn CHAR(14),
    @Name VARCHAR(50),
    @Email VARCHAR(50),
    @Phone VARCHAR(11),
	@Adress VARCHAR(100),
    @Hiredate DATE
AS
BEGIN
    BEGIN TRY
        IF (ISNULL(@instssn, '') = '' OR ISNULL(@Name, '') = '')
        BEGIN
            THROW 50005, 'Please be sure to enter your ID number and name!', 16;
        END
        
        IF (ISNULL(@Phone, '') = '' OR LEN(@Phone) != 11)
        BEGIN
            THROW 50006, 'The phone number must be 11 digits long!', 16;
        END
        
        
        
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[instructors] WHERE [inst_ssn] = @instssn))
        BEGIN
            INSERT INTO [dbo].[instructors]([inst_ssn], [full_name], [email], [phone], [inst_address], [hire_date])
            VALUES (@instssn, @Name, @Email, @Phone, @Adress, @Hiredate);
            PRINT 'Instractor added successfully.';
        END
        ELSE
        BEGIN
            THROW 50008, 'Instractor is already there.', 16;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error ' + @ErrorMessage;
    END CATCH;
END;

EXEC Addinst11 '111', '', NULL, '12345718901', '123 Main St', '2023-08-25';

CREATE PROCEDURE UpdateInstructor
    @instssn CHAR(14),
    @NewName VARCHAR(50),
    @NewEmail VARCHAR(50),
    @NewPhone VARCHAR(11),
	@NewAddress VARCHAR(100),
    @NewHiredate DATE
AS
BEGIN
    BEGIN TRY
        IF (ISNULL(@instssn, '') = '')
        BEGIN
            THROW 50010, 'Please provide the instructor ID!', 16;
        END
        
        IF (ISNULL(@NewName, '') = '')
        BEGIN
            THROW 50011, 'Please provide the new name!', 16;
        END
        
        IF (ISNULL(@NewPhone, '') = '' OR LEN(@NewPhone) != 11)
        BEGIN
            THROW 50012, 'The new phone number must be 11 digits long!', 16;
        END
        
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[instructors] WHERE [inst_ssn] = @instssn))
        BEGIN
            THROW 50013, 'Instructor not found!', 16;
        END
        
        UPDATE [dbo].[instructors]
        SET [full_name] = @NewName,
            [email] = @NewEmail,
            [phone] = @NewPhone,
            [inst_address] = @NewAddress,
            [hire_date] = @NewHiredate
        WHERE [inst_ssn] = @instssn;
        
        PRINT 'Instructor updated successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error ' + @ErrorMessage;
    END CATCH;
END;

CREATE PROCEDURE DeleteInstructor
    @instssn CHAR(14)
AS
BEGIN
    BEGIN TRY
        IF (ISNULL(@instssn, '') = '')
        BEGIN
            THROW 50020, 'Please provide the instructor ID!', 16;
        END
        
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[instructors] WHERE [inst_ssn] = @instssn))
        BEGIN
            THROW 50021, 'Instructor not found!', 16;
        END
        
        DELETE FROM [dbo].[instructors] WHERE [inst_ssn] = @instssn;
        
        PRINT 'Instructor deleted successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error ' + @ErrorMessage;
    END CATCH;
END;
-------------------------
CREATE PROCEDURE UpdateInstructorForCourse
    @inst_ssn CHAR(14),
    @crs_code VARCHAR(25),
    @new_inst_ssn CHAR(14)
AS
BEGIN
    BEGIN TRY
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[instructors] WHERE [inst_ssn] = @new_inst_ssn))
        BEGIN
            THROW 50071, 'New instructor not found!', 16;
        END
        
        IF (NOT EXISTS (SELECT 1 FROM [dbo].[courses] WHERE [crs_code] = @crs_code))
        BEGIN
            THROW 50072, 'Course not found!', 16;
        END
        
        UPDATE [dbo].[courses]
        SET [inst_ssn] = @new_inst_ssn
        WHERE  [crs_code] = @crs_code;
        
        PRINT 'Instructor for course updated successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'Error ' + @ErrorMessage;
    END CATCH;
END;
----------------------------searching----------------
SearchCourses 'CSS1'
CREATE PROCEDURE SearchCourses
    @search_term NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        DECLARE @ResultsCount INT;

        SELECT
            [crs_code],
            [crs_name],
            [crs_desc],
            [min_deg],
            [max_deg],
            [inst_ssn]
        FROM
            [dbo].[courses]
        WHERE
            [crs_code] LIKE '%' + @search_term + '%' OR
            [crs_name] LIKE '%' + @search_term + '%' OR
            [crs_desc] LIKE '%' + @search_term + '%';

        SET @ResultsCount = @@ROWCOUNT;

        IF @ResultsCount = 0
        BEGIN
            PRINT 'No courses found No students found please valid id,name or email .';
        END
    END TRY
    BEGIN CATCH
       
    END CATCH;
END;

CREATE PROCEDURE SearchStudents
    @search_term NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        DECLARE @ResultsCount INT;

        SELECT
            [std_ssn],
            [full_name],
            [std_email]

        FROM
            [dbo].[students]
        WHERE
            [std_ssn] LIKE '%' + @search_term + '%' OR
            [full_name] LIKE '%' + @search_term + '%' OR
            [std_email] LIKE '%' + @search_term + '%';

        SET @ResultsCount = @@ROWCOUNT;

        IF @ResultsCount = 0
        BEGIN
            PRINT 'No students found please valid id,name or email .';
        END
    END TRY
    BEGIN CATCH
    END CATCH;
END;


SearchCourses @search_term = 'Cs';


-----------------------Ahmed Refaat Code --------------------

-- create new intakes  BY manager

alter procedure add_new_intake (@round_num int ,
@str_date date,
@end_date date , 
@dep_name varchar(100) , 
@track_name varchar(100) ,
@branche_name varchar(100))
as	
begin
if exists (select 1 from dbo.intakes where round_num = @round_num)
begin
	
print 'This intake is Already exists'
end
else 
insert into dbo.intakes (round_num,str_date,end_date,dep_name,track_name,branch_name)
values (@round_num, @str_date , @end_date , @dep_name  , @track_name , @branche_name )
end

exec add_new_intake  6,'10/10/2023','10/10/2023','cs','FULL_STACK USING .NET','cairo'

--delete intake

create procedure delete_intake (@round_num int )
as
begin 

	delete from dbo.intakes where round_num=@round_num
end

exec delete_intake 5


--update intakes information

create procedure update_intake_info 
					(@round_num int ,
					@str_date date,
					@end_date date ,
					@dep_name varchar(100) ,
					@track_name varchar(100) ,
					@branch_name varchar(100))
as
begin
	if exists (select 1 from dbo.intakes where round_num=@round_num )
		begin
			update dbo.intakes  
			set str_date=@str_date,
				end_date=@end_date,
				dep_name=@dep_name,
				track_name=@track_name,
				branch_name=@branch_name
			where round_num=@round_num 
		end
	else  print 'this round number is not found'
end

exec update_intake_info  2,'10/10/2023','10/10/2023','cs','FULL_STACK USING .NET','cairo'



--add student 
alter procedure AddStudent (@std_ssn char(14) , @str_email varchar(50), @full_name varchar(50) , @std_phone char(11) , @std_address varchar(100) ,@round_num int)
as	
begin
if exists( select 1 from dbo.students where  std_ssn=@std_ssn)
begin
	print 'this student is Already exist'
end
else 
begin 
	insert into dbo.students (std_ssn, std_email,full_name,std_phone,std_address,round_num)
	values (@std_ssn  , @str_email , @full_name , @std_phone , @std_address  ,@round_num)
end
end

exec AddStudent  1125463,'ahmedrefaa99@gmail.com','ahmed refaat','01140651558','cairo',1

--delete student

CREATE procedure delete_student 
	@std_ssn char(14)
as
begin
	IF EXISTS (select 1 from dbo.students where std_ssn =@std_ssn )
	BEGIN
			DELETE FROM dbo.students WHERE std_ssn =@std_ssn	
	END
	
	ELSE 
	BEGIN
	PRINT 'THIS student is  NOT FOUNT'
	END
	
end

exec delete_student 2


--update student information 

create procedure update_student_info (@std_ssn char(14) , @std_email varchar(50), @full_name varchar(50) , @std_phone char(11) , @std_address varchar(100) ,@round_num int)
	
as
begin
	if exists (select 1 from dbo.students where std_ssn =@std_ssn)
	begin 
	if exists (select 1 from dbo.intakes where round_num =@round_num)
	begin
		update dbo.students 
		set std_email=@std_email,
			full_name=@full_name,
			std_phone=@std_phone,
			std_address=@std_address,
			round_num=@round_num
		where std_ssn =@std_ssn
	end
	else 
	begin 
		print 'this round number is not found'
	end
	end
	else
	print 'this student is not found'

end

exec update_student_info  1125463,'ahmed@gmail.com','ahmed refaat','01140651558','cairo',1


--add branches

alter  PROCEDURE ADD_BRANCHES(@branch_name as varchar(100) , @inst_ssn as char(14))
as 
begin 
if  exists (select 1 from dbo.branches where branch_name =@branch_name)
begin
	print 'This Branch is Already exists'
end
else
begin 
	INSERT INTO dbo.branches(branch_name, inst_ssn)
	VALUES (@branch_name ,@inst_ssn );
end
end

exec ADD_BRANCHES 'alex' , '123'  


--delete branche

create procedure delete_branch  @branch_name varchar(100)
as
begin
	IF EXISTS (select 1 from dbo.branches where branch_name =@branch_name )
	BEGIN
			DELETE FROM dbo.branches WHERE branch_name=@branch_name	
	END
	
	ELSE 
	BEGIN
	PRINT 'THIS branch is  NOT FOUNT'
	END
	
end

exec delete_branch 'alex'


--update branch information 
create procedure update_branch_info(@branch_name  varchar(100) , @inst_ssn  char(14) ,@new_branch_name varchar(100)  ,@new_inst_ssn  char(14))
	
as
begin
	if exists (select 2 from dbo.branches where branch_name =@branch_name and inst_ssn=@inst_ssn)
	begin 
		update dbo.branches  
		set branch_name=@new_branch_name,
		inst_ssn=@new_inst_ssn
		where branch_name =@branch_name and inst_ssn=@inst_ssn
	end
	else
	begin
	print 'this branch is not found'
	end
end

exec update_branch_info 'alex ',123,'aswan' ,1234


--add trackes

alter  PROCEDURE ADD_TRACKS(@TRACK_name as varchar(100))
as 
begin 
if  exists(select 1 from dbo.Tracks where track_name=@TRACK_name)
begin
	print 'this track is Already found'
end
else 
begin 
INSERT INTO dbo.Tracks(track_name)
VALUES (@TRACK_name );
end
end

exec ADD_TRACKS  'mobile application' 


--delete tracks

create procedure delete_track @track_name varchar(100)
as
begin
	IF EXISTS (select 1 from dbo.Tracks where track_name =@track_name )
	BEGIN
			DELETE FROM dbo.Tracks WHERE track_name=@track_name	
	END
	
	ELSE 
	BEGIN
	PRINT 'THIS track is  NOT FOUNT'
	END
	
end

exec delete_track 'mobile application'


--update tracks

create procedure update_track_info(@old_track_name as varchar(100),@new_track_name as varchar(100))
	
as
begin
	if exists (select 1 from dbo.tracks where track_name=@old_track_name)
	begin 
		update dbo.Tracks  
		set  track_name =@new_track_name
		where track_name=@old_track_name	
	end
	else
	begin
	print 'this track is not found'
	end
end

exec update_track_info  'FULL_STACK USING .NET1' ,'mobile application'


--add departments

alter  PROCEDURE ADD_DEPARTMENT(@DEPARTMENT_NAME as varchar(100))
as 
begin 
IF EXISTS (select 1 from dbo.Departments where dep_name =@DEPARTMENT_NAME )
begin 
	print 'this department is already found'
end
else 
begin
INSERT INTO dbo.Departments(dep_name)
VALUES (@DEPARTMENT_NAME );
end
end
exec ADD_DEPARTMENT  'ds' 


--delete departments

create procedure delete_department @DEPARTMENT_NAME varchar(100)
as
begin
	IF EXISTS (select 1 from dbo.Departments where dep_name =@DEPARTMENT_NAME )
	BEGIN
			DELETE FROM dbo.Departments WHERE dep_name=@DEPARTMENT_NAME	
	END
	
	ELSE 
	BEGIN
	PRINT 'THIS department is  NOT FOUNT'
	END
	
end

exec delete_department 'ds'



--update departments

create procedure update_department_info(@old_department_name  varchar(100) ,@new_department_name varchar(100))
as
begin
	if exists (select 1 from dbo.Departments where dep_name=@old_department_name)
	begin 
		update dbo.Departments 
		set  dep_name =@new_department_name
		where dep_name=@old_department_name	
	end
	else
	begin
	print 'this track is not found'
	end
end


exec update_department_info 'css'  ,'database'
