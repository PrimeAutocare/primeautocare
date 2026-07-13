def test_root(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "PrimeAutocare API is running"}


def test_me_requires_auth(client):
    response = client.get("/me")
    assert response.status_code == 401
