-- Create ENUM types
CREATE TYPE game_status AS ENUM ('waiting', 'in_progress', 'completed', 'cancelled');
CREATE TYPE game_mode AS ENUM ('multiplayer', 'solo_practice');
CREATE TYPE question_type AS ENUM ('multiple_choice', 'true_false');
CREATE TYPE difficulty_level AS ENUM ('easy', 'medium', 'hard');

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    display_name VARCHAR(100) NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    avatar_url VARCHAR(500),
    total_games_played INTEGER DEFAULT 0,
    total_wins INTEGER DEFAULT 0,
    total_score BIGINT DEFAULT 0,
    highest_score INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen_at TIMESTAMP
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_anonymous ON users(is_anonymous);
CREATE INDEX idx_users_total_score ON users(total_score DESC);

-- Games table
CREATE TABLE IF NOT EXISTS games (
    id SERIAL PRIMARY KEY,
    room_code VARCHAR(10) UNIQUE NOT NULL,
    host_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    status game_status DEFAULT 'waiting',
    mode game_mode DEFAULT 'multiplayer',
    max_players INTEGER DEFAULT 20,
    current_players INTEGER DEFAULT 0,
    questions_per_game INTEGER DEFAULT 10,
    time_per_question INTEGER DEFAULT 30,
    current_question_index INTEGER DEFAULT 0,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_games_room_code ON games(room_code);
CREATE INDEX idx_games_status ON games(status);
CREATE INDEX idx_games_created_at ON games(created_at DESC);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Questions table
CREATE TABLE IF NOT EXISTS questions (
    id SERIAL PRIMARY KEY,
    question_text TEXT NOT NULL,
    question_type question_type DEFAULT 'multiple_choice',
    difficulty difficulty_level DEFAULT 'medium',
    points INTEGER DEFAULT 100,
    time_limit INTEGER DEFAULT 30,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_questions_difficulty ON questions(difficulty);
CREATE INDEX idx_questions_type ON questions(question_type);

-- Answers table
CREATE TABLE IF NOT EXISTS answers (
    id SERIAL PRIMARY KEY,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    answer_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_answers_question_id ON answers(question_id);

-- Question Categories (many-to-many)
CREATE TABLE IF NOT EXISTS question_categories (
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (question_id, category_id)
);

-- Game Categories (many-to-many)
CREATE TABLE IF NOT EXISTS game_categories (
    game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (game_id, category_id)
);

-- Game Questions (which questions are in which game)
CREATE TABLE IF NOT EXISTS game_questions (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    question_order INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_game_questions_game_id ON game_questions(game_id);

-- Game Participants
CREATE TABLE IF NOT EXISTS game_participants (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    wrong_answers INTEGER DEFAULT 0,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    UNIQUE(game_id, user_id)
);

CREATE INDEX idx_game_participants_game_id ON game_participants(game_id);
CREATE INDEX idx_game_participants_user_id ON game_participants(user_id);

-- Player Answers
CREATE TABLE IF NOT EXISTS player_answers (
    id SERIAL PRIMARY KEY,
    game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    answer_id INTEGER REFERENCES answers(id) ON DELETE CASCADE,
    is_correct BOOLEAN DEFAULT FALSE,
    time_to_answer DECIMAL(10, 2),
    points_earned INTEGER DEFAULT 0,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_player_answers_game_id ON player_answers(game_id);
CREATE INDEX idx_player_answers_user_id ON player_answers(user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_games_updated_at BEFORE UPDATE ON games
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
