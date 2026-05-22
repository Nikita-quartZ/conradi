FROM python:3.12-slim

WORKDIR /app

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

COPY backend/ .
RUN chmod +x entrypoint.sh

EXPOSE 5050

CMD ["./entrypoint.sh"]
