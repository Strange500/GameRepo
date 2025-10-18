# Deployment Guide

This guide covers different ways to deploy the Game Catalogue application.

## Prerequisites

- Node.js 18.x or later
- Git
- A server or hosting platform

## Production Build

Before deploying, create a production build:

```bash
npm run build
npm start
```

The application will be available on port 3000 by default.

## Deployment Options

### 1. Self-Hosted (Linux Server)

#### Using PM2 (Recommended)

```bash
# Install PM2 globally
npm install -g pm2

# Build the application
npm run build

# Start with PM2
pm2 start npm --name "game-catalogue" -- start

# Save PM2 configuration
pm2 save

# Setup startup script
pm2 startup
```

#### Using systemd

Create a systemd service file `/etc/systemd/system/game-catalogue.service`:

```ini
[Unit]
Description=Game Catalogue
After=network.target

[Service]
Type=simple
User=youruser
WorkingDirectory=/path/to/GameRepo
ExecStart=/usr/bin/npm start
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl enable game-catalogue
sudo systemctl start game-catalogue
```

### 2. Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
```

Build and run:

```bash
# Build image
docker build -t game-catalogue .

# Run container
docker run -d -p 3000:3000 --name game-catalogue game-catalogue
```

### 3. Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  game-catalogue:
    build: .
    ports:
      - "3000:3000"
    restart: unless-stopped
    environment:
      - NODE_ENV=production
```

Deploy:

```bash
docker-compose up -d
```

### 4. Vercel (Not Recommended for this use case)

⚠️ **Note**: Vercel doesn't support executing arbitrary shell commands for security reasons. The install functionality won't work on Vercel. Use self-hosted options instead.

### 5. Cloud Platforms

#### DigitalOcean App Platform

1. Create a new app from your Git repository
2. Set build command: `npm run build`
3. Set run command: `npm start`
4. Deploy

#### AWS EC2

1. Launch an EC2 instance (Ubuntu recommended)
2. SSH into the instance
3. Install Node.js and npm
4. Clone the repository
5. Install dependencies and build
6. Use PM2 or systemd to run the application

#### Google Cloud Run

While possible, Cloud Run has limitations on command execution. Self-hosted solutions are preferred.

## Reverse Proxy Setup

### Nginx

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Apache

```apache
<VirtualHost *:80>
    ServerName your-domain.com
    
    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
</VirtualHost>
```

## Environment Variables

Create a `.env.local` file for environment-specific settings:

```env
# Port to run the application
PORT=3000

# Node environment
NODE_ENV=production
```

## Security Considerations

### Important Security Measures

1. **Firewall**: Only expose necessary ports (80, 443, 22)
2. **HTTPS**: Use SSL certificates (Let's Encrypt recommended)
3. **User Permissions**: Run the application as a non-root user
4. **Command Restrictions**: Only trusted users should modify `games-config.json`
5. **Updates**: Keep Node.js and dependencies up to date

### SSL with Let's Encrypt

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is configured automatically
```

## Monitoring

### PM2 Monitoring

```bash
# View logs
pm2 logs game-catalogue

# Monitor status
pm2 monit

# View status
pm2 status
```

### Health Checks

Add a health check endpoint (optional):

Create `app/api/health/route.ts`:

```typescript
import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({ status: 'ok' });
}
```

## Backup

Regularly backup:
- `games-config.json` - Your game catalogue
- Install scripts in `scripts/` directory
- Any custom modifications

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 3000
sudo lsof -i :3000

# Kill process
kill -9 <PID>

# Or use a different port
PORT=3001 npm start
```

### Permission Denied for Install Scripts

```bash
# Make scripts executable
chmod +x scripts/*.sh
```

### High Memory Usage

```bash
# Restart the application
pm2 restart game-catalogue

# Or limit memory
node --max-old-space-size=512 node_modules/.bin/next start
```

## Scaling

For high traffic, consider:

1. **Load Balancer**: Distribute traffic across multiple instances
2. **CDN**: Cache static assets
3. **Database**: Move game configuration to a database
4. **Message Queue**: Handle install requests asynchronously

## Updates

To update the application:

```bash
# Pull latest changes
git pull

# Install new dependencies
npm install

# Rebuild
npm run build

# Restart
pm2 restart game-catalogue
```

## Cost Estimates

### Self-Hosted Options

- **VPS (DigitalOcean, Linode)**: $5-10/month
- **AWS EC2 t2.micro**: ~$10/month
- **Home Server**: Hardware cost only (electricity ~$2-5/month)

### Managed Platforms

- **DigitalOcean App Platform**: $5-12/month
- **Railway**: $5-10/month
- **Fly.io**: $5-10/month

## Support

For deployment issues:
1. Check application logs
2. Verify all dependencies are installed
3. Ensure proper permissions
4. Review server resources (CPU, RAM, disk)
5. Open a GitHub issue with details

## Next Steps

After deployment:
1. Configure your domain and SSL
2. Set up monitoring
3. Configure automated backups
4. Test the install functionality
5. Add your games to the catalogue
6. Share with your users!

Happy deploying! 🚀
