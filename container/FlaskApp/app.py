import requests
import json
from flask import Flask, render_template, request

app = Flask(__name__)
API_URL_TO_POST = 'https://cfjhkd0qj9.execute-api.us-east-2.amazonaws.com/prod/write_to_database'
API_URL_TO_RETREIVE = 'https://du0y2gp2va.execute-api.us-east-2.amazonaws.com/prod/read_from_database'


def write_to_guestbook(name, message):
    parameters = {
        'name': name,
        'message': message
    }
    data = requests.post(url=API_URL_TO_POST, params=parameters)
    return data.json()

def read_from_guestbook():
    data = requests.get(url=API_URL_TO_RETREIVE)
    guestbook = data.json()
    return guestbook

@app.route('/', methods=['GET','POST'])
def index():
    if request.method == 'POST':
        name = request.form['name']
        message = request.form['message']
        if name is not None and message is not None:
            write_to_guestbook(name, message)
        guestbook = read_from_guestbook()
        return render_template('index.html', guestbook=guestbook)
    else:
        guestbook = read_from_guestbook()
        return render_template('index.html', guestbook=guestbook)
if __name__ == '__main__':
    app.run(debug=True)