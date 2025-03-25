import time
import pandas as pd
import psycopg2

# Database connection parameters
db_config = {
    "dbname": "mydb",
    "user": "myuser",
    "password": "mypassword",
    "host": "db"  # docker-compose service name acts as hostname
}

# Wait until the database is available
while True:
    try:
        conn = psycopg2.connect(**db_config)
        conn.autocommit = True
        print("Connected to database.")
        break
    except Exception as e:
        print("Database not ready, waiting...")
        time.sleep(2)

cur = conn.cursor()

# --- Load Excel Data ---
# Adjust this file name if necessary. The sample assumes you have a data.xlsx file in the misc folder.
excel_file = '/app/data/hr-dataset.xlsx'
df = pd.read_excel(excel_file)

# --- Insert Data into 'employee' Table ---
employees = df[['EMP_ID', 'EMP_NM', 'EMAIL', 'HIRE_DT', 'EDUCATION LEVEL']].drop_duplicates()
for _, row in employees.iterrows():
    cur.execute("""
        INSERT INTO employee (employee_id, emp_nm, email, hire_dt, education_level)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (employee_id) DO NOTHING;
    """, (row['EMP_ID'], row['EMP_NM'], row['EMAIL'], row['HIRE_DT'], row['EDUCATION LEVEL']))

# --- Insert Distinct Departments ---
departments = df[['DEPARTMENT']].drop_duplicates()
dept_map = {}
for row in departments.itertuples(index=False):
    cur.execute("""
        INSERT INTO department (department_name)
        VALUES (%s)
        RETURNING department_id;
    """, (row.DEPARTMENT,))
    dept_id = cur.fetchone()[0]
    dept_map[row.DEPARTMENT] = dept_id

# --- Insert Distinct Jobs ---
jobs = df[['JOB_TITLE', 'SALARY']].drop_duplicates()
job_map = {}
for row in jobs.itertuples(index=False):
    cur.execute("""
        INSERT INTO job (job_title, salary)
        VALUES (%s, %s)
        RETURNING job_id;
    """, (row.JOB_TITLE, row.SALARY))
    job_id = cur.fetchone()[0]
    job_map[(row.JOB_TITLE, row.SALARY)] = job_id

# --- Insert Distinct Locations ---
locations = df[['LOCATION', 'ADDRESS', 'CITY', 'STATE']].drop_duplicates()
loc_map = {}
for row in locations.itertuples(index=False):
    cur.execute("""
        INSERT INTO location (location_name, address, city, state)
        VALUES (%s, %s, %s, %s)
        RETURNING location_id;
    """, (row.LOCATION, row.ADDRESS, row.CITY, row.STATE))
    loc_id = cur.fetchone()[0]
    loc_map[(row.LOCATION, row.ADDRESS, row.CITY, row.STATE)] = loc_id

# --- Insert Employment History ---
# For the "manager" column, this sample assumes that the Excel file already provides a valid employee ID.
for _, row in df.iterrows():
    department_id = dept_map.get(row['DEPARTMENT'])
    job_id = job_map.get((row['JOB_TITLE'], row['SALARY']))
    location_id = loc_map.get((row['LOCATION'], row['ADDRESS'], row['CITY'], row['STATE']))
    # Resolve manager_id from employee table based on manager name
    manager_name = row['MANAGER'] if pd.notnull(row['MANAGER']) else None
    manager_id = None
    if manager_name:
        cur.execute("SELECT employee_id FROM employee WHERE emp_nm = %s", (manager_name,))
        result = cur.fetchone()
        if result:
            manager_id = result[0]
        else:
            print(f"Warning: Manager '{manager_name}' not found for employee {row['EMP_ID']}. Setting manager_id to NULL.")
    # Convert start_dt and end_dt to None if they are NaT
    start_dt = row['START_DT'] if pd.notnull(row['START_DT']) else None
    end_dt = row['END_DT'] if pd.notnull(row['END_DT']) else None

    cur.execute("""
        INSERT INTO employment_history (employee_id, department_id, job_id, location_id, manager_id, start_dt, end_dt)
        VALUES (%s, %s, %s, %s, %s, %s, %s);
    """, (row['EMP_ID'], department_id, job_id, location_id, manager_id, start_dt, end_dt))

print("Excel data loaded successfully.")

# --- Execute CRUD Queries from 'crud_queries.sql' ---
with open('/app/sql/crud_queries.sql', 'r') as f:
    crud_sql = f.read()

# Note: Depending on your SQL commands, you might want to split and run them individually.
cur.execute(crud_sql)

print("CRUD queries executed successfully.")

# Execute Part 4 SQL scripts
with open('/app/sql/part4.sql', 'r') as f:
    part4_sql = f.read()
cur.execute(part4_sql)
print("Part 4 SQL scripts executed successfully.")

cur.close()
conn.close()
