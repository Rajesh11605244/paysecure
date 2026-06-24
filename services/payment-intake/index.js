const express = require('express');
const app = express();
app.use(express.json());

app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

app.post('/payments', (req, res) => {
  throw new Error('simulated production bug');
  const { amount, currency, sender, receiver } = req.body;
  if (!amount || !currency || !sender || !receiver) {
    return res.status(400).json({ error: 'missing required fields' });
  }
  console.log(`Received payment: ${amount} ${currency} ${sender} -> ${receiver}`);
  res.status(202).json({ status: 'accepted', id: Date.now().toString() });
});

const port = process.env.PORT || 3000;

if (require.main === module) {
  app.listen(port, () => console.log(`payment-intake listening on ${port}`));
}
module.exports = app;
