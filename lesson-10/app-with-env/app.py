import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello():
    name = os.getenv('NAME', 'World')
    env = os.getenv('ENVIRONMENT', 'development')
    return f'Hello {name}! Environment: {env}'

@app.route('/config')
def config():
    return jsonify({
        'name': os.getenv('NAME', 'Not set'),
        'environment': os.getenv('ENVIRONMENT', 'Not set'),
        'debug': os.getenv('DEBUG', 'false')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
