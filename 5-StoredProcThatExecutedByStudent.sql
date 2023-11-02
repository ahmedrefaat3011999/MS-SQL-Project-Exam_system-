------------------------------Student-----------------------
/*
1-Student Display The Exam just in its Time 
2- Student insert Answer to every question (just in exam time)
3- student can update or edit its answer on specific question(just in exam time) 
4-after finishing from exam and time of exam expired ,
student  can display its result in this Exam
*/


/* Student  Procedures
 1 -displayExamToThisStudent
 2-answerQuestionToSpecificExam
 3-updateAnswerQuestionToSpecificExam
 4-dispalyTheFinalResultOfMyExam
*/
/*Functions
 1 - getInfoAboutSpecificExam
*/

 -------------------Procedure to make Student to see his Exam in specific time----
ALTER Proc displayExamToThisStudent
@std_ssn char(14),
@ex_id int
AS
BEGIN TRY
		IF ((SELECT COUNT(*) FROM student_exam AS SC
		WHERE SC.ex_id =@ex_id AND SC.std_ssn=@std_ssn)=0
		)
			BEGIN
				SELECT 'This Student does not Selected to do this Exam' AS 'Error';
			END
										--2023-08-26---
		 ELSE IF((CONVERT(VARCHAR ,(SELECT ex_year FROM getInfoAboutSpecificExam (@ex_id)),112) = CONVERT(VARCHAR ,GETDATE(),112))
		  AND( (CONVERT(TIME ,GETDATE(),114) >= CONVERT(TIME ,(SELECT str_time FROM getInfoAboutSpecificExam (@ex_id)),114) 
		  AND (CONVERT(TIME ,GETDATE(),114) <= CONVERT(TIME ,(SELECT end_time FROM getInfoAboutSpecificExam (@ex_id)),114)))
		  )
		  )
			BEGIN 
				--display mcq exam questions --
				SELECT 
				EQ.ex_id as [Exam ID], Q.crs_code as [Course Code],
				Q.q_id as [Question ID] , Q.q_text as [Question text] ,
				Q.q_type as [Quetion Type] , Q.op_a as [Option A],
				Q.op_b as [Option B],Q.op_c as [Option C],Q.op_d as [Option D]
				FROM questions AS Q
				JOIN exam_questions AS EQ
				ON Q.q_id = EQ.q_id
				WHERE EQ.ex_id = @ex_id AND Q.q_type = 'mcq'
				--display t/f exam questions --
				SELECT EQ.ex_id as [Exam ID], Q.crs_code as [Course Code],
				Q.q_id as [Question ID] , Q.q_text as [Question text] ,
				Q.q_type as [Quetion Type] 
				FROM questions AS Q
				JOIN exam_questions AS EQ
				ON Q.q_id = EQ.q_id
				WHERE EQ.ex_id = @ex_id AND Q.q_type = 't/f'
				--display text exam questions --
				SELECT EQ.ex_id as [Exam ID], Q.crs_code as [Course Code],
				Q.q_id as [Question ID] , Q.q_text as [Question text] ,
				Q.q_type as [Quetion Type] 
				FROM questions AS Q
				JOIN exam_questions AS EQ
				ON Q.q_id = EQ.q_id
				WHERE EQ.ex_id = @ex_id AND Q.q_type = 'text'
			END
			ELSE 
			BEGIN
			    SELECT CONCAT('the Exam date in ',(SELECT ex_year FROM getInfoAboutSpecificExam (@ex_id)),
				' and its Start Time in ' ,CONVERT(TIME(7) ,(SELECT str_time FROM getInfoAboutSpecificExam (@ex_id)),108),
				' and its End Time in ' ,CONVERT(TIME(7) ,(SELECT end_time FROM getInfoAboutSpecificExam (@ex_id)),108)
				) AS 'Note'
			END
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH


displayExamToThisStudent @std_ssn = '456' , @ex_id=2


