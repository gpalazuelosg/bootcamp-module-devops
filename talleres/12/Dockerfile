FROM python:3.7-alpine

EXPOSE 8000

WORKDIR /opt/app

COPY . .

RUN pip install -r requirements.txt

ENTRYPOINT ["gunicorn", "-w", "3", "-b", "0.0.0.0:80", "app:app"]