FROM python:3.9-slim
WORKDIR /app
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
