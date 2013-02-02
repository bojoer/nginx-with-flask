from flask import Flask, request, redirect, url_for, session, flash, g, render_template
from flask_oauth import OAuthException

# configuration
SECRET_KEY = 'development key'
DEBUG = True

# setup flask
app = Flask(__name__)
app.debug = DEBUG
app.secret_key = SECRET_KEY

@app.route('/')
def index():   
    return 'Site dev2.markdessain.com <a href="/a">Click here</a>'

@app.route('/a')
def a():
    return 'Site dev2.markdessain.com  A second page'

if __name__ == '__main__':
    app.run()