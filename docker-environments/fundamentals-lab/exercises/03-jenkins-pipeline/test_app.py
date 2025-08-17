#!/usr/bin/env python3
"""
Tests unitaires pour l'application Calculator
"""

import unittest
from app import add, multiply, divide, get_app_info

class TestCalculator(unittest.TestCase):
    
    def test_add(self):
        """Test de la fonction addition"""
        self.assertEqual(add(2, 3), 5)
        self.assertEqual(add(-1, 1), 0)
        self.assertEqual(add(0, 0), 0)
    
    def test_multiply(self):
        """Test de la fonction multiplication"""
        self.assertEqual(multiply(2, 3), 6)
        self.assertEqual(multiply(-2, 3), -6)
        self.assertEqual(multiply(0, 5), 0)
    
    def test_divide(self):
        """Test de la fonction division"""
        self.assertEqual(divide(6, 2), 3)
        self.assertEqual(divide(5, 2), 2.5)
        
        # Test de l'exception pour division par zéro
        with self.assertRaises(ValueError):
            divide(5, 0)
    
    def test_get_app_info(self):
        """Test des informations de l'application"""
        info = get_app_info()
        self.assertIn("name", info)
        self.assertIn("version", info)
        self.assertEqual(info["name"], "Calculator App")

if __name__ == '__main__':
    unittest.main()
