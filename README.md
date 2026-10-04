# พร้อม — Mobile Loan Demo

โครงแอปสินเชื่อภาษาไทยสำหรับพัฒนา local ใช้ข้อมูลสังเคราะห์ ยังไม่มีการเข้าสู่ระบบ สมัคร พิจารณา ลงนาม หรือโอนเงินจริง ชื่อพร้อมเป็นชื่อชั่วคราว

ใช้ Expo + React Native + TypeScript, NestJS, Prisma, PostgreSQL ผ่าน Docker และ Next.js สำหรับหลังบ้าน

## โครงสร้าง

- `apps/mobile`: Expo Android; หน้าทดสอบการเชื่อมต่อ API และ DB
- `apps/api`: NestJS, Prisma schema core, migration, seed และ health endpoint
- `apps/admin`: Next.js; หน้าตั้งต้น Demo และลิงก์เอกสาร API

## เตรียม local บน Windows

ใช้ Node.js 22.18+ (ตรวจรอบนี้ด้วย Node 24), pnpm 10.33.0, Docker Desktop Linux containers และ Android SDK/AVD พร้อม Android platform 36, Build Tools 36.0.0, NDK 27.1.12297006 และ CMake 3.22.1 ตรวจ Android SDK path และ ANDROID_HOME ให้ตรงกับเครื่องก่อน build

```powershell
pnpm install --frozen-lockfile
./scripts/init-local-env.ps1
pnpm db:up
pnpm db:migrate
pnpm db:seed
```

สคริปต์สร้าง `.env` และ `apps/api/.env` สำหรับ Demo ในเครื่องโดยใช้รหัสผ่านสุ่มและรักษาไฟล์เดิมไว้ ใช้ `.env.example` เมื่อต้องการตั้งค่าเอง อย่าเปลี่ยน password ใน `.env` หลังสร้าง volume โดยไม่ปรับ DB ด้วย ห้าม commit `.env`

PostgreSQL เปิดเฉพาะ `127.0.0.1:5433` ใช้ฐานข้อมูล `loan_demo`; `pnpm db:stop` หยุดเฉพาะ service นี้โดยเก็บข้อมูลไว้ ไม่ใช้คำสั่งลบ volume เป็นวิธีรันปกติ

## เปิดแอป

เปิดคนละ terminal จาก root:

```powershell
pnpm dev:api
pnpm dev:admin
```

- Admin: http://127.0.0.1:3000
- Health: http://127.0.0.1:3001/api/v1/health
- Swagger: http://127.0.0.1:3001/api/docs

API dev สร้างโค้ดก่อนเปิด watch; หลังแก้ TypeScript ให้รัน `pnpm --filter @loan/api build` ในอีก terminal เพื่อให้ watch โหลดโค้ดใหม่

เปิด Android emulator API 35 หรือใหม่กว่าใน Device Manager จากนั้นเปิด Metro ในอีก terminal ด้วย `pnpm dev:mobile` แล้ว build Android:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
pnpm android
```

ตรวจ JDK ให้ตรงกับ Gradle ที่โครง Expo สร้างก่อนใช้ path ข้างต้น Mobile ใช้ `http://10.0.2.2:3001/api/v1` สำหรับ Android emulator เปลี่ยนผ่าน `apps/mobile/.env` ตาม `.env.example` ได้ ค่านี้เป็น public URL ห้ามใส่ secret ใน `EXPO_PUBLIC_*`

`pnpm dev:mobile` เปิด Expo development client เฉพาะ IPv4 loopback ส่วน `pnpm android` build/ติดตั้งและเปิดแอปโดยไม่เปิด Metro ซ้ำ ใช้ `adb reverse` ให้ emulator โหลดจาก `127.0.0.1:8081` หลัง build ครั้งแรกใช้ `pnpm dev:mobile` แล้วกด `a` ใน terminal เพื่อเปิด development build ที่ติดตั้งไว้ รองรับ local HTTP สำหรับ debug เท่านั้น ก่อน release ต้องกำหนด HTTPS และ production configuration

## ตรวจโค้ด

```powershell
pnpm typecheck
pnpm lint
pnpm format:check
pnpm build
```

`pnpm build` ตรวจ API และ Admin; native build ตรวจแยกด้วย `pnpm android` ไม่มีการถือว่า iOS ผ่านจาก Android
