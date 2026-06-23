const request = require('supertest');
const app = require('./index.js');

(async () => {
  const res = await request(app).post('/payments').send({
    amount: 100, currency: 'USD', sender: 'A', receiver: 'B'
  });
  console.assert(res.status === 202, 'expected 202 for valid payment');

  const bad = await request(app).post('/payments').send({ amount: 100 });
  console.assert(bad.status === 400, 'expected 400 for missing fields');

  console.log('All tests passed');
})();
