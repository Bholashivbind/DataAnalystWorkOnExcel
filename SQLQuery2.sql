USE Healthcare
--Viewing Data on Database
Select * from healthcare_dataset
-- Counting Total Record in Database
Select Count(*) From healthcare_dataset
-- Finding maximum age of Patient admitted
Select max(age) as Maximum_Age from healthcare_dataset
--Finding Average age of hospitalized patients.
Select round(avg(age),0) as Average_Age from healthcare_dataset
-- Calculating Patients Hospitalized Age-wise from Maximum to Minimum
-- Findings : The output will display a list of unique ages present in the "Healthcare" table along with the count of occurrences for each age, sorted from oldest 	to youngest.   
Select Age, Count(AGE) As Total
From healthcare_dataset
Group By age 
Order by Age DESC

--Calculating Maximum Count of patient on basisi of total patients Hospistalized with respect to age
Select Age, Count(Age) as Total
From healthcare_dataset
Group by age 
Order by Total DESC, age Desc;

-- Ranking Age on the number of patients Hospitalized
SELECT AGE, COUNT(AGE) As Total, dense_RANK() OVER(ORDER BY COUNT(AGE) DESC, age DESC) as Ranking_Admitted 
FROM healthcare_dataset
GROUP BY age;
--HAVING Total > Avg(age);

-- by using cte method
WITH AgeCounts AS (
    SELECT 
        Age, 
        COUNT(Age) AS Total, 
        DENSE_RANK() OVER (ORDER BY COUNT(Age) DESC, Age DESC) AS Ranking_Admitted
    FROM 
        Healthcare_dataset
    GROUP BY 
        Age
)
SELECT *
FROM AgeCounts
WHERE Total > (SELECT AVG(Age) FROM Healthcare_dataset);

-- Finding Count of Medical Condition of patients and listing it by maximum no of patients
Select Medical_Condition, Count(Medical_Condition)as Total_Patients
From healthcare_dataset
Group By Medical_Condition
Order By Total_Patients DESC;

-- Finding Rank & Maximum number of medicines recommend  to patients based on Medical Condition
-- pertianing to them
Select Medical_Condition, Medication, Count(medication) as Total_Medication_to_Patients, Rank()Over(Partition by Medical_Condition order by Count(medication)Desc)as Rank_Medicine
From healthcare_dataset
Group by Medical_Condition,Medication
Order by Medical_Condition;


WITH Ranked_Medications AS (
    SELECT 
        Medical_Condition, 
        Medication, 
        COUNT(Medication) AS Total_Medication_to_Patients,
        RANK() OVER (PARTITION BY Medical_Condition ORDER BY COUNT(Medication) DESC) AS Rank_Medicine
    FROM healthcare_dataset
    GROUP BY Medical_Condition, Medication
)
SELECT *
FROM Ranked_Medications
ORDER BY Medical_Condition, Rank_Medicine;

--Most Preferred Insurance Provide by Patients Hospitalized
Select Insurance_Provider, count(Insurance_Provider) As Total
From healthcare_dataset
Group By Insurance_Provider
Order by total Desc 

-- Finding out most preferred Hospital
Select Hospital,Count(Hospital) As Total
From healthcare_dataset
Group by Hospital
Order by Total Desc;
-- *Findings -: It provides insight into which hospitals have the highest frequency of 
-- records within the healthcare dataset. The resulting list 
-- show cases hospitals based on their patient count or the number of entries related to each hospital, allowing for an understanding of the
-- distribution or prominence of healthcare service among 
-- different meidical facilities.*


-- Identifying Average Billing Amount by Medical Condition
Select Medical_condition, Round(Avg(Billing_Amount),2)As Avg_Billing_Amount
From healthcare_dataset
Group by Medical_Condition
-- Finding: It offers insights into the typ9ical costs associated with various medicalconditions. This information can be valuable for analyzing the financial impact of different health issues, identifying expensive conditions, or assisting in resources allocation within healthcare facilities.

