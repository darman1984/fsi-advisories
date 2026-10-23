// 비밀번호를 확인한 사람에게만 지식 그래프와 온톨로지 데이터를 내줘요(Vercel 함수, Node 22, 패키지 없음).
// POST /api/data  {"password": "..."}  → 200 {advisories, products, follows, ontology_concepts, ontology_relations}
// 비밀번호는 Vercel 환경 변수 SITE_PASSWORD에 둬요. 비밀번호와 IP는 저장하지도 로그에 찍지도 않아요.
import { createHash, timingSafeEqual } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';

const FILES = ['advisories', 'products', 'follows', 'ontology_concepts', 'ontology_relations'];
const MAX_BODY = 4096;

function reply(status, body) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' },
  });
}

// 길이가 달라도 견주는 시간이 같도록 해시끼리 견줘요
function same(a, b) {
  return timingSafeEqual(createHash('sha256').update(a).digest(), createHash('sha256').update(b).digest());
}

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

export async function GET() {
  return reply(405, { error: 'POST로 비밀번호를 보내 주세요.' });
}

export async function POST(request) {
  const expected = process.env.SITE_PASSWORD;
  if (!expected) {
    return reply(500, { error: '사이트 비밀번호가 아직 설정되지 않았어요. Vercel 프로젝트의 환경 변수 SITE_PASSWORD를 넣고 다시 배포해 주세요.' });
  }
  const type = (request.headers.get('content-type') || '').split(';')[0].trim().toLowerCase();
  if (type !== 'application/json') return reply(415, { error: 'application/json으로 보내 주세요.' });

  const bytes = new Uint8Array(await request.arrayBuffer());
  if (bytes.length > MAX_BODY) return reply(413, { error: '요청 본문이 너무 커요.' });
  let password = '';
  try {
    const value = JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(bytes));
    password = typeof value?.password === 'string' ? value.password : '';
  } catch {
    return reply(400, { error: '요청을 읽지 못했어요. 비밀번호를 다시 넣어 주세요.' });
  }
  if (!password || !same(password, expected)) {
    await wait(600); // 마구 넣어 보기를 늦춰요
    return reply(401, { error: '비밀번호가 맞지 않아요. 다시 넣어 주세요.' });
  }

  try {
    const dir = join(process.cwd(), 'private-data');
    const body = {};
    for (const name of FILES) {
      const text = await readFile(join(dir, `${name}.json`), 'utf8');
      body[name] = JSON.parse(text.replace(/^﻿/, ''));
    }
    return reply(200, body);
  } catch (error) {
    console.error('private-data를 읽지 못함:', error.message);
    return reply(500, { error: '데이터 파일을 읽지 못했어요. 잠시 뒤 다시 시도해 주세요.' });
  }
}
