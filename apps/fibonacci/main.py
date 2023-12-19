from flask import Flask, jsonify
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
import requests

app = Flask(__name__)
tracer_provider = TracerProvider(resource=Resource.create({'service.name': 'fibonacci-microservice'}))
tracer_provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(endpoint="http://jaeger-service.monitoring-traces.svc.cluster.local:4317", insecure=True)))
trace.set_tracer_provider(tracer_provider)
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()


def calculate_fibonacci(n):
    with trace.get_tracer(__name__).start_as_current_span(f"fibonacci-calculation-{n}"):
        if n <= 0:
            return 0
        elif n == 1:
            return 1
        return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)


@app.route('/fibonacci/<int:number>', methods=['GET'])
def fibonacci(number):
    with trace.get_tracer(__name__).start_as_current_span("fibonacci-calculation"):
        verification_response = requests.get(f'http://number-verifier-service:420/verify/{number}')
        verification_result = verification_response.json().get('verification', 'unknown')
        if verification_result == 'success':
            result = calculate_fibonacci(number)
            return jsonify({'result': result})
        else:
            return jsonify({'result': 'Please provide a number from 0 to 20'})
        


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