-- Finding Billing Amount of patients admitted and number of days spent in respective hospital.
SELECT 
    Medical_condition, 
    Name, 
    Hospital, 
    DATEDIFF(DAY, Date_of_Admission, Discharge_date) AS Number_of_Days,
    SUM(ROUND(Billing_Amount, 2)) OVER (PARTITION BY Hospital ORDER BY Hospital DESC) AS Total_Amount
FROM healthcare_dataset
ORDER BY Medical_condition, Name;
-- Findings=>This query retrieves a dataset showing the names of patients, their repective medical conditions, billed amounts(rounded to two decimal places), the hospital they visited, and the duration of their hospital stay in days. Insights gelaned inclued:
  -- Individual Patients Details: It presents a comprehensive view of patients, their medical conditions, billed amounts and hospital involved, aiding in understanding the scope of medical services availed by patients.
  -- Hospital Performence: By knowing the length of hospital stays,, an evaluation of the efficiecny of hospital in managing patinet care and treatment duration is possible.
  -- Potential Patterns: Patterns in medical conditions, billed amounts, and duration of hospitalization may emerge, offering insights into prevalent health issue and associated costs in the healthcare dataset.


-- Finding Hospitals Which were successful in discharging patterns after having test resuls as 'Normal' with count of days taken to get reuslts to Normal
Select Medical_Condition, Hospital, DATEDIFF(Day, Date_of_Admission, Discharge_Date)as Total_Hospitalized_days, test_results
From healthcare_dataset
Where Test_Results = 'Normal'
Order by Medical_Condition, Hospital;

-- Calculate number of blood types of patients which lies between age 20 to 45
Select Age, Blood_type, Count(Blood_Type) as Count_Blood_Type
From healthcare_dataset 
Where Age Between 20 And 45
Group by Age,Blood_Type
Order by Blood_Type dESC;
-- Findings: This query filters healthcares data for individual 
--aged between 20 and 45, grouping them by their age and blood type. 
--It then counts the occurrneces of each blood type wihtin this age range. The output provides a breakdwon of 
--blood type distribution among individuals aged 20 to 45,revealingthe prevalence of different 
--blood types within this specific age bracket. The results may offer insights into any 
--potential correlation between age groups and blood type occurances wihthin the dataset.

