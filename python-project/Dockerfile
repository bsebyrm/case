FROM python:3.10

WORKDIR /app

COPY etl.py .

RUN pip install pymongo

CMD ["python", "etl.py"]
