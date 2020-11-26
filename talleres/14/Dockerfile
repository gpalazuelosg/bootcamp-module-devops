FROM python:3.7

EXPOSE 80

WORKDIR /opt/app

COPY . .

RUN apt update -y
RUN apt install -y stress
RUN pip install -r requirements.txt

ENTRYPOINT ["gunicorn", "-w", "3", "-b", "0.0.0.0:80", "app:app"]