--Find how many of patient are Universal Blood Donor and Universal Blood reciever
Select Distinct (Select Count(Blood_Type) From healthcare_dataset
Where Blood_Type In ('O-')) As Universal_Bood_Donor,
(Select Count(Blood_Type) From healthcare_dataset Where Blood_Type In('AB+')) as Universal_Blood_reciever
From healthcare_dataset
	-- Findings: This query extracts specific counts of individuals with particular blood types ('O-' and 'AB+' from the healthcare dataset. It compares the count of 'O-' blood type individuals (Conisdered universal donors) against the count of 'AB+' blood type individuals (Considered universal recipients). The result showcase the stark contrast in the prevalance of these two blood types within dataset, highlighting the potential availability of universal donors compared to universal recipients.


-- Create a procedure to find Universal Blood Donor to an Universal to an Universal Blood Reciever, with priority to same hospital and afterwards other hospitals
CREATE PROCEDURE Blood_Matcher
    @Name_of_patient NVARCHAR(200)
AS
BEGIN
    -- Priority: Match donors and receivers from the same hospital
    SELECT 
        D.Name AS Donor_name, 
        D.Age AS Donor_Age, 
        D.Blood_Type AS Donors_Blood_type, 
        D.Hospital AS Donors_Hospital, 
        R.Name AS Reciever_name, 
        R.Age AS Reciever_Age, 
        R.Blood_Type AS Recievers_Blood_type, 
        R.Hospital AS Receivers_Hospital
    FROM 
        healthcare_dataset D
    INNER JOIN 
        healthcare_dataset R
        ON D.Blood_Type = 'O-' 
        AND R.Blood_Type = 'AB+' 
        AND D.Hospital = R.Hospital
    WHERE 
        R.Name LIKE '%' + @Name_of_patient + '%'
        AND D.Age BETWEEN 20 AND 40
    
    UNION
    
    -- Secondary: Match donors and receivers from different hospitals
    SELECT 
        D.Name AS Donor_name, 
        D.Age AS Donor_Age, 
        D.Blood_Type AS Donors_Blood_type, 
        D.Hospital AS Donors_Hospital, 
        R.Name AS Reciever_name, 
        R.Age AS Reciever_Age, 
        R.Blood_Type AS Recievers_Blood_type, 
        R.Hospital AS Receivers_Hospital
    FROM 
        healthcare_dataset D
    INNER JOIN 
        healthcare_dataset R
        ON D.Blood_Type = 'O-' 
        AND R.Blood_Type = 'AB+' 
        AND D.Hospital != R.Hospital
    WHERE 
        R.Name LIKE '%' + @Name_of_patient + '%'
        AND D.Age BETWEEN 20 AND 40;
END;

-- Execute the procedure
EXEC Blood_Matcher @Name_of_patient = 'Donald'
-- Findings: This stored procedure named 'Blood_Matcher' is designed to identify potential donors and recipients based on specific blood types ('O-' and 'AB+') within a certain age range (20 to 40 years old). It retrieves the names, ages, blood types, and hospital of potential donors and recipients from the healthcare database. the condition checks for a match between the blood types and hospitals of donors and recipients or if they are from different hospitals. Additionally, it filters recipient names matching the input provided in the procedure call using regulalr expression. Overall, this procedure aims to find potential mathches for blood donors and reicpients meeting
DROP PROCEDURE Blood_Matcher;

-- Provide a list of hospitals along with the count of patients admitted in the year 2024 And 2025
Select Distinct Hospital, Count(*) as Total_Admitted
From healthcare_dataset
Where Year(Date_of_Admission) In (2024, 2025)
Group By Hospital
Order by total_Admitted Desc;
	 --Findings: This query provides insights into the total admission in different hospitals for the years 2024 and 2025. It retrieves the count distinct admissions per hospital within the specified timeframe. The results are ordered in descending order based on the total number of admissions, highlighiting hospital wiht the highest influx of patients during these years. This data can aid in identifying healthcare facilities experiencing higher patient volumes across the specified period, aiding in resources allocation or further analysis of healthcare demand. 

--Find the average, minimum and maximum  billing amount for each insurance provider?
Select Insurance_Provider, Round(Avg(Billing_Amount),0) as Average_Amount, Round(Min(Billing_Amount),0) as Minimum_Amount, Round(Max(Billing_Amount),0)as Maximum_Amount
From healthcare_dataset
Group By Insurance_Provider
		--Findings: This Query provides insights into billing amount across different insurance provider in the healthcare dataset. It calculate the average, minimum and maximum billing amountper insurance Provider. By examining these metrics, we can understand the typical billing amount range associated with each insurance provider. This information helps identify patterns in healthcare expenses linked to specific insurance companies, highlighting variations in billing practices or potential cost disparities among providers.

-- create a new column that categorizes patients as high, medium or low risk based on their medical condition.

Select Name, Medical_Condition, Test_Results,
Case 
		When Test_Results = 'Inconclusive' Then 'Need More Checks/ CanNot be Discharge'
		When Test_Results = 'Normal' Then 'Can take discharge, But need to follow prescribed medication timely'
		When Test_Results = 'Abnormal' Then 'Needs more attention and more tests'
		End as 'Status', Hospital, Doctor

From healthcare_dataset
 -- Findings: This query provides a summary of patients stautus based on their test results for various medical Conditions. It categorizes patients into distinct statuses: those requring additional checks and unable to be discharged due to inconclusive results, individuals fit for discharge but needing strict adherence to prescribed medications for normal results, and those needing more attention and further tests for abnormal findings. It also displays associated detials like the patient's name, hospital, and attending doctor, offering an overview of patient conditions, discharge possibilites, and necessary follow-up actions.




















