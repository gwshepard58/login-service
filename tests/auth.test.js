const request = require('supertest');
const app = require('../index');

describe('POST /api/auth/login', () => {
  it('should reject invalid login', async () => {
    const res = await request(app).post('/api/auth/login').send({ username: 'wrong', password: 'wrong' });
    expect(res.statusCode).toEqual(401);
  });
});
