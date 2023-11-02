
---------use the database-------------
use examination_system;

-------T/F---bulk command to inserting data into quesTions table---

BULK INSERT questions
FROM 'C:\Users\dell\Desktop\MS SQL Project\questions-tf.csv'
WITH(
FIELDTERMINATOR = ',',
ROWTERMINATOR ='\n'
);

--------------MCQ----------------bulk command to inserting data into quesTions table-

BULK INSERT questions
FROM 'C:\Users\dell\Desktop\MS SQL Project\questions.csv'
WITH(
FIELDTERMINATOR = ',',
ROWTERMINATOR ='\n'
);

--------------Text----------------bulk command to inserting data into quesTions table-

BULK INSERT questions
FROM 'C:\Users\dell\Desktop\MS SQL Project\textQuestion.csv'
WITH(
FIELDTERMINATOR = ',',
ROWTERMINATOR ='\n'
);


