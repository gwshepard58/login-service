import requests

BASE_URL = "http://localhost:3005/api/auth"

# test user
user_data = {
    "username": "gary",
    "email": "gary@example.com",
    "password": "Spen1cer123"
}

session = requests.Session()  # keeps cookies for us

# 1. Register
print("=== Register ===")
register_resp = session.post(f"{BASE_URL}/register", json=user_data)
print("Status:", register_resp.status_code)
print("Response:", register_resp.json())

# 2. Login
print("\n=== Login ===")
login_resp = session.post(f"{BASE_URL}/login", json={
    "username": user_data["username"],
    "password": user_data["password"]
})
print("Status:", login_resp.status_code)
print("Response:", login_resp.json())

# 3. Get Profile
print("\n=== Profile ===")
profile_resp = session.get(f"{BASE_URL}/profile")
print("Status:", profile_resp.status_code)
print("Response:", profile_resp.json())
