CREATE DATABASE challenge;
USE challenge;
CREATE TABLE Companies (
    CompanyID INT PRIMARY KEY,            
    CompanyName VARCHAR(255) NOT NULL,  
    Company_Location VARCHAR(255) NOT NULL);
INSERT INTO Companies VALUES (1, 'Tech Innovators', 'San Francisco, CA');
INSERT INTO Companies VALUES (2, 'Global Solutions', 'New York, NY');
INSERT INTO Companies VALUES (3, 'Creative Minds', 'Los Angeles, CA');
select*from Companies;
CREATE TABLE Jobs (
    JobID INT PRIMARY KEY,                  
    CompanyID INT,                          
    JobTitle VARCHAR(255) NOT NULL,          
    JobDescription TEXT NOT NULL,            
    JobLocation VARCHAR(255) NOT NULL,      
    Salary DECIMAL(10, 2),                   
    JobType VARCHAR(50) NOT NULL,            
    PostedDate DATETIME DEFAULT CURRENT_TIMESTAMP,  
    FOREIGN KEY (CompanyID) REFERENCES Companies(CompanyID) );
INSERT INTO Jobs VALUES (1, 1, 'Software Engineer', 'Develop and maintain web applications.', 'San Francisco, CA', 200000.00, 'Full-time', '2024-10-01 10:00:00');
INSERT INTO Jobs VALUES (2, 2, 'Data Scientist', 'Analyze large datasets and build predictive models.', 'New York, NY', 215000.00, 'Full-time', '2024-10-05 12:30:00');
INSERT INTO Jobs VALUES (3, 3, 'Graphic Designer', 'Create visual designs for marketing materials.', 'Los Angeles, CA', 75000.00, 'Part-time', '2024-10-07 09:00:00');
select*from Jobs;
CREATE TABLE Applicants (
    ApplicantID INT PRIMARY KEY,          
    FirstName VARCHAR(255) NOT NULL,       
    LastName VARCHAR(255) NOT NULL,        
    Email VARCHAR(255) NOT NULL,           
    Phone VARCHAR(20),                     
    Resume TEXT);
INSERT INTO Applicants VALUES (1, 'Johnny', 'deep', 'johnny.deep@example.com', '123-456-7890', 'Experienced software developer with expertise in web technologies.');
INSERT INTO Applicants VALUES(2, 'James', 'gosling', 'james.gosling@example.com', '987-654-3210', 'Data analyst with 2 years of experience in machine learning.');
INSERT INTO Applicants VALUES(3, 'Adom', 'Johns', 'adom.johns@example.com', '555-123-4567', 'Ui/Ux designer with expertise in  Illustrator.');
select*from Applicants; 
CREATE TABLE Applications (
    ApplicationID INT PRIMARY KEY,           
    JobID INT,                              
    ApplicantID INT,                         
    ApplicationDate DATETIME DEFAULT CURRENT_TIMESTAMP, 
    CoverLetter TEXT,
    FOREIGN KEY (ApplicantID) REFERENCES Applicants(ApplicantID) );
INSERT INTO Applications VALUES(1, 1, 1, DEFAULT, 'I am a software engineer with 5 years of experience. I am excited to apply for the Software Engineer position.');
INSERT INTO Applications VALUES(2, 2, 2, DEFAULT, 'As a data scientist, I have a deep understanding of machine learning and statistical analysis. I am very interested in applying for this role.');
select*from Applications;
---4. Ensure the script handles potential errors, such as if the database or tables already exist.
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'challenge')
BEGIN
    CREATE DATABASE challenge ;
END

---5. Write an SQL query to count the number of applications received for each job listing in the "Jobs" table. Display the job title and the corresponding application count. Ensure that it lists all jobs, even if they have no applications.
SELECT 
    Jobs.JobTitle,                       
    COUNT(Applications.ApplicationID) AS ApplicationCount  
FROM 
    Jobs
LEFT JOIN 
    Applications ON Jobs.JobID = Applications.JobID  
GROUP BY 
    Jobs.JobID, Jobs.JobTitle; 
---6. Develop an SQL query that retrieves job listings from the "Jobs" table within a specified salary
---range. Allow parameters for the minimum and maximum salary values. Display the job title,
---company name, location, and salary for each matching job.
DECLARE @min_salary DECIMAL(10, 2) = 50000; 
DECLARE @max_salary DECIMAL(10, 2) = 150000; 
SELECT
Jobs.JobTitle,              
    Companies.CompanyName,     
    Jobs.JobLocation,       
    Jobs.Salary FROM Jobs JOIN 
   Companies ON Jobs.CompanyID = Companies.CompanyID  
WHERE Jobs.Salary BETWEEN @min_salary AND @max_salary; 
---7. Write an SQL query that retrieves the job application history for a specific applicant. Allow a
---parameter for the ApplicantID, and return a result set with the job titles, company names, and
---application dates for all the jobs the applicant has applied to.
DECLARE @ApplicantID INT = 1; 
SELECT Jobs.JobTitle, Companies.CompanyName,Applications.ApplicationDate 
FROM Applications
JOIN Jobs ON Applications.JobID = Jobs.JobID  
JOIN Companies ON Jobs.CompanyID = Companies.CompanyID
WHERE  Applications.ApplicantID = @ApplicantID; 
---8. Create an SQL query that calculates and displays the average salary offered by all companies for
---job listings in the "Jobs" table. Ensure that the query filters out jobs with a salary of zero.
SELECT AVG(Salary) AS AverageSalary   
FROM Jobs
WHERE Salary > 0; 
---9. Write an SQL query to identify the company that has posted the most job listings. Display the
---company name along with the count of job listings they have posted. Handle ties if multiple
---companies have the same maximum count.
WITH JobCount AS (
    SELECT Companies.CompanyName,COUNT(Jobs.JobID) AS JobCount    
    FROM Jobs
    JOIN Companies ON Jobs.CompanyID = Companies.CompanyID  
    GROUP BY Companies.CompanyName             
)
SELECT CompanyName,JobCount
FROM JobCount
WHERE JobCount = (SELECT MAX(JobCount) FROM JobCount);
---10. Find the applicants who have applied for positions in companies located in 'CityX' and have at least 3 years of experience.
ALTER TABLE Applications
ADD YearsofExperience INT;
UPDATE Applications
SET YearsofExperience=5 WHERE ApplicantID=1;
SELECT 
    a.FirstName,            
    a.LastName,             
    a.Email,                
    a.Phone, 
	a.YearsofExperience,
    a.Resume                
