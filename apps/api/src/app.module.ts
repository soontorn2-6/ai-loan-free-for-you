import {
  Controller,
  Get,
  Module,
  Res,
  ServiceUnavailableException,
} from "@nestjs/common";
import {
  ApiOkResponse,
  ApiServiceUnavailableResponse,
  ApiTags,
} from "@nestjs/swagger";
import { PrismaService } from "./prisma.service";

@ApiTags("health")
@Controller("health")
class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @ApiOkResponse({ description: "Demo API and database available" })
  @ApiServiceUnavailableResponse({ description: "Database unavailable" })
  async health(
    @Res({ passthrough: true })
    response: {
      setHeader: (name: string, value: string) => void;
    },
  ) {
    response.setHeader("Cache-Control", "no-store");
    try {
      await this.prisma.$queryRaw`SELECT 1`;
    } catch {
      throw new ServiceUnavailableException({
        status: "unavailable",
        database: "down",
        mode: "demo",
      });
    }
    return { status: "ok", database: "up", mode: "demo" };
  }
}

@Module({ controllers: [HealthController], providers: [PrismaService] })
export class AppModule {}
