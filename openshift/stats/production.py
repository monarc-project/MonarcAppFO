import os

HOST = os.environ.get("STATS_HOST")
PORT = os.environ.get("STATS_PORT")
INSTANCE_URL = os.environ.get("STATS_INSTANCE_URL")
DB_USER = os.environ.get("STATS_DB_USER")
DB_PASSWORD = os.environ.get("STATS_DB_PASSWORD")
DB_HOST = os.environ.get("STATS_DB_HOST")
DB_NAME = os.environ.get("STATS_DB_NAME")
SECRET_KEY = os.environ.get("STATS_SECRET_KEY")

DEBUG = False
TESTING = False

ADMIN_EMAIL = 'info@nc3.lu'
ADMIN_URL = 'https://www.nc3.lu'

ACTIVE_BLUEPRINTS = ["stats_bp", "admin_bp", "root_bp"]

REMOTE_STATS_SERVER = 'https://dashboard.monarc.lu'

DB_CONFIG_DICT = {
    'user': DB_USER,
    'password': DB_PASSWORD,
    'host': DB_HOST,
    'port': 5432,
}
DATABASE_NAME = DB_NAME
SQLALCHEMY_DATABASE_URI = 'postgresql://{user}:{password}@{host}:{port}/{name}'.format(
    name=DATABASE_NAME, **DB_CONFIG_DICT
)
SQLALCHEMY_TRACK_MODIFICATIONS = False

LOG_PATH = './var/stats.log'

MOSP_URL = 'https://objects.monarc.lu'
