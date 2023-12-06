from flask import Flask, jsonify
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

app = Flask(__name__)
tracer_provider = TracerProvider(resource=Resource.create({'service.name': 'fibonacci-microservice'}))
tracer_provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(endpoint="http://jaeger:4317")))
trace.set_tracer_provider(tracer_provider)
FlaskInstrumentor().instrument_app(app)


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
        result = calculate_fibonacci(number)
    return jsonify({'result': result})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
