import tkinter as tk
from tkinter import messagebox
import requests

BASE_URL = "http://localhost:3005/api/auth"

session = requests.Session()  # keep cookies

def register():
    username = entry_username.get()
    email = entry_email.get()
    password = entry_password.get()
    try:
        resp = session.post(f"{BASE_URL}/register", json={
            "username": username,
            "email": email,
            "password": password
        })
        messagebox.showinfo("Register", resp.json())
    except Exception as e:
        messagebox.showerror("Error", str(e))

def login():
    username = entry_username.get()
    password = entry_password.get()
    try:
        resp = session.post(f"{BASE_URL}/login", json={
            "username": username,
            "password": password
        })
        messagebox.showinfo("Login", resp.json())
    except Exception as e:
        messagebox.showerror("Error", str(e))

def profile():
    try:
        resp = session.get(f"{BASE_URL}/profile")
        messagebox.showinfo("Profile", resp.json())
    except Exception as e:
        messagebox.showerror("Error", str(e))

# Tkinter UI
root = tk.Tk()
root.title("Login Service Tester")
root.geometry("400x250")

# Labels and fields
tk.Label(root, text="Username").pack()
entry_username = tk.Entry(root, width=30)
entry_username.pack()

tk.Label(root, text="Email").pack()
entry_email = tk.Entry(root, width=30)
entry_email.pack()

tk.Label(root, text="Password").pack()
entry_password = tk.Entry(root, show="*", width=30)
entry_password.pack()

# Buttons
tk.Button(root, text="Register", command=register, width=15).pack(pady=5)
tk.Button(root, text="Login", command=login, width=15).pack(pady=5)
tk.Button(root, text="Get Profile", command=profile, width=15).pack(pady=5)

root.mainloop()
