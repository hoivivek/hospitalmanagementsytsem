
-- Query 1 List the patient details who had appointments scheduled with staff between the dates 2020-01-01 and 2020-06-30

SELECT 
    p.patient_id AS 'Patient ID',
    p.patient_first_name AS 'Patient First Name',
    p.patient_last_name AS 'Patient Last Name',
    a.date AS 'Appointment Date',
    a.time AS 'Appointment Time',
    s.staff_id AS 'Staff Id',
    s.staff_first_name AS 'Staff First Name',
    s.staff_last_name AS 'Staff Last Name'
FROM Patients AS p
	JOIN Appointment AS a ON p.patient_id = a.Patients_patient_id
	JOIN Patients_has_Staff AS ps ON p.patient_id = ps.Patients_patient_id
	JOIN Staff AS s ON s.staff_id = ps.Staff_staff_id
WHERE a.date BETWEEN '2020-01-01' AND '2020-06-30'
ORDER BY a.date;


-- Query 2 This query will list details of patients, billing amounts, and insurance details of the patient for bills covered by insurance as a payment method.  

SELECT 
    p.patient_id AS 'Patient Id',
    CONCAT(p.patient_first_name, ' ', p.patient_last_name) AS 'Patient Full Name',
    b.bill_id AS 'Bill Id',
    b.amount AS 'Bill Amount',
    i.policy_number AS 'Policy Number',
    i.provider_name AS 'Insurance Provider Name'
FROM Patients AS p
JOIN Billing AS b ON p.patient_id = b.Patients_patient_id
JOIN Insurance AS i ON p.patient_id = i.Patients_patient_id
WHERE b.mode_of_payment LIKE 'insurance';


-- Query 3 This query will get staff details for all the doctor staff.

SELECT 
    s.staff_id AS 'Staff Id',
    s.staff_first_name AS 'Doctor\'s First Name',
    s.staff_last_name AS 'Doctor\'s Last Name'
FROM Staff AS s
JOIN Staff_Type AS st ON s.staff_id = st.Staff_staff_id
WHERE st.staff_type_name LIKE 'doctor';


-- Query 4 This query lists the details of patients and the number of appointments that they made in the year 2018.  

SELECT 
    p.patient_id AS 'Patient Id',
    p.patient_first_name AS 'Patient First Name',
    p.patient_last_name AS 'Patient Last Name',
    COUNT(a.date) AS 'Appointment Count'
FROM Patients AS p
JOIN Appointment AS a ON p.patient_id = a.patients_patient_id
WHERE a.date BETWEEN '2018-01-01' AND '2018-12-31'
GROUP BY p.patient_id
ORDER BY COUNT(a.date) DESC;


-- Query 5 This query gives the details of patients with their illness who are born between 1965-01-01 and 1975-12-31.

SELECT 
    p.patient_id AS 'Patient Id',
    p.patient_first_name AS 'Patient First Name',
    p.patient_last_name AS 'Patient Last Name',
    p.dateofbirth AS 'Date of Birth',
    ill.description AS 'Illness Description'
FROM Patients AS p
JOIN Patients_has_Illness_Details AS pd ON p.patient_id = pd.Patients_patient_id
JOIN Illness_Details AS ill ON ill.illness_id = pd.Illness_details_illness_id
WHERE dateofbirth BETWEEN '1965-01-01' AND '1975-12-31'
ORDER BY dateofbirth;


-- Query 6 This query gives the list of doctors by the number of patients they have served, in descending order.

SELECT 
    st.Staff_staff_id AS 'Staff Id',
    CONCAT(s.staff_first_name, ' ', s.staff_last_name) AS 'Staff Name',
    COUNT(DISTINCT phs.Patients_patient_id) AS Patient_count
FROM Staff_Type st
JOIN Patients_has_Staff phs ON st.Staff_staff_id = phs.Staff_staff_id
JOIN Staff s ON s.staff_id = st.Staff_staff_id
WHERE staff_type_name = 'Doctor'
GROUP BY st.Staff_staff_id , st.staff_type_name
ORDER BY Patient_count DESC;


-- Query 7 This query Identifies the patient with the highest bill payment and lists the services they received, as well as the names of the staff’s who treated them.

