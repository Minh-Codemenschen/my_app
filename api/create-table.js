const SUPABASE_URL = 'https://vzusoizwmnarilhtmzuc.supabase.co';
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const sql = `
    create table if not exists courses (
      id uuid primary key default gen_random_uuid(),
      title text not null,
      created_at timestamp with time zone default now()
    );
  `;

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
                error: '❌ Failed to create table',
                detail: result,
            });
        }

        return res.status(200).json({ message: '✅ Table created!' });
    } catch (err) {
        return res.status(500).json({ error: '❌ Unexpected server error' });
    }
}
