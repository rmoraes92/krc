FROM python:3-alpine
RUN apk add gcc make g++ zlib-dev
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
ADD models.py models.py
ADD clients.py clients.py
ADD settings.py settings.py
EXPOSE 8000
ARG SERVICE_MODULE="signup.py"
ADD ${SERVICE_MODULE} api.py
CMD [ "fastapi", "dev", "--host", "0.0.0.0", "--port", "8000", "api.py" ]
