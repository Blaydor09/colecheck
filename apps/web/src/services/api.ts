import axios from 'axios';

// Configure the base instance
const api = axios.create({
  baseURL: 'http://localhost:3005/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor to attach JWT token to all requests if it exists
api.interceptors.request.use(
  (config) => {
    // Read token from localStorage if we are authenticated
    const token = localStorage.getItem('token');
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default api;