----------------sotred procedure for student to do answer exam ----------
--1-fIRST student must display the exam using this procedure displayExamToThisStudent 
--2-stdent must insert Exam ID , Question ID , Student SSN , Answer


ALTER PROCEDURE answerQuestionToSpecificExam
@ex_id int ,
@q_id int,
@std_ssn CHAR(14),
@std_answer varchar(100)
AS
BEGIN TRY
	DECLARE @Q_degree numeric(18,2);
	IF((SELECT COUNT(*) FROM exam_questions --check if this question exits in this exam
	WHERE q_id=@q_id AND ex_id=@ex_id)=0)    
		 BEGIN 
			print 'This Question does not exit in this exam!';
		 END
	 ELSE IF((SELECT COUNT(*) FROM student_exam AS SC
			WHERE SC.ex_id =@ex_id AND SC.std_ssn=@std_ssn)=0)
			BEGIN 
				PRINT 'This Student does not Selected to do this Exam';
			END
     ELSE IF((CONVERT(VARCHAR ,(SELECT ex_year FROM getInfoAboutSpecificExam (@ex_id)),112) = CONVERT(VARCHAR ,GETDATE(),112))
		  AND( (CONVERT(TIME ,GETDATE(),114) >= CONVERT(TIME ,(SELECT str_time FROM getInfoAboutSpecificExam (@ex_id)),114) 
		  AND (CONVERT(TIME ,GETDATE(),114) <= CONVERT(TIME ,(SELECT end_time FROM getInfoAboutSpecificExam (@ex_id)),114)))
		  ))
			BEGIN
				 IF(LOWER(@std_answer) =LOWER((SELECT Q.correct_ans FROM questions AS Q
									WHERE Q.q_id = @q_id)))
				 BEGIN
					  set @Q_degree = (SELECT EQ.q_degree FROM [dbo].[exam_questions] as EQ
									where EQ.ex_id=@ex_id and Eq.q_id=@q_id)
				END
				ELSE
					BEGIN 
						set @Q_degree =0.0;
					END

				INSERT INTO student_answers(ex_id,q_id,std_ssn,std_ans,degree)
				VALUES(@ex_id,@q_id,@std_ssn,@std_answer,@Q_degree);
				PRINT 'you have answered the question.'
			END
			ELSE 
			BEGIN
			    SELECT CONCAT('the Exam date in ',(SELECT ex_year FROM getInfoAboutSpecificExam (@ex_id)),
				' and its Start Time in ' ,CONVERT(varchar(8) ,(SELECT str_time FROM getInfoAboutSpecificExam (@ex_id)),108),
				' and its End Time in ' ,CONVERT(varchar(8) ,(SELECT end_time FROM getInfoAboutSpecificExam (@ex_id)),108)
				) AS 'Note'
			END
END TRY
BEGIN CATCH
	    SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH


-----------------------Function To return a Specific Exam Info by exam id-----

CREATE FUNCTION  getInfoAboutSpecificExam (@ex_id INT)
RETURNS TABLE
AS
  RETURN(
		SELECT * FROM exams WHERE ex_id=@ex_id
		);




	select * from getInfoAboutSpecificExam (2);



displayExamToThisStudent @std_ssn = '456' , @ex_id=2
answerQuestionToSpecificExam @ex_id= 2, @q_id=64,@std_ssn='456',@std_answer='TRUE'


--------------------------------------------------

