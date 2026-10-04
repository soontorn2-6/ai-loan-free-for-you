import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client';

if (process.env.APP_MODE !== 'demo') throw new Error('Seed requires APP_MODE=demo');
const url = new URL(process.env.DATABASE_URL ?? '');
if (!['localhost', '127.0.0.1'].includes(url.hostname) || url.pathname !== '/loan_demo') {
  throw new Error('Seed is restricted to the local loan_demo database');
}
const prisma = new PrismaClient({ adapter: new PrismaPg({ connectionString: url.href }) });
async function seed() {
  await prisma.$transaction(async (tx) => {
    const borrower = await tx.user.upsert({ where: { demoAlias: 'demo-borrower' }, update: {}, create: { demoAlias: 'demo-borrower', role: 'BORROWER' } });
    await tx.borrowerProfile.upsert({ where: { userId: borrower.id }, update: {}, create: { userId: borrower.id, displayName: 'ผู้ใช้จำลอง' } });
    await tx.user.upsert({ where: { demoAlias: 'demo-officer' }, update: {}, create: { demoAlias: 'demo-officer', role: 'OFFICER' } });
    await tx.application.upsert({ where: { id: '00000000-0000-4000-8000-000000000001' }, update: {}, create: { id: '00000000-0000-4000-8000-000000000001', borrowerId: borrower.id, requestedAmount: '20000.00', termMonths: 12, productVersionId: 'demo-pending-pricing-v1' } });
  });
  console.log('Synthetic local fixtures ready');
}
seed().catch(() => { console.error('Seed failed; inspect local database configuration'); process.exitCode = 1; }).finally(() => prisma.$disconnect());
