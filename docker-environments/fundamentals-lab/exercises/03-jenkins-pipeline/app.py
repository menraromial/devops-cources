#!/usr/bin/env python3
"""
Application simple pour démonstration CI/CD
"""

def add(a, b):
    """Addition de deux nombres"""
    return a + b

def multiply(a, b):
    """Multiplication de deux nombres"""
    return a * b

def divide(a, b):
    """Division de deux nombres"""
    if b == 0:
        raise ValueError("Division par zéro impossible")
    return a / b

def get_app_info():
    """Retourne les informations de l'application"""
    return {
        "name": "Calculator App",
        "version": "1.0.0",
        "description": "Application de démonstration CI/CD"
    }

if __name__ == "__main__":
    print("Calculator App - Version 1.0.0")
    print(f"2 + 3 = {add(2, 3)}")
    print(f"4 * 5 = {multiply(4, 5)}")
    print(f"10 / 2 = {divide(10, 2)}")
