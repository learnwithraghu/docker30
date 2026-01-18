FROM python:3.9-slim
WORKDIR /app

# Copy requirements first (changes less frequently)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy code last (changes frequently)
COPY . .

EXPOSE 5000
CMD ["python", "app.py"]
