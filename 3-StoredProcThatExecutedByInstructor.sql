---------------Stored Procedure ------operation that instructor can do ---
use examination_system;
------1------------------Instructors Generates an Exam with Rondom question From questions pool------------------

ALTER PROCEDURE generateExamByInstructor
@type char(10), ----type Exam (exam , corrective)
@year date, ----------------(Date of an exam)
@str_time time(7), ----------Start time--------
@end_time time(7), ----------End time--------
@total_time numeric(5,2), --------total time of Exam ---------
@inst_ssn char(14),    -----------Instructor SSN ---------
@round_num int,       ------------intake round number -----
@crs_code varchar(25),   ----------Course Code ------------
@mcq_num int, @mcq_deg numeric(5,2),          --------Number of MCQ quesstions ----
@tf_num int, @tf_deg numeric(5,2),      --------Number of t/f quesstions ----
@text_num int , @text_deg numeric(5,2)        --------Number of text quesstions ----
AS
BEGIN TRY 
		DECLARE @InsertedExamId TABLE (ID INT)

		IF NOT EXISTS(SELECT * FROM courses where crs_code = @crs_code)
			BEGIN 
					SELECT 'This course does not exist' AS 'Error'; 
			END
		ELSE IF NOT EXISTS(SELECT * FROM courses where inst_ssn = @inst_ssn)
			BEGIN 
					SELECT 'This instructor does not  teach this corse' AS 'Error'; 
			END
		ELSE IF NOT EXISTS(SELECT * FROM intakes where round_num = @round_num)
			BEGIN 
					SELECT 'This intake does not exist' AS 'Error'; 
			END
		ELSE
			BEGIN 
				IF(dbo.checkIfTotalQuestionsDegreesEqualMaxDegreeOfCourse(@mcq_num,
				@mcq_deg,@tf_num,@tf_deg,@text_num,@text_deg)=
				(SELECT max_deg FROM courses WHERE crs_code=@crs_Code))
					BEGIN
							----------insert info about exam
							 INSERT INTO exams(ex_type,ex_year,str_time,end_time,
							total_time,inst_ssn,round_num,crs_code)
							OUTPUT INSERTED.ex_id INTO @InsertedExamId
							VALUES(@type,@year,@str_time,@end_time,@total_time,
							@inst_ssn,@round_num,@crs_code);


							----------select mcq Question from Questions pool .....>
							------related to course and insert into this exam----
							-------------insert mcq question ---------
							INSERT INTO exam_questions(q_id,ex_id,q_degree) 
							SELECT TOP(@mcq_num) Qus.q_id ,(SELECT ID from @InsertedExamId), @mcq_deg
							FROM questions AS Qus
							WHERE qus.crs_code = @crs_code AND qus.q_type = 'mcq'
							ORDER BY NEWID();

							-------------insert T/F question ---------
							INSERT INTO exam_questions(q_id,ex_id,q_degree) 
							SELECT TOP(@tf_num) Qus.q_id ,(SELECT ID from @InsertedExamId) ,@tf_deg 
							FROM questions AS Qus
							WHERE qus.crs_code = @crs_code AND qus.q_type = 't/f'
							ORDER BY NEWID();
							-------------insert text question ---------
							INSERT INTO exam_questions(q_id,ex_id,q_degree) 
							SELECT TOP(@text_num) Qus.q_id ,(SELECT ID from @InsertedExamId),@text_deg  
							FROM questions AS Qus
							WHERE qus.crs_code = @crs_code AND qus.q_type = 'text'
							ORDER BY NEWID();
							SELECT 'You generated Exam Successfully For This Course '+@crs_code AS 'Success Message'; 
					END
					ELSE
						BEGIN 
							SELECT 'The total degree of questions not Equal max Degree for this course ' AS 'Error'; 
						END
			
			END
END TRY

BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH
-----------------------call generateExamByInstructor-----------------
generateExamByInstructor @type='exam' , @year='2023-08-31',
@str_time='03:30:00',@end_time='10:30:00',
@total_time=2.00,@inst_ssn='123',
@round_num=1,@crs_code='CSS101',
@mcq_num=2,@mcq_deg=25.0,
@tf_num=2,@tf_deg =25.0,
@text_num=0,@text_deg=0.0



----------------Function to compute the total degree of Questions----->
ALTER FUNCTION checkIfTotalQuestionsDegreesEqualMaxDegreeOfCourse(
@mcq_num int,
@mcq_deg numeric(5,2),       
@tf_num int, @tf_deg numeric(5,2),     
@text_num int,@text_deg numeric(5,2) 
)
RETURNS NUMERIC(5,2)
AS
BEGIN
    DECLARE @result NUMERIC(5,2)
    SET @result = (@mcq_num * @mcq_deg) +(@tf_num*@tf_deg)+(@text_num*@text_deg);
	
	RETURN @result;
END

select dbo.checkIfTotalQuestionsDegreesEqualMaxDegreeOfCourse(2,25,2,25,0,0)



-----2---Instructor Create The Basics Info About Exam ------>
ALTER PROCEDURE CreateExamWithBasicInfo
@type char(10), ----type Exam 
@year date, ----------------(Date of an exam)
@str_time time(7), ----------Start time--------
@end_time time(7),    ----------End time--------
@total_time numeric(2,1), --------total time of Exam -----
@inst_ssn char(14),      -----------Instructor SSN ---------
@round_num int,          ------intake round number -----
@crs_code varchar(25)   ------Course Code ----
As
BEGIN TRY 
	   IF NOT EXISTS(SELECT * FROM courses where crs_code = @crs_code)
			BEGIN 
					SELECT 'This course does not exist' AS 'Error'; 
			END
		ELSE IF NOT EXISTS(SELECT * FROM courses where inst_ssn = @inst_ssn)
			BEGIN 
					SELECT 'This instructor does not  teach this corse' AS 'Error'; 
			END
		ELSE IF NOT EXISTS(SELECT * FROM intakes where round_num = @round_num)
			BEGIN 
					SELECT 'This intake does not exist' AS 'Error'; 
			END
		ELSE
			BEGIN
			----------insert info about exam
			 INSERT INTO exams(ex_type,ex_year,str_time,end_time,
			 total_time,inst_ssn,round_num,crs_code)
			VALUES(@type,@year,@str_time,@end_time,@total_time,
			@inst_ssn,@round_num,@crs_code);
			END
END TRY

BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH

--Rename the stored procedure.  
EXEC sp_rename 'CreateExamByselectingQuestionManually', 'CreateExamWithBasicInfo';


CreateExamWithBasicInfo @type='exam' , @year='2023-09-25',
@str_time='09:00:00',@end_time='12:00:00',
@total_time=2.00,@inst_ssn='123',
@round_num=1,@crs_code='CSS101';




-------3-------Instructor Proc to display all exam for his course teach-->
ALTER PROCEDURE displayAllExamForCourseThatInstructorTeach
@inst_ssn char(14)
as
BEGIN TRY
	SELECT exams.ex_id as [Exam Id] ,exams.ex_year as [Exam Date] FROM exams left join courses
	on exams.inst_ssn = courses.inst_ssn
	where exams.inst_ssn =@inst_ssn
END TRY

BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH

displayAllExamForCourseThatInstructorTeach @inst_ssn = '123';

------4--------Instructor Proc to display all Questions for his course teach-->
CREATE PROCEDURE displayAllQuestionsForCourseThatInstructorTeach
@inst_ssn char(14)
as
BEGIN TRY
	SELECT Q.q_id as [Question Id], Q.q_text  as [Question Text] ,Q.q_type as [Type] 
	FROM questions AS Q left join courses AS C
	on Q.[crs_code] = C.[crs_code] left join instructors AS I
	on C.inst_ssn=I.inst_ssn
	where I.inst_ssn =@inst_ssn
END TRY

BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH

displayAllQuestionsForCourseThatInstructorTeach @inst_ssn = '123';



