const axios = require('axios');

const SUPABASE_URL = 'https://vzusoizwmnarilhtmzuc.supabase.co';
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

module.exports = async (req, res) => {
    if (req.method !== 'POST') return res.status(405).send('Method not allowed');

    const sql = `
    create table if not exists courses (
      id uuid primary key default gen_random_uuid(),
      title text not null,
      created_at timestamp with time zone default now()
    );
  `;

    try {
        await axios.post(`${SUPABASE_URL}/rest/v1/rpc/execute_sql`, { sql }, {
            headers: {
                apikey: SERVICE_ROLE_KEY,
                Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
                'Content-Type': 'application/json',
            },
        });

        res.status(200).json({ message: '✅ Table created!' });
    } catch (err) {
        res.status(500).json({ error: '❌ Failed to create table' });
    }
};
