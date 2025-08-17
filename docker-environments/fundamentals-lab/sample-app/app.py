#!/usr/bin/env python3
"""
Application d'exemple pour les exercices DevOps Fundamentals
Une API REST simple avec base de données PostgreSQL
"""

import os
import json
from datetime import datetime
from flask import Flask, jsonify, request
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

# Configuration de la base de données
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'postgres'),
    'database': os.getenv('DB_NAME', 'sampleapp'),
    'user': os.getenv('DB_USER', 'devops'),
    'password': os.getenv('DB_PASSWORD', 'devops123'),
    'port': os.getenv('DB_PORT', '5432')
}

def get_db_connection():
    """Établit une connexion à la base de données"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except psycopg2.Error as e:
        print(f"Erreur de connexion à la base de données: {e}")
        return None

def init_db():
    """Initialise la base de données avec les tables nécessaires"""
    conn = get_db_connection()
    if conn:
        try:
            cur = conn.cursor()
            cur.execute('''
                CREATE TABLE IF NOT EXISTS messages (
                    id SERIAL PRIMARY KEY,
                    content TEXT NOT NULL,
                    author VARCHAR(100) NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            
            # Insérer quelques données d'exemple
            cur.execute('''
                INSERT INTO messages (content, author) 
                SELECT 'Bienvenue dans le laboratoire DevOps!', 'System'
                WHERE NOT EXISTS (SELECT 1 FROM messages WHERE author = 'System')
            ''')
            
            conn.commit()
            cur.close()
            print("Base de données initialisée avec succès")
        except psycopg2.Error as e:
            print(f"Erreur lors de l'initialisation de la base de données: {e}")
        finally:
            conn.close()

@app.route('/')
def home():
    """Page d'accueil de l'API"""
    return jsonify({
        'message': 'API DevOps Fundamentals Lab',
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'messages': '/api/messages',
            'info': '/api/info'
        }
    })

@app.route('/health')
def health_check():
    """Endpoint de vérification de santé"""
    try:
        conn = get_db_connection()
        if conn:
            cur = conn.cursor()
            cur.execute('SELECT 1')
            cur.close()
            conn.close()
            db_status = 'healthy'
        else:
            db_status = 'unhealthy'
    except Exception as e:
        db_status = f'error: {str(e)}'
    
    return jsonify({
        'status': 'healthy' if db_status == 'healthy' else 'unhealthy',
        'timestamp': datetime.now().isoformat(),
        'database': db_status,
        'environment': os.getenv('ENV', 'unknown')
    })

@app.route('/api/messages', methods=['GET'])
def get_messages():
    """Récupère tous les messages"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute('SELECT * FROM messages ORDER BY created_at DESC')
        messages = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify({
            'messages': [dict(msg) for msg in messages],
            'count': len(messages)
        })
    except psycopg2.Error as e:
        return jsonify({'error': f'Database error: {str(e)}'}), 500

@app.route('/api/messages', methods=['POST'])
def create_message():
    """Crée un nouveau message"""
    data = request.get_json()
    
    if not data or 'content' not in data or 'author' not in data:
        return jsonify({'error': 'Content and author are required'}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(
            'INSERT INTO messages (content, author) VALUES (%s, %s) RETURNING *',
            (data['content'], data['author'])
        )
        new_message = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            'message': 'Message created successfully',
            'data': dict(new_message)
        }), 201
    except psycopg2.Error as e:
        return jsonify({'error': f'Database error: {str(e)}'}), 500

@app.route('/api/info')
def app_info():
    """Informations sur l'application et l'environnement"""
    return jsonify({
        'application': 'DevOps Fundamentals Sample App',
        'version': '1.0.0',
        'environment': os.getenv('ENV', 'development'),
        'python_version': os.sys.version,
        'database': {
            'host': DB_CONFIG['host'],
            'database': DB_CONFIG['database'],
            'user': DB_CONFIG['user']
        },
        'container_info': {
            'hostname': os.getenv('HOSTNAME', 'unknown'),
            'port': os.getenv('PORT', '8000')
        }
    })

if __name__ == '__main__':
    # Initialiser la base de données au démarrage
    init_db()
    
    # Démarrer l'application
    port = int(os.getenv('PORT', 8000))
    debug = os.getenv('ENV', 'development') == 'development'
    
    app.run(host='0.0.0.0', port=port, debug=debug)