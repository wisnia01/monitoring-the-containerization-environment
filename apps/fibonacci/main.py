from flask import Flask, request, jsonify

app = Flask(__name__)


def calculate_fibonacci(n):
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)


@app.route('/fibonacci/<int:number>', methods=['GET'])
def fibonacci(number):
    result = calculate_fibonacci(number)
    return jsonify({'result': result})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
