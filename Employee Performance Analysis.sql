--- SQL Employee Performance Analysis
create database sql_project6;
use sql_project6;

-- Data Analysis and Business insights

-- 1. Which departments have the highest average employee performance?

SELECT Department, ROUND(AVG(CurrentEmployeeRating),2) AS Avg_Rating
FROM employee
GROUP BY Department
ORDER BY Avg_Rating DESC;

-- 2. Rank employees within each department based on performance rating.

SELECT EmpID, Department, CurrentEmployeeRating AS Performance_rating, 
DENSE_RANK() OVER( PARTITION BY Department ORDER BY CurrentEmployeeRating DESC) AS Department_rank
FROM employee
ORDER BY Department, Department_Rank;

-- 3. Which training programs produce the highest employee performance ratings?

SELECT t.TrainingProgram, COUNT(t.EmployeeID) AS Total_Employees_Trained,
ROUND(AVG(e.CurrentEmployeeRating),2) AS Avg_Performance_Rating
FROM employee e
INNER JOIN `t&d` t ON e.EmpID = t.EmployeeID
GROUP BY t.TrainingProgram
ORDER BY Avg_Performance_Rating DESC;
    
-- 4. Does employee engagement influence performance ratings?

SELECT
CASE WHEN r.EngagementScore >= 4 THEN 'High Engagement'
WHEN r.EngagementScore >= 3 THEN 'Medium Engagement'
ELSE 'Low Engagement'
END AS Engagement_Level,
count(EmpID) as Total_Employees, 
ROUND(AVG(CurrentEmployeeRating), 2) AS Avg_Performance_Rating FROM Employee e
join employee_engagement r on e.EmpID = r.EmployeeID
GROUP BY Engagement_Level
ORDER BY Avg_Performance_Rating DESC;

-- 5. What is the attrition rate by job role and department?

WITH EmployeeAttrition AS ( SELECT Department, Job,
CASE WHEN EmployeeStatus IN ('Voluntarily Terminated', 'Terminated for Cause')
THEN 1 ELSE 0
END AS Attrition FROM employee)

SELECT Department, Job, COUNT(*) AS Total_Employees,
SUM(Attrition) AS Employees_Left, ROUND(SUM(Attrition) * 100.0 / COUNT(*), 2) AS Attrition_Rate
FROM EmployeeAttrition
GROUP BY Department, Job
ORDER BY Attrition_Rate DESC;

-- 6. Which long-tenured employees have maintained consistently high performance ratings?

SELECT EmpID, FirstName, LastName, Department, Job, StartDate,
TIMESTAMPDIFF(YEAR, StartDate, CURDATE()) AS Years_of_Service,
CurrentEmployeeRating, PerformanceScore,
CASE WHEN PerformanceScore = 'Exceeds'
AND CurrentEmployeeRating >= 4
THEN 'Outstanding Performer'
WHEN PerformanceScore = 'Fully Meets'
 AND CurrentEmployeeRating >= 4
THEN 'Consistent High Performer'
ELSE 'Needs Development' END AS Performance_Category
FROM employee
WHERE TIMESTAMPDIFF(YEAR, StartDate, CURDATE()) >= 5
AND PerformanceScore IN ('Exceeds', 'Fully Meets')
AND CurrentEmployeeRating >= 4
ORDER BY Years_of_Service DESC, CurrentEmployeeRating DESC;

-- End of Project
