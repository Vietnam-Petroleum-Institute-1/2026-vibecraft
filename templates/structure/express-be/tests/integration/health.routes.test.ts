import request from 'supertest';

import { testApp } from '../helpers/test-app';

describe('GET /health', () => {
  it('returns 200 and status ok', async () => {
    const res = await request(testApp).get('/health');
    expect(res.status).toBe(200);
    expect((res.body as { data: { status: string } }).data.status).toBe('ok');
  });
});
