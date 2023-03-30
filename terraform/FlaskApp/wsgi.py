import os
from app import app

if __name__=='__main':
    app.run(threaded=True, host='0.0.0.0', port=int(os.getenv('APP_PORT')))