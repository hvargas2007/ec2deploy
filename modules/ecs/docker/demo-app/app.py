from flask import Flask, render_template
from healthcheck import HealthCheck
import random
import urllib.request
import socket

app = Flask(__name__)
health = HealthCheck(app, "/status")
hostname = (socket.gethostname())

# list of images:
images = [
    "https://media.giphy.com/media/BemKqR9RDK4V2/giphy.gif",
    "https://media.giphy.com/media/citBl9yPwnUOs/giphy.gif",
    "https://media.giphy.com/media/4no7ul3pa571e/giphy.gif",
    "https://media.giphy.com/media/NAcNfRrU6f2bC/giphy.gif",
    "https://media.giphy.com/media/ktcUyw6mBlMVa/giphy.gif",
    "https://media.giphy.com/media/13rQ7rrTrvZXlm/giph.gif",
    "https://media.giphy.com/media/o7OChVtT1oqmk/giphy.gif",
    "https://media.giphy.com/media/NzQSHl01OBLkk/giphy.gif"
]

def demo_available():
	code = urllib.request.urlopen("http://127.0.0.1:8082").getcode()
	print(code)
	if code == 200:
		return True, "OK"
	else:
		return False, "ERROR"

health.add_check(demo_available)

@app.route('/')
def index():
    url = random.choice(images)
    return render_template(
        'index.html',
        url=url,
        hostname=hostname,
        )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8082)