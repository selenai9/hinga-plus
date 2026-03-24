-- Hinga+ Database Schema

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Plots table
CREATE TABLE IF NOT EXISTS plots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    crop VARCHAR(100),
    size DECIMAL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Activities table
CREATE TABLE IF NOT EXISTS activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- pending, completed, cancelled
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Pests table (Static Library)
CREATE TABLE IF NOT EXISTS pests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    crop VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    treatment TEXT,
    image_url TEXT
);

-- Weather Cache table
CREATE TABLE IF NOT EXISTS weather_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location VARCHAR(200) NOT NULL,
    latitude DECIMAL NOT NULL,
    longitude DECIMAL NOT NULL,
    data JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sync Queue table (Server-side tracking for conflicts or logging)
CREATE TABLE IF NOT EXISTS sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    record_id UUID NOT NULL,
    status VARCHAR(20) DEFAULT 'synced',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Seed data for Pests
INSERT INTO pests (crop, name, description, treatment) VALUES 
('Maize', 'Fall Armyworm', 'Small green/brown caterpillars that eat maize leaves.', 'Apply Neem oil or appropriate organic pesticides early in the morning.'),
('Beans', 'Bean Aphids', 'Small black insects found on stems and leaves.', 'Spray with soapy water or encourage ladybugs.'),
('Potato', 'Late Blight', 'Fungal disease causing dark spots on leaves and tubers.', 'Ensure good drainage and use blight-resistant varieties.');

