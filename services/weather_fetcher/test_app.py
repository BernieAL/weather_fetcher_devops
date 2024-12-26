from app import app
import pytest

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_fetch_weather(client):
    response = client.get('/fetch/london')
    assert response.status_code == 200
    data = response.get_json()
    assert 'temperature' in data

