FROM python:3.6-alpine
WORKDIR /code
ADD . /code
RUN pip install redis flask
CMD ["python", "app.py"]
