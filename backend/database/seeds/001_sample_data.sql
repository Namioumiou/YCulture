-- Insert sample categories
INSERT INTO categories (name, description) VALUES
    ('General Knowledge', 'Questions about general culture and knowledge'),
    ('History', 'Historical events and figures'),
    ('Geography', 'Countries, cities, and places around the world'),
    ('Science', 'Scientific facts and discoveries'),
    ('Art & Literature', 'Books, paintings, and artistic works'),
    ('Music', 'Songs, artists, and musical knowledge'),
    ('Movies & TV', 'Films, series, and entertainment'),
    ('Sports', 'Sports, athletes, and competitions')
ON CONFLICT DO NOTHING;

-- Insert sample questions
INSERT INTO questions (question_text, question_type, difficulty, points, time_limit) VALUES
    ('What is the capital of France?', 'multiple_choice', 'easy', 100, 30),
    ('In which year did World War II end?', 'multiple_choice', 'medium', 200, 30),
    ('What is the largest planet in our solar system?', 'multiple_choice', 'easy', 100, 30),
    ('Who painted the Mona Lisa?', 'multiple_choice', 'easy', 100, 30),
    ('The Great Wall of China is visible from space.', 'true_false', 'medium', 150, 20),
    ('What is the smallest country in the world?', 'multiple_choice', 'medium', 200, 30),
    ('Who wrote "Romeo and Juliet"?', 'multiple_choice', 'easy', 100, 30),
    ('The human body has 206 bones.', 'true_false', 'easy', 100, 20),
    ('What is the chemical symbol for gold?', 'multiple_choice', 'medium', 200, 30),
    ('Mount Everest is located in which mountain range?', 'multiple_choice', 'medium', 200, 30)
ON CONFLICT DO NOTHING;

-- Insert answers for question 1: Capital of France
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (1, 'Paris', true, 1),
    (1, 'London', false, 2),
    (1, 'Berlin', false, 3),
    (1, 'Madrid', false, 4);

-- Insert answers for question 2: WW2 end year
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (2, '1945', true, 1),
    (2, '1944', false, 2),
    (2, '1943', false, 3),
    (2, '1946', false, 4);

-- Insert answers for question 3: Largest planet
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (3, 'Jupiter', true, 1),
    (3, 'Saturn', false, 2),
    (3, 'Neptune', false, 3),
    (3, 'Earth', false, 4);

-- Insert answers for question 4: Mona Lisa painter
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (4, 'Leonardo da Vinci', true, 1),
    (4, 'Michelangelo', false, 2),
    (4, 'Pablo Picasso', false, 3),
    (4, 'Vincent van Gogh', false, 4);

-- Insert answers for question 5: Great Wall visible from space (True/False)
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (5, 'False', true, 1),
    (5, 'True', false, 2);

-- Insert answers for question 6: Smallest country
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (6, 'Vatican City', true, 1),
    (6, 'Monaco', false, 2),
    (6, 'San Marino', false, 3),
    (6, 'Liechtenstein', false, 4);

-- Insert answers for question 7: Romeo and Juliet author
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (7, 'William Shakespeare', true, 1),
    (7, 'Charles Dickens', false, 2),
    (7, 'Jane Austen', false, 3),
    (7, 'Mark Twain', false, 4);

-- Insert answers for question 8: Human bones count (True/False)
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (8, 'True', true, 1),
    (8, 'False', false, 2);

-- Insert answers for question 9: Gold symbol
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (9, 'Au', true, 1),
    (9, 'Ag', false, 2),
    (9, 'Fe', false, 3),
    (9, 'Cu', false, 4);

-- Insert answers for question 10: Mount Everest location
INSERT INTO answers (question_id, answer_text, is_correct, display_order) VALUES
    (10, 'Himalayas', true, 1),
    (10, 'Alps', false, 2),
    (10, 'Andes', false, 3),
    (10, 'Rockies', false, 4);

-- Link questions to categories
INSERT INTO question_categories (question_id, category_id) VALUES
    (1, 3),  -- Geography
    (2, 2),  -- History
    (3, 4),  -- Science
    (4, 5),  -- Art & Literature
    (5, 1),  -- General Knowledge
    (6, 3),  -- Geography
    (7, 5),  -- Art & Literature
    (8, 4),  -- Science
    (9, 4),  -- Science
    (10, 3); -- Geography

-- Create a test user (password: "test123")
INSERT INTO users (username, email, password_hash, display_name, is_anonymous) VALUES
    ('testuser', 'test@example.com', '$2b$10$rKvVXhI4pZ8yD1xG0xD1J.zGqXHfQZ5yP5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z', 'Test User', false)
ON CONFLICT DO NOTHING;
