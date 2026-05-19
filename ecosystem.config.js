module.exports = {
  apps: [{
    name: 'colecheck-api',
    script: './apps/api/dist/index.js',
    cwd: '/opt/colecheck',
    env: {
      NODE_ENV: 'production',
      PORT: 3005
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    error_file: '/var/log/colecheck/api-error.log',
    out_file: '/var/log/colecheck/api-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
