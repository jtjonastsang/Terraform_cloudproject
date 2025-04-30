from flask import Flask # type: ignore
import psycopg2 # type: ignore
import os
import ssl

app = Flask(__name__)

@app.route('/')
def index():
    try:
        conn = psycopg2.connect(
            dbname=os.environ.get('DB_NAME'),
            user=os.environ.get('DB_USER'),
            password=os.environ.get('DB_PASSWORD'),
            host=os.environ.get('DB_HOST'),
            port=os.environ.get('DB_PORT')
        )
        cur = conn.cursor()
        cur.execute("CREATE TABLE IF NOT EXISTS items (id SERIAL PRIMARY KEY, name VARCHAR(100));")
        cur.execute("INSERT INTO items (name) VALUES ('Test Item') ON CONFLICT DO NOTHING;")
        cur.execute("SELECT name FROM items;")
        items = cur.fetchall()
        conn.commit()
        cur.close()
        conn.close()
        return '<br>'.join([item[0] for item in items])
    except Exception as e:
        return f"Error connecting to database: {str(e)}"

if __name__ == '__main__':
    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context.load_cert_chain('/app/cert.pem', '/app/key.pem')
    app.run(host='0.0.0.0', port=5000, ssl_context=context)