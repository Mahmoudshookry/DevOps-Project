const request = require('supertest');
const app = require('../app'); // Adjust path as needed

describe('Test the root path', () => {
    it('should respond with a 200 status code', async () => {
        const response = await request(app).get('/');
        expect(response.statusCode).toBe(200);
    });
});
