FROM python:3.10

WORKDIR /app

COPY ETL.py .

RUN pip install pymongo

CMD ["python", "ETL.py"]
