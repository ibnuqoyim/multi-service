FROM python:3.12
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt

# Copy environment file if .env doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env; fi

EXPOSE 8082
CMD ["python", "app.py"]
