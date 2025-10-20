FROM python:3.12
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt

# Copy environment file if .env doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Use environment variable for port exposure
EXPOSE ${PYTHON_SERVICE_PORT:-8082}
CMD ["python", "app.py"]
