"""
Donut Flavors CRUD Application
A Flask web application for managing donut flavors with MySQL/RDS backend.
"""

import os
from flask import Flask, render_template, request, redirect, url_for, flash
import pymysql

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'donut-secret-key-change-in-prod')

# Database configuration from environment variables
DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'admin'),
    'password': os.environ.get('DB_PASSWORD', 'password'),
    'database': os.environ.get('DB_NAME', 'donutdb'),
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}


def get_db_connection():
    """Create and return a database connection."""
    return pymysql.connect(**DB_CONFIG)


def init_db():
    """Initialize the database with the donuts table."""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS donuts (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    flavor VARCHAR(100) NOT NULL,
                    price DECIMAL(5,2) NOT NULL,
                    description TEXT,
                    is_available BOOLEAN DEFAULT TRUE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')

            # Check if table is empty and add sample data
            cursor.execute('SELECT COUNT(*) as count FROM donuts')
            if cursor.fetchone()['count'] == 0:
                sample_donuts = [
                    ('Glazed Classic', 'Original Glaze', 1.50, 'Our signature glazed donut - light, fluffy, and perfectly sweet'),
                    ('Chocolate Dream', 'Chocolate', 2.00, 'Rich chocolate frosting with chocolate cake base'),
                    ('Boston Cream', 'Vanilla Custard', 2.50, 'Filled with vanilla custard, topped with chocolate'),
                    ('Strawberry Sprinkle', 'Strawberry', 1.75, 'Pink strawberry frosting with rainbow sprinkles'),
                    ('Maple Bacon', 'Maple', 3.00, 'Maple glaze topped with crispy bacon bits'),
                    ('Blueberry Burst', 'Blueberry', 2.25, 'Fresh blueberry glaze with blueberry pieces'),
                    ('Cinnamon Sugar', 'Cinnamon', 1.50, 'Coated in cinnamon sugar perfection'),
                    ('Lemon Zest', 'Lemon', 2.00, 'Tangy lemon glaze with zest topping'),
                ]
                cursor.executemany(
                    'INSERT INTO donuts (name, flavor, price, description) VALUES (%s, %s, %s, %s)',
                    sample_donuts
                )
        connection.commit()
    finally:
        connection.close()


@app.route('/')
def index():
    """Display all donuts."""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT * FROM donuts ORDER BY created_at DESC')
            donuts = cursor.fetchall()
    finally:
        connection.close()
    return render_template('index.html', donuts=donuts)


@app.route('/donut/<int:donut_id>')
def view_donut(donut_id):
    """View a single donut's details."""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT * FROM donuts WHERE id = %s', (donut_id,))
            donut = cursor.fetchone()
    finally:
        connection.close()

    if donut is None:
        flash('Donut not found!', 'error')
        return redirect(url_for('index'))
    return render_template('view.html', donut=donut)


@app.route('/add', methods=['GET', 'POST'])
def add_donut():
    """Add a new donut."""
    if request.method == 'POST':
        name = request.form['name']
        flavor = request.form['flavor']
        price = request.form['price']
        description = request.form['description']
        is_available = 'is_available' in request.form

        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    'INSERT INTO donuts (name, flavor, price, description, is_available) VALUES (%s, %s, %s, %s, %s)',
                    (name, flavor, price, description, is_available)
                )
            connection.commit()
        finally:
            connection.close()

        flash(f'Donut "{name}" added successfully!', 'success')
        return redirect(url_for('index'))

    return render_template('add.html')


@app.route('/edit/<int:donut_id>', methods=['GET', 'POST'])
def edit_donut(donut_id):
    """Edit an existing donut."""
    connection = get_db_connection()

    if request.method == 'POST':
        name = request.form['name']
        flavor = request.form['flavor']
        price = request.form['price']
        description = request.form['description']
        is_available = 'is_available' in request.form

        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    'UPDATE donuts SET name=%s, flavor=%s, price=%s, description=%s, is_available=%s WHERE id=%s',
                    (name, flavor, price, description, is_available, donut_id)
                )
            connection.commit()
        finally:
            connection.close()

        flash(f'Donut "{name}" updated successfully!', 'success')
        return redirect(url_for('index'))

    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT * FROM donuts WHERE id = %s', (donut_id,))
            donut = cursor.fetchone()
    finally:
        connection.close()

    if donut is None:
        flash('Donut not found!', 'error')
        return redirect(url_for('index'))

    return render_template('edit.html', donut=donut)


@app.route('/delete/<int:donut_id>', methods=['POST'])
def delete_donut(donut_id):
    """Delete a donut."""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT name FROM donuts WHERE id = %s', (donut_id,))
            donut = cursor.fetchone()
            if donut:
                cursor.execute('DELETE FROM donuts WHERE id = %s', (donut_id,))
                connection.commit()
                flash(f'Donut "{donut["name"]}" deleted successfully!', 'success')
            else:
                flash('Donut not found!', 'error')
    finally:
        connection.close()

    return redirect(url_for('index'))


@app.route('/toggle/<int:donut_id>', methods=['POST'])
def toggle_availability(donut_id):
    """Toggle donut availability."""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                'UPDATE donuts SET is_available = NOT is_available WHERE id = %s',
                (donut_id,)
            )
        connection.commit()
    finally:
        connection.close()

    flash('Availability updated!', 'success')
    return redirect(url_for('index'))


@app.route('/health')
def health_check():
    """Health check endpoint for load balancer."""
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute('SELECT 1')
        connection.close()
        return {'status': 'healthy', 'database': 'connected'}, 200
    except Exception as e:
        return {'status': 'unhealthy', 'error': str(e)}, 500


# Initialize database on startup
with app.app_context():
    try:
        init_db()
        print("Database initialized successfully!")
    except Exception as e:
        print(f"Database initialization will happen on first request: {e}")


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
