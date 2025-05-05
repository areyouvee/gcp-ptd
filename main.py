from flask import Flask
import subprocess

app = Flask(__name__)

@app.route("/")
def index():
    result = subprocess.run(["python", "script.py"], capture_output=True, text=True)
    return result.stdout or "Script executed with no output."

app.run(host="0.0.0.0", port=8080)