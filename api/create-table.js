const axios = require('axios');

const SUPABASE_URL = 'https://vzusoizwmnarilhtmzuc.supabase.co';
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

module.exports = async (req, res) => {
    if (req.method !== 'GET') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const sql = req.query.sql;

    if (!sql) {
        return res.status(400).json({ error: 'Missing SQL parameter' });
    }

    try {
        await axios.post(`${SUPABASE_URL}/rest/v1/rpc/execute_sql`, { sql }, {
            headers: {
                apikey: SERVICE_ROLE_KEY,
                Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
                'Content-Type': 'application/json',
            },
        });

        res.status(200).json({ message: '✅ Table created successfully' });
    } catch (err) {
        res.status(500).json({ error: '❌ Failed to create table', details: err.message });
    }
};
