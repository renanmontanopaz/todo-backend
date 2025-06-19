import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
//controller
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  async getTodos() {
    return this.appService.getTodos();
  }
}
