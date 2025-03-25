-- Department Table
CREATE TABLE IF NOT EXISTS department (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- Job Table (contains the sensitive salary field)
CREATE TABLE IF NOT EXISTS job (
    job_id SERIAL PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL,
    salary INTEGER NOT NULL
);

-- Location Table
CREATE TABLE IF NOT EXISTS location (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50)
);

-- Employee Table (static employee information)
CREATE TABLE IF NOT EXISTS employee (
    employee_id VARCHAR(20) PRIMARY KEY,
    emp_nm VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    hire_dt DATE NOT NULL,
    education_level VARCHAR(50)
);

-- Employment History Table (captures job transitions)
CREATE TABLE IF NOT EXISTS employment_history (
    history_id SERIAL PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL,
    department_id INTEGER NOT NULL,
    job_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    manager_id VARCHAR(20),
    start_dt DATE NOT NULL,
    end_dt DATE,
    CONSTRAINT fk_emp FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT fk_dept FOREIGN KEY (department_id) REFERENCES department(department_id),
    CONSTRAINT fk_job FOREIGN KEY (job_id) REFERENCES job(job_id),
    CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES location(location_id),
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employee(employee_id)
);
