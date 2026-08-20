// ============================================================
// app.test.js – kleine Tests für die Express-App
// ============================================================
// Läuft mit "npm test" (Jest + supertest). Startet dafür KEINEN
// echten Server auf Port 3000, sondern testet die Express-App
// direkt im Speicher — genau deshalb ist app.js von server.js
// getrennt.

const request = require('supertest');
const app = require('./app');

describe('GET /health', () => {
  it('antwortet mit Status 200 und Text "OK"', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.text).toBe('OK');
  });
});

describe('GET /', () => {
  it('antwortet mit Status 200', async () => {
    const res = await request(app).get('/');
    expect(res.status).toBe(200);
  });

  it('zeigt die Docker-Beispielprojekt-Meldung an', async () => {
    const res = await request(app).get('/');
    expect(res.text).toContain('Docker-Beispielprojekt läuft');
  });
});
