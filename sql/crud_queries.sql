-- Q1: List current employment assignments for each employee (where end_dt is NULL)
SELECT e.employee_id, e.emp_nm, j.job_title, d.department_name
FROM employee e
JOIN employment_history eh ON e.employee_id = eh.employee_id
JOIN job j ON eh.job_id = j.job_id
JOIN department d ON eh.department_id = d.department_id
WHERE eh.end_dt IS NULL;

-- Q2: Insert "Web Programmer" as a new job title
INSERT INTO job (job_title, salary) VALUES ('Web Programmer', 55000);

-- Q3: Update the job title from "Web Programmer" to "Web Developer"
UPDATE job
SET job_title = 'Web Developer'
WHERE job_title = 'Web Programmer';

-- Q4: Delete the job title "Web Developer" from the database
DELETE FROM job
WHERE job_title = 'Web Developer';

-- Q5: Count current employees in each department (consider current assignment where end_dt is NULL)
SELECT d.department_name, COUNT(eh.employee_id) AS employee_count
FROM department d
LEFT JOIN employment_history eh
    ON d.department_id = eh.department_id AND eh.end_dt IS NULL
GROUP BY d.department_name;

-- Q6: Retrieve current and past employment history for employee Toni Lembeck
SELECT e.emp_nm, j.job_title, d.department_name, m.emp_nm AS manager_name, eh.start_dt, eh.end_dt
FROM employment_history eh
JOIN employee e ON eh.employee_id = e.employee_id
JOIN job j ON eh.job_id = j.job_id
JOIN department d ON eh.department_id = d.department_id
LEFT JOIN employee m ON eh.manager_id = m.employee_id
WHERE e.emp_nm = 'Toni Lembeck';