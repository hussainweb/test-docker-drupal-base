# Docker Drupal Base Image Testing

This repository contains comprehensive tests for the Docker images from [hussainweb/docker-drupal-base](https://github.com/hussainweb/docker-drupal-base).

## Testing Strategy

### Overview

The testing strategy validates that the Docker images properly support running Drupal applications by:

1. **Spinning up Docker containers** using different image variants
2. **Installing Drupal** using Drush with SQLite database
3. **Verifying** that Drupal loads and functions correctly

### Tested Configurations

The test suite covers the following matrix:

- **Drupal Versions:**
  - Drupal 11.0 (latest stable)
  - DrupalCMS 2.0 (next generation Drupal)

- **Docker Image Variants (PHP 8.5):**
  - `apache-trixie` - Apache web server on Debian Trixie
  - `fpm-alpine` - PHP-FPM on Alpine Linux (with nginx)
  - `frankenphp-trixie` - FrankenPHP on Debian Trixie

### Test Architecture

#### 1. GitHub Actions Workflow

The testing is automated using GitHub Actions (`.github/workflows/test-images.yml`) with the following triggers:

- **Push to main branch** - Ensures changes don't break functionality
- **Pull requests** - Validates contributions before merging
- **Weekly schedule** - Catches issues with latest Drupal releases
- **Manual dispatch** - On-demand testing

The workflow uses a matrix strategy to test all combinations of Drupal versions and image variants in parallel.

#### 2. Docker Compose Stacks

Each image variant has its own Docker Compose configuration:

- **`tests/docker-compose.apache.yml`** - Apache variant (single container)
- **`tests/docker-compose.fpm.yml`** - FPM variant (PHP-FPM + nginx containers)
- **`tests/docker-compose.frankenphp.yml`** - FrankenPHP variant (single container)

The FPM variant requires an additional nginx container to serve as the web server, with configuration provided in `tests/nginx.conf`.

#### 3. Installation Script

`tests/install-drupal.sh` handles the Drupal installation:

- Creates necessary directories and sets permissions
- Installs Drupal using Drush with SQLite database
- Configures admin credentials (username: `admin`, password: `admin`)
- Verifies successful installation via Drush status checks
- Secures permissions after installation

**SQLite Usage:** Tests use SQLite to avoid the complexity of setting up a separate database server, making tests faster and more portable.

#### 4. Verification Script

`tests/verify-drupal.sh` performs comprehensive validation:

**HTTP Endpoint Tests:**
- Homepage accessibility (HTTP 200)
- User login page functionality
- Admin page redirect behavior
- Content verification (Drupal meta tags)

**Backend Tests:**
- Drush status check (bootstrap verification)
- PHP availability and version
- Required PHP extensions (gd, pdo, pdo_sqlite, json, opcache)
- Web root file permissions

### Running Tests Locally

You can run the tests locally to validate changes before pushing:

#### Prerequisites

- Docker and Docker Compose installed
- Composer installed (for downloading Drupal)

#### Steps

1. **Clone this repository:**
   ```bash
   git clone https://github.com/hussainweb/test-docker-drupal-base.git
   cd test-docker-drupal-base
   ```

2. **Choose a variant to test** (apache-trixie, fpm-alpine, or frankenphp-trixie):
   ```bash
   VARIANT="apache-trixie"
   ```

3. **Download Drupal:**
   ```bash
   # For Drupal 11
   composer create-project drupal/recommended-project:^11.0 drupal-root --no-interaction --no-dev
   
   # OR for DrupalCMS 2
   composer create-project drupal/cms:^2.0 drupal-root --no-interaction --no-dev
   
   # Add drush
   cd drupal-root
   composer require drush/drush --no-interaction
   cd ..
   ```

4. **Set up docker-compose:**
   ```bash
   # For Apache variant
   cp tests/docker-compose.apache.yml docker-compose.yml
   
   # For FPM variant (also copy nginx config)
   cp tests/docker-compose.fpm.yml docker-compose.yml
   cp tests/nginx.conf nginx.conf
   
   # For FrankenPHP variant
   cp tests/docker-compose.frankenphp.yml docker-compose.yml
   ```

5. **Start containers:**
   ```bash
   docker-compose up -d
   ```

6. **Install Drupal:**
   ```bash
   chmod +x tests/install-drupal.sh
   ./tests/install-drupal.sh $VARIANT "11.0"
   ```

7. **Run verification tests:**
   ```bash
   chmod +x tests/verify-drupal.sh
   ./tests/verify-drupal.sh $VARIANT
   ```

8. **Access Drupal:**
   Open http://localhost:8080 in your browser
   - Username: `admin`
   - Password: `admin`

9. **Clean up:**
   ```bash
   docker-compose down -v
   rm -rf drupal-root
   ```

### Test Coverage

The verification suite includes 8 comprehensive tests:

1. ✓ Homepage returns HTTP 200
2. ✓ Login page accessible
3. ✓ Admin page redirect works
4. ✓ Drupal content present on homepage
5. ✓ Drush bootstrap successful
6. ✓ PHP is available and working
7. ✓ Required PHP extensions installed
8. ✓ Web root has proper permissions

### Continuous Integration

GitHub Actions automatically runs these tests for every push and pull request. Test results and logs are available as artifacts in the Actions tab.

**Matrix Testing:** Each combination of Drupal version and image variant is tested independently, resulting in 6 test jobs per run (2 Drupal versions × 3 variants).

### Why This Testing Strategy?

1. **Comprehensive Coverage:** Tests all supported variants and Drupal versions
2. **Real-world Scenarios:** Uses actual Drupal installations, not mocks
3. **Multiple Verification Points:** Tests HTTP, PHP, and Drupal functionality
4. **Automated & Repeatable:** Runs consistently in CI/CD
5. **Fast & Portable:** SQLite avoids external database dependencies
6. **Failure Diagnostics:** Captures logs and artifacts for debugging

### Future Enhancements

Potential improvements to the test suite:

- [ ] Add tests for multi-site configurations
- [ ] Test different PHP versions (8.2, 8.3, 8.4)
- [ ] Add performance benchmarking
- [ ] Test with MySQL/PostgreSQL databases
- [ ] Add tests for common Drupal modules
- [ ] Test container restart/recovery scenarios
- [ ] Add security scanning of images

## Contributing

Contributions are welcome! Please ensure:

1. Tests pass locally before submitting PR
2. New features include appropriate test coverage
3. Documentation is updated for any changes

## License

This testing repository follows the same license as the main [docker-drupal-base](https://github.com/hussainweb/docker-drupal-base) project.

## Related Resources

- [Main Repository: docker-drupal-base](https://github.com/hussainweb/docker-drupal-base)
- [Docker Hub: hussainweb/drupal-base](https://hub.docker.com/r/hussainweb/drupal-base)
- [Drupal Official Documentation](https://www.drupal.org/docs)
- [Drush Documentation](https://www.drush.org/)
