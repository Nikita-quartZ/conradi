FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

COPY backend/ .
COPY migration/ ../migration/
RUN chmod +x entrypoint.sh

EXPOSE 5050

ENV FLASK_APP=run.py

CMD ["./entrypoint.sh"]
