
const express = require('express');
const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(express.json());

// =======================
// FIXED CORS MIDDLEWARE
// =======================

const allowedOrigins = [
  "https://frontend.somyap.online",
  "http://frontend.somyap.online"
];

app.use((req, res, next) => {
  const origin = req.headers.origin;

  if (allowedOrigins.includes(origin)) {
    res.setHeader("Access-Control-Allow-Origin", origin);
  }

  res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.setHeader("Access-Control-Allow-Credentials", "true");

  if (req.method === "OPTIONS") {
    return res.sendStatus(200);
  }

  next();
});

// =======================
// END CORS FIX
// =======================

let db;

// Health check for ALB
app.get('/health', (req, res) => {
  res.status(200).send("OK");
});

// DB connect with retry
const connectToDatabase = async () => {
  const maxRetries = 20;
  let retries = 0;

  while (retries < maxRetries) {
    try {
      db = await mysql.createPool({
        host: process.env.MYSQL_HOST,
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
        database: process.env.MYSQL_DATABASE,
        waitForConnections: true,
        connectionLimit: 5,
      });

      await db.query('SELECT 1');
      console.log('Connected to MySQL database');
      break;

    } catch (err) {
      retries++;
      console.log(`MySQL not ready... retrying (${retries}/${maxRetries})`);
      await new Promise(res => setTimeout(res, 3000));
    }
  }

  if (!db) {
    console.error("DB still not reachable, but server will continue running.");
  }
};

app.listen(3500, () => {
  console.log("Backend running on port 3500");
});

connectToDatabase();

// Now add your real API routes below...
