#!/usr/bin/env python3
"""
Application Flask d'exemple pour le Docker Lab
Démontre l'utilisation de PostgreSQL et Redis avec Flask
"""

import os
import json
import time
import socket
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import redis
from dotenv import load_dotenv

# Charger les variables d'environnement
load_dotenv()

# Configuration de l'application
app = Flask(__name__)
CORS(app)

# Configuration de la base de données
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://labuser:labpass@localhost:5432/labdb')
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379')

# Connexion Redis
try:
    redis_client = redis.from_url(REDIS_URL, decode_responses=True)
    redis_client.ping()
    print("✅ Connexion Redis établie")
except Exception as e:
    print(f"❌ Erreur connexion Redis: {e}")
    redis_client = None

def get_db_connection():
    """Obtenir une connexion à la base de données PostgreSQL"""
    try:
        conn = psycopg2.connect(DATABASE_URL)
        return conn
    except Exception as e:
        print(f"❌ Erreur connexion PostgreSQL: {e}")
        return None

def init_database():
    """Initialiser la base de données avec les tables nécessaires"""
    try:
        conn = get_db_connection()
        if not conn:
            return False
            
        cur = conn.cursor()
        
        # Créer la table des produits
        cur.execute("""
            CREATE TABLE IF NOT EXISTS products (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                description TEXT,
                price DECIMAL(10,2) NOT NULL,
                category VARCHAR(50),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Vérifier s'il y a des données
        cur.execute("SELECT COUNT(*) FROM products")
        count = cur.fetchone()[0]
        
        if count == 0:
            # Insérer des données d'exemple
            sample_products = [
                ('Laptop Dell XPS', 'Ordinateur portable haute performance', 1299.99, 'Electronics'),
                ('iPhone 14', 'Smartphone Apple dernière génération', 999.99, 'Electronics'),
                ('Chaise de bureau', 'Chaise ergonomique pour le travail', 299.99, 'Furniture'),
                ('Livre Python', 'Guide complet de programmation Python', 49.99, 'Books'),
                ('Casque Bluetooth', 'Casque sans fil avec réduction de bruit', 199.99, 'Electronics')
            ]
            
            cur.executemany(
                "INSERT INTO products (name, description, price, category) VALUES (%s, %s, %s, %s)",
                sample_products
            )
            print("✅ Données d'exemple insérées dans la table products")
        
        conn.commit()
        cur.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ Erreur initialisation base de données: {e}")
        return False

# Routes

@app.route('/')
def home():
    """Page d'accueil de l'API"""
    return jsonify({
        'message': '🐍 Docker Python Flask App',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat(),
        'environment': os.getenv('FLASK_ENV', 'production'),
        'hostname': socket.gethostname()
    })

@app.route('/health')
def health_check():
    """Endpoint de vérification de santé"""
    try:
        # Test PostgreSQL
        conn = get_db_connection()
        if conn:
            cur = conn.cursor()
            cur.execute('SELECT 1')
            cur.close()
            conn.close()
            db_status = 'connected'
        else:
            db_status = 'disconnected'
        
        # Test Redis
        if redis_client:
            redis_client.ping()
            redis_status = 'connected'
        else:
            redis_status = 'disconnected'
        
        status = 'healthy' if db_status == 'connected' and redis_status == 'connected' else 'degraded'
        
        return jsonify({
            'status': status,
            'timestamp': datetime.now().isoformat(),
            'services': {
                'database': db_status,
                'redis': redis_status
            },
            'hostname': socket.gethostname()
        })
        
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/products', methods=['GET'])
def get_products():
    """Récupérer la liste des produits"""
    try:
        # Vérifier le cache Redis
        if redis_client:
            cached = redis_client.get('products')
            if cached:
                return jsonify({
                    'data': json.loads(cached),
                    'source': 'cache',
                    'timestamp': datetime.now().isoformat()
                })
        
        # Requête base de données
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
            
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute('SELECT * FROM products ORDER BY created_at DESC')
        products = cur.fetchall()
        
        # Convertir en liste de dictionnaires
        products_list = [dict(product) for product in products]
        
        # Mettre en cache pour 5 minutes
        if redis_client:
            redis_client.setex('products', 300, json.dumps(products_list, default=str))
        
        cur.close()
        conn.close()
        
        return jsonify({
            'data': products_list,
            'source': 'database',
            'count': len(products_list),
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/products', methods=['POST'])
def create_product():
    """Créer un nouveau produit"""
    try:
        data = request.get_json()
        
        if not data or not all(k in data for k in ('name', 'price')):
            return jsonify({'error': 'Name and price are required'}), 400
        
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
            
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(
            """INSERT INTO products (name, description, price, category) 
               VALUES (%s, %s, %s, %s) RETURNING *""",
            (data['name'], data.get('description', ''), data['price'], data.get('category', ''))
        )
        
        new_product = dict(cur.fetchone())
        conn.commit()
        
        # Invalider le cache
        if redis_client:
            redis_client.delete('products')
        
        cur.close()
        conn.close()
        
        return jsonify({
            'message': 'Product created successfully',
            'product': new_product
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Récupérer un produit spécifique"""
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
            
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute('SELECT * FROM products WHERE id = %s', (product_id,))
        product = cur.fetchone()
        
        if not product:
            return jsonify({'error': 'Product not found'}), 404
        
        cur.close()
        conn.close()
        
        return jsonify({
            'data': dict(product),
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/stats')
def get_stats():
    """Statistiques de l'application"""
    try:
        stats = {}
        
        # Statistiques base de données
        conn = get_db_connection()
        if conn:
            cur = conn.cursor()
            cur.execute('SELECT COUNT(*) FROM products')
            stats['total_products'] = cur.fetchone()[0]
            
            cur.execute('SELECT category, COUNT(*) FROM products GROUP BY category')
            categories = cur.fetchall()
            stats['products_by_category'] = {cat[0]: cat[1] for cat in categories}
            
            cur.close()
            conn.close()
        
        # Statistiques Redis
        if redis_client:
            # Compteur de visites
            visits = redis_client.incr('api_visits')
            stats['api_visits'] = visits
            
            # Informations Redis
            info = redis_client.info()
            stats['redis_info'] = {
                'connected_clients': info.get('connected_clients', 0),
                'used_memory_human': info.get('used_memory_human', '0B'),
                'uptime_in_seconds': info.get('uptime_in_seconds', 0)
            }
        
        return jsonify({
            'stats': stats,
            'timestamp': datetime.now().isoformat(),
            'hostname': socket.gethostname()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/info')
def system_info():
    """Informations système"""
    import platform
    import psutil
    
    return jsonify({
        'hostname': socket.gethostname(),
        'platform': platform.platform(),
        'python_version': platform.python_version(),
        'flask_version': '2.3.3',
        'memory_usage': f"{psutil.virtual_memory().percent}%",
        'cpu_count': psutil.cpu_count(),
        'timestamp': datetime.now().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    """Gestionnaire d'erreur 404"""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested resource was not found',
        'timestamp': datetime.now().isoformat()
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Gestionnaire d'erreur 500"""
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An internal server error occurred',
        'timestamp': datetime.now().isoformat()
    }), 500

if __name__ == '__main__':
    print("🚀 Démarrage de l'application Flask...")
    print(f"🌍 Environnement: {os.getenv('FLASK_ENV', 'production')}")
    print(f"🐳 Container ID: {socket.gethostname()}")
    
    # Initialiser la base de données
    if init_database():
        print("✅ Base de données initialisée")
    else:
        print("❌ Erreur d'initialisation de la base de données")
    
    # Démarrer l'application
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5000)),
        debug=os.getenv('FLASK_ENV') == 'development'
    )