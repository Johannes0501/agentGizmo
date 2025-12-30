# Gizmo (Agent Zero) Setup with 2FA Authentication

## Overview
- **gizmo.datastrøm.com** - Agent Zero with Authelia 2FA protection
- **auth.datastrøm.com** - Authelia login portal

## Prerequisites
- Docker and Docker Compose installed
- Nginx installed
- Domain DNS configured (gizmo.datastrøm.com and auth.datastrøm.com → your server IP)

---

## Step 1: Generate Your Password Hash

```bash
docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'YOUR_SECURE_PASSWORD'
```

Copy the output hash and edit `authelia/users_database.yml`:
```bash
nano /home/jh/development/jarvis/authelia/users_database.yml
```

Replace the placeholder password with your generated hash.

---

## Step 2: Add DNS Record for auth.datastrøm.com

Make sure you have an A record for `auth.datastrøm.com` pointing to your server IP.

---

## Step 3: Get SSL Certificates

```bash
# Install certbot if not already installed
sudo apt install certbot python3-certbot-nginx

# Get certificates for both domains
sudo certbot certonly --nginx -d gizmo.xn--datastrm-3ya.com
sudo certbot certonly --nginx -d auth.xn--datastrm-3ya.com
```

---

## Step 4: Install Nginx Configs

```bash
# Copy site configs
sudo cp /home/jh/development/jarvis/nginx/sites-available/*.conf /etc/nginx/sites-available/

# Enable sites
sudo ln -sf /etc/nginx/sites-available/auth.datastrøm.com.conf /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/gizmo.datastrøm.com.conf /etc/nginx/sites-enabled/

# Test config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

---

## Step 5: Start Services

```bash
cd /home/jh/development/jarvis

# Pull images
docker compose pull

# Start all services
docker compose up -d

# Check logs
docker compose logs -f
```

---

## Step 6: Set Up 2FA

1. Go to https://auth.datastrøm.com
2. Log in with username `jh` and your password
3. You'll be prompted to set up TOTP 2FA
4. Scan the QR code with an authenticator app (Google Authenticator, Authy, etc.)
5. Enter the code to verify

---

## Step 7: Access Agent Zero

1. Go to https://gizmo.datastrøm.com
2. You'll be redirected to the Authelia login
3. Enter username, password, and 2FA code
4. You'll be redirected to Agent Zero

---

## Useful Commands

```bash
# View logs
docker compose logs -f authelia
docker compose logs -f agent-zero

# Restart services
docker compose restart

# Stop everything
docker compose down

# Update Agent Zero
docker compose pull agent-zero
docker compose up -d agent-zero
```

---

## Troubleshooting

### "502 Bad Gateway"
- Check if containers are running: `docker compose ps`
- Check authelia logs: `docker compose logs authelia`

### "Cannot connect to Redis"
- Ensure redis container is running: `docker compose ps redis`
- Check redis logs: `docker compose logs redis`

### 2FA not working
- Ensure your system clock is synchronized
- Check that the TOTP issuer in authelia config matches

### IDN Domain Issues
The domain datastrøm.com uses special characters. In nginx configs and some places, the punycode version is used: `xn--datastrm-3ya.com`
