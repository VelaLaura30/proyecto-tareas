
import { ApiPropertyOptional } from '@nestjs/swagger'; 
import { PartialType } from '@nestjs/mapped-types';
import { CreateTaskDto } from './create-task.dto';

/**
 * DTO para actualizar tareas.
 * Hereda todas las propiedades de CreateTaskDto, pero todas son opcionales.
 * Permite actualizar parcial o totalmente una tarea.
 */
export class UpdateTaskDto extends PartialType(CreateTaskDto) {}
