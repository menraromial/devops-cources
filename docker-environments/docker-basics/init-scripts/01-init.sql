-- Script d'initialisation de la base de données pour le Docker Lab
-- Ce script est exécuté automatiquement au démarrage de PostgreSQL

-- Créer les extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des utilisateurs (pour l'app Node.js)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des produits (pour l'app Python)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des tâches (pour l'app Go)
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour mettre à jour updated_at automatiquement
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_tasks_updated_at ON tasks;
CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insérer des données d'exemple si les tables sont vides
DO $$
BEGIN
    -- Données d'exemple pour users
    IF NOT EXISTS (SELECT 1 FROM users) THEN
        INSERT INTO users (name, email) VALUES 
        ('Alice Dupont', 'alice@example.com'),
        ('Bob Martin', 'bob@example.com'),
        ('Charlie Durand', 'charlie@example.com'),
        ('Diana Prince', 'diana@example.com'),
        ('Ethan Hunt', 'ethan@example.com');
    END IF;

    -- Données d'exemple pour products
    IF NOT EXISTS (SELECT 1 FROM products) THEN
        INSERT INTO products (name, description, price, category) VALUES 
        ('Laptop Dell XPS', 'Ordinateur portable haute performance', 1299.99, 'Electronics'),
        ('iPhone 14', 'Smartphone Apple dernière génération', 999.99, 'Electronics'),
        ('Chaise de bureau', 'Chaise ergonomique pour le travail', 299.99, 'Furniture'),
        ('Livre Python', 'Guide complet de programmation Python', 49.99, 'Books'),
        ('Casque Bluetooth', 'Casque sans fil avec réduction de bruit', 199.99, 'Electronics'),
        ('Table de bureau', 'Table en bois massif pour bureau', 399.99, 'Furniture'),
        ('Clavier mécanique', 'Clavier gaming RGB', 129.99, 'Electronics'),
        ('Livre Docker', 'Maîtriser la conteneurisation', 39.99, 'Books');
    END IF;

    -- Données d'exemple pour tasks
    IF NOT EXISTS (SELECT 1 FROM tasks) THEN
        INSERT INTO tasks (title, description, completed) VALUES 
        ('Apprendre Docker', 'Maîtriser les concepts de base de Docker', false),
        ('Créer un Dockerfile', 'Écrire un Dockerfile optimisé', true),
        ('Utiliser Docker Compose', 'Orchestrer plusieurs conteneurs', false),
        ('Déployer en production', 'Mettre en production avec Docker', false),
        ('Configurer le monitoring', 'Mettre en place Prometheus et Grafana', false),
        ('Sécuriser les conteneurs', 'Appliquer les bonnes pratiques de sécurité', false);
    END IF;
END $$;

-- Afficher un message de confirmation
DO $$
BEGIN
    RAISE NOTICE 'Base de données initialisée avec succès pour le Docker Lab !';
END $$;