-------5---------Proc Selecting the Exam and its Questions one by one --->
CREATE PROC SelectingQuestionToOneByOneExamManually
@ex_id int , ---Exam ID ---
@q_id int , ------Question ID ----
@q_degree numeric(2,1)   -----Question Degree -----
AS
BEGIN TRY
  --***-check if this question and exam belong to the same course -***--
	IF((SELECT COUNT(*) FROM exams AS E 
	left join questions AS Q on E.[crs_code] = Q.[crs_code]
	where E.ex_id =@ex_id AND Q.q_id=@q_id) > 0 
	)
	BEGIN
		INSERT INTO exam_questions(q_id,ex_id,q_degree)
		VALUES(@q_id,@ex_id,@q_degree)
	END
	ELSE
	   BEGIN 
			SELECT 'This question  does not belong to this corse' AS 'Error'; 
	   END
END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH

SelectingQuestionToOneByOneExamManually @ex_id =3 , @q_id=65 ,@q_degree=5 

-----***-------Instructor Select Spececfiec Student to do an Exam----***-----

--- 1 -instructor display his Exams for his coure to get Exam ID --------
displayAllExamForCourseThatInstructorTeach @inst_ssn = '123';
--- 2 -instructor display all students that Enrolled in his course  that he teach
------------------6-----------------------
CREATE PROCEDURE displayAllStudentThatEnrrolledInSpecCourse
@crs_code varchar(25)
AS 
BEGIN TRY 
		IF EXISTS (SELECT 1 FROM courses where crs_code =@crs_code)
		   BEGIN
				SELECT S.std_ssn AS [Student SSN] , S.full_name AS [Name]
				FROM students AS S left join student_courses AS SC
				ON SC.[std_ssn] = S.[std_ssn]
				WHERE SC.crs_code = @crs_code
		   END
		ELSE
		BEGIN
			SELECT 'This course does not exist' AS 'Error'; 
		END
END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH

displayAllStudentThatEnrrolledInSpecCourse @crs_code='CSS101'
--- 3 - instructor SELECT specifc student to do an exam -----7-- 
ALTER PROC selectSpecificStudentToDoExam
@ex_id int,
@std_ssn char(14),
@inst_ssn char(14)
AS
BEGIN TRY
		IF NOT EXISTS (SELECT COUNT(*) FROM exams 
		where inst_ssn =@inst_ssn AND ex_id =@ex_id)
			BEGIN 
				SELECT 'This instructor does not  teach this corse' AS 'Error'; 
			END
		ELSE IF NOT EXISTS(SELECT COUNT(*) FROM exams E
				JOIN [dbo].[student_courses] AS SC
				ON E.crs_code = SC.crs_code
				WHERE SC.[std_ssn] =@std_ssn AND E.ex_id=@ex_id
				)
			BEGIN
				SELECT 'Student and exam do not belong to the same course' AS 'Error'; 
			END
		ELSE
			BEGIN
				INSERT INTO student_exam(ex_id,std_ssn,inst_ssn)
				VALUES(@ex_id,@std_ssn,@inst_ssn)
				SELECT 'You selected student to exam Successfully' AS 'Success'; 
			END

END TRY
BEGIN CATCH
			SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH

selectSpecificStudentToDoExam @ex_id ='',@std_ssn='' ,@inst_ssn='';

--------------Delete Specific Exam By Istructor Course ------
---First all Exam For his Course , then pick exam id and delete the exam 
---8
ALTER PROC deleteExamByCourseInstructor
@ex_id int , 
@inst_ssn char(14)
AS
BEGIN TRY
	IF NOT EXISTS (SELECT COUNT(*) FROM exams 
		where inst_ssn =@inst_ssn AND ex_id =@ex_id)
			BEGIN 
				SELECT 'This instructor does not teach this corse ,
				then not allow to delete this exam' AS 'Error'; 
			END
	ELSE
		BEGIN 
			delete from exams where ex_id = @ex_id
		END

END TRY
BEGIN CATCH
			SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH


