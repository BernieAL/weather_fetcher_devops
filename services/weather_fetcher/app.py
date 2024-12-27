import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from flask import Flask, jsonify
import requests
from dotenv import load_dotenv
import os

load_dotenv()
API_KEY = os.getenv('OPENWEATHER_API_KEY')

app = Flask(__name__)


FETCHER_URL = 'http://weather_fetcher:5000'
PROCESSOR_URL = 'http://weather_processor:5001'


@app.route('/health')
def health_check():
    return jsonify({"status": "healthy"})

@app.route('/fetch/<city>')
def fetch_weather(city):
    try:
        url = f'http://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric'
        response = requests.get(url)
        response.raise_for_status()  # Raise exception for bad status codes
        
        weather_data = response.json()
        
        # Extract relevant data
        processed_data = {
            'city': city,
            'temperature': weather_data['main']['temp'],
            'humidity': weather_data['main']['humidity'],
            'description': weather_data['weather'][0]['description'],
            'wind_speed': weather_data['wind']['speed']
        }
        
        return jsonify(processed_data)
    
    except requests.RequestException as e:
        return jsonify({"error": f"Failed to fetch weather data: {str(e)}"}), 500

@app.route('/error')
def simulate_error():
    """Endpoint to test error handling"""
    return jsonify({"error": "Test error"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)