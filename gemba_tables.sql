-- Tabla para gestionar las salas de los Gembas (El Administrador las crea)
CREATE TABLE IF NOT EXISTS gemba_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'waiting', -- Puede ser 'waiting', 'in_progress', 'completed'
    admin_name TEXT,
    event_date TEXT,
    shift TEXT,
    areas TEXT,
    pin_code TEXT UNIQUE NOT NULL -- Un PIN numérico corto de 4 o 6 dígitos para que la gente entre fácil
);

-- Habilitar tiempo real para gemba_events
ALTER PUBLICATION supabase_realtime ADD TABLE gemba_events;

-- Tabla para los participantes que entran desde su celular
CREATE TABLE IF NOT EXISTS gemba_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    event_id UUID REFERENCES gemba_events(id) ON DELETE CASCADE,
    participant_name TEXT NOT NULL,
    assigned_section TEXT -- Ej. 'Ergonomía', 'Seguridad', etc. (Se llenará después por el admin o al azar)
);

-- Habilitar tiempo real para gemba_participants
ALTER PUBLICATION supabase_realtime ADD TABLE gemba_participants;

-- Tabla temporal para almacenar acciones levantadas durante la sesión ANTES de cerrar el reporte
CREATE TABLE IF NOT EXISTS gemba_live_actions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    event_id UUID REFERENCES gemba_events(id) ON DELETE CASCADE,
    participant_id UUID REFERENCES gemba_participants(id) ON DELETE CASCADE,
    section TEXT NOT NULL,
    question TEXT NOT NULL,
    action_text TEXT NOT NULL,
    owner TEXT,
    due_date TEXT,
    priority TEXT,
    photo_base64 TEXT -- La foto comprimida en texto (Opcional, puede estar vacía)
);

-- Habilitar tiempo real para gemba_live_actions
ALTER PUBLICATION supabase_realtime ADD TABLE gemba_live_actions;