SELECT 
    p.patient_id AS 'Patient Id',
    CONCAT(p.patient_first_name, ' ', p.patient_last_name) AS 'Patient Name',
    mr.record_id AS 'Medical Record Id',
    b.max_paid AS 'Maximum Amount Paid',
    phs.Staff_staff_id AS 'Staff Id',
	CONCAT(s.staff_first_name, ' ', s.staff_last_name) AS 'Staff Name'
FROM
    Patients AS p
JOIN
    (SELECT 
        Patients_patient_id, MAX(amount) AS max_paid
    FROM
        Billing AS b
    GROUP BY Patients_patient_id
    ORDER BY max_paid DESC
    LIMIT 1) AS b ON p.patient_id = b.Patients_patient_id
JOIN Medical_Records AS mr ON p.patient_id = mr.Patients_patient_id
JOIN Patients_has_Staff AS phs ON p.patient_id = phs.Patients_patient_id
JOIN Staff AS s ON phs.Staff_staff_id = s.staff_id
JOIN Staff_Type AS st ON s.staff_id = st.Staff_staff_id;      
    
 
-- Query 8 This query finds all the billing records for patients with payment status as Unpaid. 

SELECT 
    p.patient_id AS 'Patient Id',
     CONCAT(p.patient_first_name, ' ', p.patient_last_name) AS 'Patient Name',
    b.amount AS 'Amount',
    b.date AS 'Billing Date'
FROM Patients AS p
JOIN Billing AS b ON p.patient_id = b.Patients_patient_id
WHERE b.payment_status = 'unpaid'
ORDER BY b.date;
    

-- Query 9 This query lists the Patients appointment history in descending order. 

SELECT 
    p.patient_id AS 'Patient Id',
    p.patient_first_name AS 'Patient First Name',
    p.patient_last_name AS 'Patient Last Name',
    a.date AS 'Appointment Date',
    a.time AS 'Appoinntment Time'
FROM Patients AS p
JOIN Appointment AS a ON p.patient_id = a.Patients_patient_id
ORDER BY a.date DESC;


 -- Query 10 This query gets the average billing amount per illness type.  
 
SELECT 
	il.description AS 'Illness Description',
    AVG(b.amount) AS 'Average Billing Amount'
FROM Illness_Details AS il
JOIN Patients_has_Illness_Details AS pid ON il.illness_id = pid.Illness_Details_illness_id
JOIN Billing AS b ON pid.Patients_patient_id = b.Patients_patient_id
GROUP BY il.description;
    
    
-- Query 11 This query will list patients that have not been seen by a doctor, what their illness was, and how long did they stay in the hospital.

SELECT 
    p.patient_id AS 'Patient ID',
    CONCAT(p.patient_first_name, ' ', p.patient_last_name) AS 'Patient Name',
    GROUP_CONCAT(DISTINCT id.description) AS Illness,
    SUM(DATEDIFF(mr.discharge_date, mr.addmission_date)) AS 'Total Length Of Stay'
FROM
    Patients AS p
        INNER JOIN
    Patients_has_Illness_Details AS phi ON p.patient_id = phi.Patients_patient_id
        INNER JOIN
    Illness_Details AS id ON phi.Illness_Details_illness_id = id.illness_id
        INNER JOIN
    Medical_Records AS mr ON p.patient_id = mr.Patients_patient_id
        LEFT JOIN
    Patients_has_Staff AS phs ON p.patient_id = phs.Patients_patient_id
        INNER JOIN
    Staff AS s ON phs.Staff_staff_id = s.staff_id
        INNER JOIN
    Staff_Type AS st ON s.staff_id = st.Staff_staff_id
WHERE
    st.staff_type_name IN ('Registered Nurse' , 'Nurse Practitioner')
        AND NOT EXISTS( SELECT 
            1
        FROM
            Patients_has_Staff AS phs2
                INNER JOIN
            Staff AS s2 ON phs2.Staff_staff_id = s2.staff_id
                INNER JOIN
            Staff_Type AS st2 ON s2.staff_id = st2.Staff_staff_id
        WHERE
            phs2.Patients_patient_id = p.patient_id
                AND st2.staff_type_name = 'Doctor')
GROUP BY p.patient_id;

