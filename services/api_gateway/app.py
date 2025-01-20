from flask import Flask, jsonify
import requests,os
from dotenv import load_dotenv,find_dotenv

app = Flask(__name__)


# FETCHER_HOST = os.getenv('FETCHER_HOST')
# PROCESSaOR_HOST = os.getenv('PROCESSOR_HOST')

FETCHER_URL = 'http://weather_fetcher:5000'
PROCESSOR_URL = 'http://weather_processor:5001'


@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200


@app.route('/weather/<city>')
def get_weather(city):
    # Get processed weather data
    response = requests.get(f'{PROCESSOR_URL}/process/{city}')
    return jsonify(response.json())

@app.route('/raw/<city>')
def get_raw_weather(city):
    # Get raw weather data directly from fetcher
    response = requests.get(f'{FETCHER_URL}/fetch/{city}')
    return jsonify(response.json())

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)