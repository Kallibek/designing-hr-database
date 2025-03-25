FROM python:3.8-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the data loading script
COPY load_data.py load_data.py

CMD ["python", "load_data.py"]
