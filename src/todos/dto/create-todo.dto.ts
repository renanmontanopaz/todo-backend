import { IsString, IsOptional, IsBoolean } from 'class-validator';

export class CreateTodoDto {
  @IsString()
  title: string;

  @IsBoolean()
  @IsOptional()
  completed?: boolean;
}