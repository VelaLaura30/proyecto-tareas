import { IsString, IsBoolean, IsOptional, Length } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * DTO para la creación de tareas.
 * Contiene los campos que se pueden enviar al crear una tarea.
 * Incluye validaciones y documentación para Swagger.
 */
export class CreateTaskDto {
  @ApiProperty({
    description: 'Título de la tarea',
    example: 'Comprar leche',
  })
  @IsString({ message: 'El título debe ser texto' })
  @Length(2, 50, { message: 'El título debe tener entre 2 y 50 caracteres' })
  title: string;

  @ApiPropertyOptional({
    description: 'Descripción detallada de la tarea',
    example: 'Comprar leche en el supermercado cerca de casa',
    maxLength: 200,
  })
  @IsString({ message: 'La descripción debe ser texto' })
  @IsOptional()
  @Length(0, 200, { message: 'La descripción no debe exceder 200 caracteres' })
  description?: string;

  @ApiPropertyOptional({
    description: 'Estado de la tarea: completada o no',
    example: false,
    default: false,
  })
  @IsBoolean({ message: 'El campo completed debe ser verdadero o falso' })
  @IsOptional()
  completed?: boolean = false;

  @ApiPropertyOptional({
    description: 'ID del usuario propietario de la tarea',
    example: '1234567890abcdef',
  })
  @IsString()
  @IsOptional()
  userId?: string;
}

