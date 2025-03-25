-- Create view for all employee attributes
CREATE OR REPLACE VIEW vw_all_employees AS
SELECT 
    e.employee_id, 
    e.emp_nm, 
    e.email, 
    e.hire_dt, 
    e.education_level,
    eh.start_dt, 
    eh.end_dt,
    j.job_title, 
    j.salary,
    d.department_name,
    l.location_name, 
    l.address, 
    l.city, 
    l.state
FROM employee e
JOIN employment_history eh ON e.employee_id = eh.employee_id
JOIN job j ON eh.job_id = j.job_id
JOIN department d ON eh.department_id = d.department_id
JOIN location l ON eh.location_id = l.location_id;

-- Create function for employment history
CREATE OR REPLACE FUNCTION sp_get_employment_history(empName VARCHAR)
RETURNS TABLE (
    emp_nm VARCHAR,
    job_title VARCHAR,
    department_name VARCHAR,
    manager_name VARCHAR,
    start_dt DATE,
    end_dt DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.emp_nm, 
        j.job_title, 
        d.department_name, 
        m.emp_nm AS manager_name, 
        eh.start_dt, 
        eh.end_dt
    FROM employment_history eh
    JOIN employee e ON eh.employee_id = e.employee_id
    JOIN job j ON eh.job_id = j.job_id
    JOIN department d ON eh.department_id = d.department_id
    LEFT JOIN employee m ON eh.manager_id = m.employee_id
    WHERE e.emp_nm = empName;
END;
$$ LANGUAGE plpgsql;



-- Create a non-management user without login privileges
CREATE USER NoMgr WITH NOLOGIN;

-- Grant read-only access to general tables
GRANT SELECT ON employee TO NoMgr;
GRANT SELECT ON employment_history TO NoMgr;
GRANT SELECT ON department TO NoMgr;
GRANT SELECT ON location TO NoMgr;

-- Since PostgreSQL does not support column-level DENY permissions,
-- create a view excluding the salary column and grant access to that view.
CREATE VIEW vw_job_nosalary AS
SELECT job_id, job_title
FROM job;
GRANT SELECT ON vw_job_nosalary TO NoMgr;