ALTER PROCEDURE updateAnswerQuestionToSpecificExam
@ex_id int ,
@q_id int,
@std_ssn CHAR(14),
@new_std_answer varchar(100)
AS
BEGIN TRY
	DECLARE @Q_degree numeric(18,2);
	IF((SELECT COUNT(*) FROM exam_questions --check if this question exits in this exam
	WHERE q_id=@q_id AND ex_id=@ex_id)=0)    
		 BEGIN 
			print 'This Question does not exit in this exam!';
		 END
	 ELSE IF((SELECT COUNT(*) FROM student_exam AS SC
			WHERE SC.ex_id =@ex_id AND SC.std_ssn=@std_ssn)=0)
			BEGIN 
				PRINT 'This Student does not Selected to do this Exam';
			END
     ELSE IF((CONVERT(VARCHAR ,(SELECT ex_year FROM getInfoAboutSpecificExam (@ex_id)),112) = CONVERT(VARCHAR ,GETDATE(),112))
		  AND( (CONVERT(TIME ,GETDATE(),114) >= CONVERT(TIME ,(SELECT str_time FROM getInfoAboutSpecificExam (@ex_id)),114) 
		  AND (CONVERT(TIME ,GETDATE(),114) <= CONVERT(TIME ,(SELECT end_time FROM getInfoAboutSpecificExam (@ex_id)),114)))
		  ))
			BEGIN
				 IF(LOWER(@new_std_answer) =LOWER((SELECT Q.correct_ans FROM questions AS Q
									WHERE Q.q_id = @q_id)))
				 BEGIN
					  set @Q_degree = (SELECT EQ.q_degree FROM [dbo].[exam_questions] as EQ
									where EQ.ex_id=@ex_id and Eq.q_id=@q_id)
				END
				ELSE
					BEGIN 
						set @Q_degree =0.0;
					END

				UPDATE  student_answers SET degree=@Q_degree , std_ans =@new_std_answer 
				WHERE q_id= @q_id AND ex_id=@ex_id AND std_ssn= @std_ssn;
				PRINT 'you have Updated the answer of question.'
			END
			ELSE 
			BEGIN
			    SELECT CONCAT('the Exam date in ',(SELECT ex_year FROM getInfoAboutSpecificExam (@ex_id)),
				' and its Start Time in ' ,CONVERT(varchar(8) ,(SELECT str_time FROM getInfoAboutSpecificExam (@ex_id)),108),
				' and its End Time in ' ,CONVERT(varchar(8) ,(SELECT end_time FROM getInfoAboutSpecificExam (@ex_id)),108)
				) AS 'Note'
			END
END TRY
BEGIN CATCH
	    SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH

updateAnswerQuestionToSpecificExam @ex_id= 2, @q_id=65,@std_ssn='456',@new_std_answer='cascad style sheets'

----------Proc To display The Final result OF Exam to student -----
dispalyTheFinalResultOfMyExam @ex_id = 51 , @std_ssn='456'
ALTER PROC dispalyTheFinalResultOfMyExam
@ex_id int,
@std_ssn char(14)
AS
BEGIN TRY
	declare @std_deg numeric(18,2);
	declare @max_deg numeric(18,2);
	IF((SELECT COUNT(*) FROM student_exam AS SC
			WHERE SC.ex_id =@ex_id AND SC.std_ssn=@std_ssn)=0)
			BEGIN 
				PRINT 'you have not been selected to do this exam!';
			END
     ELSE IF((CONVERT(VARCHAR ,(SELECT ex_year FROM getInfoAboutSpecificExam (@ex_id)),112) = CONVERT(VARCHAR ,GETDATE(),112))
		  OR (CONVERT(TIME ,GETDATE(),114) >= CONVERT(TIME ,(SELECT end_time FROM getInfoAboutSpecificExam (@ex_id)),114)))
			BEGIN
				set @std_deg = (SELECT SUM(degree) FROM student_answers
				WHERE ex_id = @ex_id AND std_ssn =@std_ssn)
				set @max_deg =(SELECT max_deg FROM exams join courses
				on exams.crs_code = courses.crs_code
				WHERE exams.ex_id = @ex_id
				); 
				PRINT 'Your Degree Is '+ CAST(@std_deg AS NVARCHAR) + ' / ' +
				CAST(@max_deg AS NVARCHAR)
			END
END TRY 
BEGIN CATCH
		SELECT ERROR_MESSAGE() AS errorMessage;
END CATCH





