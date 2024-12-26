from flask import Flask, jsonify
import requests

app = Flask(__name__)

# FETCHER_URL = 'http://localhost:5000'  # URL of our weather fetcher service
FETCHER_URL = 'http://weather_fetcher:5000'
PROCESSOR_URL = 'http://weather_processor:5001'

@app.route('/process/<city>')
def process_weather(city):
    # Get data from weather fetcher
    response = requests.get(f'{FETCHER_URL}/fetch/{city}')
    weather_data = response.json()
    
    # Do some simple processing
    processed_data = {
        'city': city,
        'temperature': weather_data['temperature'],
        'temperature_fahrenheit': (weather_data['temperature'] * 9/5) + 32,
        'conditions': {
            'humidity': weather_data['humidity'],
            'wind_speed': weather_data['wind_speed'],
            'description': weather_data['description']
        }
    }
    
    return jsonify(processed_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)  # Note: different port than fetcher