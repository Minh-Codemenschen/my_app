const SUPABASE_URL = 'https://vzusoizwmnarilhtmzuc.supabase.co';
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export default async function handler(req, res) {
    let sql = '';

    if (req.method === 'GET') {
        sql = req.query.sql;
    } else if (req.method === 'POST') {
        sql = req.body.sql;
    } else {
        return res.status(405).json({ error: 'Method not allowed. Use GET or POST' });
    }

    if (!sql) {
        return res.status(400).json({ error: 'Missing SQL query. Provide it via query param (?sql=...) or JSON body { sql: "..." }' });
    }

    try {
        const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/execute_sql`, {
            method: 'POST',
            headers: {
                apikey: SERVICE_ROLE_KEY,
                Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ sql }),
        });

        const result = await response.json();

        if (!response.ok) {
            return res.status(500).json({
                error: '❌ Failed to execute SQL',
                detail: result,
            });
        }

        return res.status(200).json({ message: '✅ SQL executed successfully' });
    } catch (err) {
        return res.status(500).json({ error: '❌ Unexpected server error', details: err.message });
    }
}
