const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const { Pool } = require('pg');

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());

// PostgreSQL Pool setup
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Mock Auth Middleware
const authenticateUser = async (req, res, next) => {
  const userId = req.headers['x-user-id'];
  if (!userId) {
    return res.status(401).json({ error: 'Unauthorized: Missing User ID' });
  }
  try {
    const user = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
    if (user.rows.length === 0) {
      return res.status(401).json({ error: 'Unauthorized: User not found' });
    }
    req.user = user.rows[0];
    next();
  } catch (err) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to Hinga+ Backend API' });
});

// Auth Routes
app.post('/api/auth/login', async (req, res) => {
  const { phone } = req.body;
  if (!phone) return res.status(400).json({ error: 'Phone number required' });

  try {
    let user = await pool.query('SELECT * FROM users WHERE phone = $1', [phone]);
    if (user.rows.length === 0) {
      user = await pool.query('INSERT INTO users (phone) VALUES ($1) RETURNING *', [phone]);
    }
    res.json({ user: user.rows[0], message: 'OTP sent (mocked)' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Weather API
app.get('/api/weather', async (req, res) => {
  const { lat, lon } = req.query;
  if (!lat || !lon) return res.status(400).json({ error: 'Latitude and longitude required' });

  try {
    // Check cache first
    const cache = await pool.query('SELECT * FROM weather_cache WHERE latitude = $1 AND longitude = $2 AND updated_at > NOW() - INTERVAL \'3 hours\'', [lat, lon]);
    if (cache.rows.length > 0) {
      return res.json(cache.rows[0].data);
    }

    // Mock weather from Open-Meteo or similar
    const weatherData = {
      location: 'Rwanda',
      forecast: [
        { day: 'Today', temp: 24, condition: 'Sunny', advice: 'Good day for planting.' },
        { day: 'Tomorrow', temp: 22, condition: 'Cloudy', advice: 'Check soil moisture.' },
        { day: 'Wednesday', temp: 20, condition: 'Rain', advice: 'Avoid spraying pesticides.' },
      ]
    };

    await pool.query('INSERT INTO weather_cache (location, latitude, longitude, data) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING', ['Rwanda', lat, lon, JSON.stringify(weatherData)]);
    res.json(weatherData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Pest Library API
app.get('/api/pests', async (req, res) => {
  try {
    const pests = await pool.query('SELECT * FROM pests');
    res.json(pests.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Sync API (Batch Updates)
app.post('/api/sync', authenticateUser, async (req, res) => {
  const { updates } = req.body; // Array of { table, operation, data }
  if (!updates || !Array.isArray(updates)) return res.status(400).json({ error: 'Invalid updates format' });

  const results = [];
  try {
    for (const update of updates) {
      const { table, operation, data } = update;
      if (table === 'plots') {
        if (operation === 'INSERT' || operation === 'UPDATE') {
          const { id, name, crop, size } = data;
          await pool.query(
            'INSERT INTO plots (id, user_id, name, crop, size, updated_at) VALUES ($1, $2, $3, $4, $5, NOW()) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, crop = EXCLUDED.crop, size = EXCLUDED.size, updated_at = NOW()',
            [id, req.user.id, name, crop, size]
          );
        }
      } else if (table === 'activities') {
        if (operation === 'INSERT' || operation === 'UPDATE') {
          const { id, plot_id, title, date, status } = data;
          await pool.query(
            'INSERT INTO activities (id, plot_id, title, date, status, updated_at) VALUES ($1, $2, $3, $4, $5, NOW()) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, date = EXCLUDED.date, status = EXCLUDED.status, updated_at = NOW()',
            [id, plot_id, title, date, status]
          );
        }
      }
      results.push({ id: data.id, status: 'synced' });
    }

    // Pull latest data for user
    const plots = await pool.query('SELECT * FROM plots WHERE user_id = $1', [req.user.id]);
    const plotIds = plots.rows.map(p => p.id);
    let activities = [];
    if (plotIds.length > 0) {
        const activitiesRes = await pool.query('SELECT * FROM activities WHERE plot_id = ANY($1)', [plotIds]);
        activities = activitiesRes.rows;
    }

    res.json({
      synced: results,
      server_data: {
        plots: plots.rows,
        activities: activities
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

