FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl \
    && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Create a non-root user and switch to it
RUN useradd -m appuser
USER appuser

EXPOSE 5000
CMD ["python", "app.py"]
