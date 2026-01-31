#!/bin/bash
set -e

VARIANT=$1
DRUPAL_VERSION=$2

echo "===================================="
echo "Installing Drupal ${DRUPAL_VERSION} on ${VARIANT}"
echo "===================================="

# Determine the container name based on variant
if [ "$VARIANT" = "fpm-alpine" ]; then
    CONTAINER="drupal-fpm"
elif [ "$VARIANT" = "frankenphp-trixie" ]; then
    CONTAINER="drupal-frankenphp"
else
    CONTAINER="drupal-apache"
fi

# Wait for the container to be fully ready
echo "Waiting for container to be ready..."
sleep 5

# Check if Drupal is already installed
INSTALLED=$(docker-compose exec -T $CONTAINER sh -c 'if [ -f /var/www/html/web/sites/default/settings.php ] && grep -q "database" /var/www/html/web/sites/default/settings.php 2>/dev/null; then echo "yes"; else echo "no"; fi' || echo "no")

if [ "$INSTALLED" = "yes" ]; then
    echo "Drupal appears to be already installed. Skipping installation."
    exit 0
fi

# Set proper permissions
echo "Setting up permissions..."
docker-compose exec -T $CONTAINER sh -c 'mkdir -p /var/www/html/web/sites/default/files && chmod -R 777 /var/www/html/web/sites/default/files'
docker-compose exec -T $CONTAINER sh -c 'chmod 777 /var/www/html/web/sites/default'

# Install Drupal using drush with SQLite
echo "Installing Drupal using drush..."
docker-compose exec -T $CONTAINER sh -c 'cd /var/www/html && vendor/bin/drush site:install minimal \
    --db-url=sqlite://sites/default/files/.ht.sqlite \
    --site-name="Drupal Test Site" \
    --account-name=admin \
    --account-pass=admin \
    --yes \
    --no-interaction'

# Verify installation
echo "Verifying Drupal installation..."
DRUSH_STATUS=$(docker-compose exec -T $CONTAINER sh -c 'cd /var/www/html && vendor/bin/drush status --format=json' || echo "{}")

echo "Drush status output:"
echo "$DRUSH_STATUS"

# Check if bootstrap was successful
if echo "$DRUSH_STATUS" | grep -q "bootstrap"; then
    echo "✓ Drupal installation completed successfully"
else
    echo "✗ Drupal installation may have issues"
    exit 1
fi

# Set permissions back to safer values
echo "Securing permissions..."
docker-compose exec -T $CONTAINER sh -c 'chmod 555 /var/www/html/web/sites/default'

echo "===================================="
echo "Drupal installation complete"
echo "Admin user: admin"
echo "Admin pass: admin"
echo "===================================="
