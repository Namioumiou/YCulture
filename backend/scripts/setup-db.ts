#!/usr/bin/env node

/**
 * Database Setup Script
 * 
 * This script will:
 * 1. Connect to PostgreSQL
 * 2. Drop existing database (if --reset flag is provided)
 * 3. Create database
 * 4. Run all migrations
 * 5. Run all seed files (if --seed flag is provided)
 */

import { Client } from 'pg';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const config = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'yculture_user',
  password: process.env.DB_PASSWORD || 'yculture_password_dev',
  database: process.env.DB_NAME || 'yculture_db',
};

const args = process.argv.slice(2);
const shouldReset = args.includes('--reset');
const shouldSeed = args.includes('--seed');

async function runSQL(client: Client, sql: string, description: string) {
  try {
    console.log(`⏳ ${description}...`);
    await client.query(sql);
    console.log(`✅ ${description} - Done`);
  } catch (error: any) {
    console.error(`❌ ${description} - Failed:`, error.message);
    throw error;
  }
}

async function runSQLFile(client: Client, filePath: string) {
  const fileName = path.basename(filePath);
  const sql = fs.readFileSync(filePath, 'utf8');
  await runSQL(client, sql, `Running ${fileName}`);
}

async function setupDatabase() {
  console.log('🚀 YCulture Database Setup\n');

  // First, connect to postgres database to create/drop our database
  const adminClient = new Client({
    ...config,
    database: 'postgres', // Connect to default postgres db
  });

  try {
    await adminClient.connect();
    console.log('✅ Connected to PostgreSQL server\n');

    if (shouldReset) {
      console.log('⚠️  RESET MODE: Dropping existing database...\n');
      
      // Terminate existing connections
      await runSQL(
        adminClient,
        `SELECT pg_terminate_backend(pid) 
         FROM pg_stat_activity 
         WHERE datname = '${config.database}' AND pid <> pg_backend_pid();`,
        'Terminating existing connections'
      );

      // Drop database
      await runSQL(
        adminClient,
        `DROP DATABASE IF EXISTS ${config.database};`,
        'Dropping database'
      );
    }

    // Create database
    await runSQL(
      adminClient,
      `CREATE DATABASE ${config.database};`,
      'Creating database'
    );

    await adminClient.end();
    console.log('\n📊 Database created. Running migrations...\n');

    // Now connect to our new database to run migrations
    const client = new Client(config);
    await client.connect();

    // Run migrations
    const migrationsDir = path.join(__dirname, '..', 'database', 'migrations');
    const migrationFiles = fs
      .readdirSync(migrationsDir)
      .filter((f) => f.endsWith('.sql'))
      .sort();

    console.log(`Found ${migrationFiles.length} migration(s)\n`);

    for (const file of migrationFiles) {
      const filePath = path.join(migrationsDir, file);
      await runSQLFile(client, filePath);
    }

    // Run seeds if requested
    if (shouldSeed) {
      console.log('\n🌱 Seeding database...\n');
      const seedsDir = path.join(__dirname, '..', 'database', 'seeds');
      
      if (fs.existsSync(seedsDir)) {
        const seedFiles = fs
          .readdirSync(seedsDir)
          .filter((f) => f.endsWith('.sql'))
          .sort();

        console.log(`Found ${seedFiles.length} seed file(s)\n`);

        for (const file of seedFiles) {
          const filePath = path.join(seedsDir, file);
          await runSQLFile(client, filePath);
        }
      }
    }

    await client.end();

    console.log('\n✨ Database setup completed successfully!\n');
    console.log('Connection details:');
    console.log(`  Host: ${config.host}`);
    console.log(`  Port: ${config.port}`);
    console.log(`  Database: ${config.database}`);
    console.log(`  User: ${config.user}\n`);

    if (shouldSeed) {
      console.log('🎮 Sample data loaded:');
      console.log('  - 8 categories');
      console.log('  - 10 sample questions');
      console.log('  - Test user: test@example.com / password: test123\n');
    }

  } catch (error: any) {
    console.error('\n❌ Database setup failed:', error.message);
    process.exit(1);
  }
}

// Run the setup
setupDatabase();
