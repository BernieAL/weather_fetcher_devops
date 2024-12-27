
import pytest
import os,sys
from flask import Flask
from unittest.mock import patch
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client
    
#we mock the requests.get function
@patch('requests.get')
def test_fetch_weather(mock_get,client):
    #setup mock response

    mock_get.return_value.json.return_value = {
        "main": {"temp":20},
        "weather": [{"description": "clear"}],
        "wind":{"speed":5}
    }

    response = client.get('/fetch/london')
    assert response.status_code == 200