deleteExamByCourseInstructor @ex_id=12 , @inst_ssn='123456'

--------9----------DisplayResultOfAllStudentInCourse --By intructor -----------
displayResultOfAllStudentINSpecificExam @crs_code='CSS101', @inst_ssn='123', @ex_id=2

ALTER PROC displayResultOfAllStudentINSpecificExam
@crs_code varchar(25),
@inst_ssn char(14),
@ex_id int
AS
BEGIN TRY
	IF NOT EXISTS(SELECT * FROM courses where crs_code = @crs_code)
			BEGIN 
					SELECT 'This course does not exist' AS 'Error'; 
			END
		ELSE IF NOT EXISTS(SELECT * FROM courses where inst_ssn = @inst_ssn)
			BEGIN 
					SELECT 'This instructor does not  teach this corse' AS 'Error'; 
			END
		ELSE
			BEGIN
				SELECT S.full_name as[Full Name] , SUM(SA.degree)as [Student degree],@crs_code as [Course Code]  
				FROM student_answers SA
				LEFT JOIN students S
				ON SA.std_ssn = S.std_ssn
				where ex_id=@ex_id
				GROUP BY S.full_name
			END
END TRY
BEGIN CATCH
			SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH

----------------------------ahmed refaat code----
create procedure add_question_To_pool
	(@q_id int ,
	@q_text varchar(max),
	@crs_code varchar(25),
	@q_type varchar(5),
	@correct_ans varchar(100),
	@op_a varchar(100) ,
	@op_b varchar(100),
	@op_c varchar(100) ,
	@op_d varchar(100))

AS
begin try
	IF EXISTS (SELECT 1 FROM dbo.questions WHERE [q_id]= @q_id OR [q_text]=@q_text )
	BEGIN
	PRINT 'This question has been entered previously'
	END
	
	ELSE 
	BEGIN
	insert into dbo.questions (q_id,q_text,crs_code,q_type,correct_ans,op_a,op_b,op_c,op_d)
	values (@q_id , @q_text , @crs_code , @q_type , @correct_ans , @op_a , @op_b , @op_c,@op_d)
	END
end try
begin catch
    SELECT ERROR_MESSAGE() AS errorMessage;
end catch

EXEC add_question_To_pool 1,'In which ocean GC?Bermuda TriangleGC? region is located? '
						,'geo02','mcq','Atlantic','Atlantic','Indian','America','Arctic'






CREATE PROCEDURE Ubdate_Question
    (@q_id int ,
	@q_text varchar(max),
	@crs_code varchar(25),
	@q_type varchar(5),
	@correct_ans varchar(100),
	@op_a varchar(100),
	@op_b varchar(100),
	@op_c varchar(100),
	@op_d varchar(100))

AS
BEGIN try
        IF  EXISTS (SELECT 1 FROM dbo.questions WHERE q_id= @q_id )
        BEGIN
		UPDATE dbo.questions
        SET q_text=@q_text,
			crs_code=@crs_code,
			q_type=@q_type,
			correct_ans=@correct_ans,
			op_a=@op_a,
			op_b=@op_b,
			op_c=@op_c,
			op_d=@op_d
		WHERE q_id= @q_id
		END
		ELSE
        BEGIN
            PRINT 'this question is not found'
        END
end try
begin catch
    SELECT ERROR_MESSAGE() AS errorMessage;
end catch

exec Ubdate_Question  2,'Which one is the smallest ocean in the world? ','geo02',
						'mcq' ,'Arctic','Indian','Pacific','Atlantic','Arctic'




CREATE procedure delete_question 
	@q_id INT 
as
begin try
 	IF EXISTS (select 1 from dbo.questions where [q_id] =@q_id )
	BEGIN
			DELETE FROM dbo.questions WHERE q_id =@q_id	
	END
	
	ELSE 
	BEGIN
	PRINT 'THIS QUESTION NOT FOUNT'
	END
end try
begin catch
    SELECT ERROR_MESSAGE() AS errorMessage;
end catch


EXEC delete_question 200