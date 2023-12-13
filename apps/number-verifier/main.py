from flask import Flask, jsonify, request
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.propagate import extract
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from time import sleep

app = Flask(__name__)
tracer_provider = TracerProvider(resource=Resource.create({'service.name': 'number-verification-microservice'}))
tracer_provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(endpoint="http://jaeger-service.monitoring-traces.svc.cluster.local:4317", insecure=True)))
trace.set_tracer_provider(tracer_provider)
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()


@app.route('/verify/<int:number>', methods=['GET'])
def verify(number):
    with trace.get_tracer(__name__).start_as_current_span("number-verification"):
        sleep(0.01)
        if number <= 20:
            return jsonify({'verification': 'success'})
        return jsonify({'verification': 'failed'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=420)
