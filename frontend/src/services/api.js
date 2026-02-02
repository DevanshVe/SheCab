import axios from 'axios';

const api = axios.create({
    baseURL: 'http://localhost:8080/api/v1',
    headers: {
        'Content-Type': 'application/json',
    },
});

api.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

export const authService = {
    login: async (credentials) => {
        const response = await api.post('/auth/authenticate', credentials);
        return response.data;
    },
    register: async (userData) => {
        const response = await api.post('/auth/register', userData);
        return response.data;
    },
    getProfile: async () => {
        const response = await api.get('/user/profile');
        return response.data;
    }
};

export const bookingService = {
    bookRide: async (request) => {
        const response = await api.post('/bookings/request', request);
        return response.data;
    },
    getAvailableRides: async () => {
        const response = await api.get('/bookings/available');
        return response.data;
    },
    acceptRide: async (rideId) => {
        const response = await api.post(`/bookings/${rideId}/accept`);
        return response.data;
    },
    startRide: async (rideId, otp) => {
        const response = await api.post(`/bookings/${rideId}/start`, null, {
            params: { otp }
        });
        return response.data;
    },
    completeRide: async (rideId) => {
        const response = await api.post(`/bookings/${rideId}/complete`);
        return response.data;
    },
    payRide: async (rideId) => {
        const response = await api.post(`/bookings/${rideId}/pay`);
        return response.data;
    },
    getMyRides: async () => {
        const response = await api.get('/bookings/my-rides');
        return response.data;
    }
};

export const driverService = {
    toggleAvailability: async () => {
        const response = await api.post('/user/driver/toggle-availability');
        return response.data;
    },
    updateLocation: async (lat, lon) => {
        const response = await api.post(`/user/driver/location?lat=${lat}&lon=${lon}`);
        return response.data;
    }
};

export default api;
