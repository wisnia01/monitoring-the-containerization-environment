FROM python:3.12

WORKDIR /app

RUN pip install flask
RUN pip install opentelemetry-api opentelemetry-sdk opentelemetry-instrumentation-flask opentelemetry-instrumentation-requests opentelemetry-exporter-jaeger opentelemetry-exporter-otlp-proto-http opentelemetry-proto opentelemetry-exporter-otlp-proto-grpc

COPY . .

CMD ["python", "main.py"]