FROM 
    Applicants a
JOIN 
    Applications app ON a.ApplicantID = app.ApplicantID  
JOIN 
    Jobs j ON app.JobID = j.JobID
JOIN 
    Companies c ON j.CompanyID = c.CompanyID
WHERE 
    c.Company_Location = 'CityX'  
    AND a.YearsofExperience >= 3;
	SELECT * from Applications
---11. Retrieve a list of distinct job titles with salaries between $60,000 and $80,000.
SELECT DISTINCT JobTitle       
FROM Jobs            
WHERE Salary BETWEEN 60000 AND 80000;
---12. Find the jobs that have not received any applications.
SELECT *FROM Jobs j
LEFT JOIN 
    Applications a ON j.JobID = a.JobID
WHERE 
    a.ApplicationID IS NULL;
---13. Retrieve a list of job applicants along with the companies they have applied to and the positions they have applied for.
SELECT a.FirstName,           
    a.LastName,             
    a.Email,               
    c.CompanyName,          
    j.JobTitle FROM 
    Applicants a
JOIN 
    Applications app ON a.ApplicantID = app.ApplicantID   
JOIN 
    Jobs j ON app.JobID = j.JobID                       
JOIN 
    Companies c ON j.CompanyID = c.CompanyID              
ORDER BY 
    a.LastName, a.FirstName; 
---14. Retrieve a list of companies along with the count of jobs they have posted, even if they have not received any applications.
SELECT 
    c.CompanyName,
    COUNT(j.JobID) AS JobCount
FROM 
    Companies c
LEFT JOIN 
    Jobs j ON c.CompanyID = j.CompanyID
GROUP BY 
    c.CompanyName
ORDER BY 
    JobCount DESC;
---15. List all applicants along with the companies and positions they have applied for, including those who have not applied.
SELECT 
    a.FirstName,
    a.LastName,
    a.Email,
    COALESCE(c.CompanyName, 'No Applications') AS CompanyName,
    COALESCE(j.JobTitle, 'No Position Applied') AS JobTitle
FROM 
    Applicants a
LEFT JOIN 
    Applications app ON a.ApplicantID = app.ApplicantID
LEFT JOIN 
    Jobs j ON app.JobID = j.JobID
LEFT JOIN 
    Companies c ON j.CompanyID = c.CompanyID 
ORDER BY 
    a.LastName, a.FirstName;   
---16. Find companies that have posted jobs with a salary higher than the average salary of all jobs.
SELECT 
    c.CompanyName,           
    j.JobTitle, 
    j.Salary  
	FROM 
    Jobs j
JOIN 
    Companies c ON j.CompanyID = c.CompanyID    
WHERE 
    j.Salary > (SELECT AVG(Salary) FROM Jobs WHERE Salary > 0) 
ORDER BY 
    j.Salary DESC
---17. Display a list of applicants with their names and a concatenated string of their city and state.
SELECT A.ApplicantID, A. FirstName, A.LastName,

CONCAT(J.jobtitle, 'and', J.jobLocation) AS JobLocation

FROM Applicants A

LEFT JOIN Applications Ap ON A.ApplicantID =Ap.ApplicantID

LEFT JOIN Jobs J ON Ap. JobID = J.JobID;

---18. Retrieve a list of jobs with titles containing either 'Developer' or 'Engineer'.
SELECT 
    JobID,                  
    JobTitle
          
FROM 
    Jobs
WHERE 
    JobTitle LIKE '%Developer%'    
    OR JobTitle LIKE '%Engineer%'  
ORDER BY 
    JobTitle;   
---19. Retrieve a list of applicants and the jobs they have applied for, including those who have not applied and jobs without applicants.
SELECT 
    a.ApplicantID,           
    a.FirstName,
    a.LastName,
    a.Email,
    COALESCE(j.JobTitle, 'No Position Applied') AS JobTitle, 
    COALESCE(c.CompanyName, 'No Company') AS CompanyName 
FROM 
    Applicants a
LEFT JOIN 
    Applications app ON a.ApplicantID = app.ApplicantID   
LEFT JOIN 
    Jobs j ON app.JobID = j.JobID 
LEFT JOIN 
    Companies c ON j.CompanyID = c.CompanyID  
ORDER BY 
    a.LastName, a.FirstName;   
---20. List all combinations of applicants and companies where the company is in a specific city and the applicant has more than 2 years of experience. For example: city=Chennai
SELECT 
    a.ApplicantID,          
    a.FirstName,
    a.LastName,
    a.Email, 
    c.CompanyName,            
    c.Company_Location AS Company_Location                
FROM 
    Applicants a
JOIN 
    Companies c ON c.Company_Location = 'Los Angeles, CA'  
WHERE 
    a.YearsofExperience > 2
ORDER BY 
    a.LastName, a.FirstName;
	
