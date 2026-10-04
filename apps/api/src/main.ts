import "reflect-metadata";
import "dotenv/config";
import { randomUUID } from "node:crypto";
import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { AppModule } from "./app.module";

async function bootstrap() {
  if (process.env.APP_MODE !== "demo")
    throw new Error("Bootstrap supports APP_MODE=demo only");
  if (!process.env.DATABASE_URL) throw new Error("DATABASE_URL is required");
  const port = Number(process.env.PORT ?? "3001");
  if (!Number.isInteger(port) || port < 1024 || port > 65535)
    throw new Error("Invalid PORT");
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix("api/v1");
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.enableShutdownHooks();
  app.enableCors({
    origin: ["http://localhost:3000", "http://127.0.0.1:3000"],
  });
  app.use(
    (
      _req: unknown,
      res: { setHeader: (name: string, value: string) => void },
      next: () => void,
    ) => {
      res.setHeader("X-Correlation-ID", randomUUID());
      next();
    },
  );
  const config = new DocumentBuilder()
    .setTitle("พร้อม — Demo API")
    .setVersion("0.1")
    .build();
  SwaggerModule.setup(
    "api/docs",
    app,
    SwaggerModule.createDocument(app, config),
  );
  await app.listen(port, "0.0.0.0");
}
bootstrap().catch(() => {
  console.error("API startup failed; check local configuration and database");
  process.exitCode = 1;
});
