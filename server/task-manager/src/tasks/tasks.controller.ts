import { Controller, Get, Post, Put, Delete, Body, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBody } from '@nestjs/swagger';
import { TasksService } from './tasks.service';
import { Task } from './task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';

@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) { }

 @Get()
  @ApiOperation({ summary: 'Obtener todas las tareas o por usuario' })
  @ApiQuery({
    name: 'userId',
    required: false,
    description: 'Filtra tareas por ID de usuario',
    type: String,
  })
  @ApiResponse({ status: 200, description: 'Lista de tareas obtenida correctamente', type: [Task] })
  getAll(@Query('userId') userId?: string): Promise<Task[]> {
    return userId
      ? this.tasksService.findByUserId(userId)
      : this.tasksService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener una tarea por su ID' })
  @ApiParam({ name: 'id', description: 'ID de la tarea', type: Number })
  @ApiResponse({ status: 200, description: 'Tarea encontrada', type: Task })
  @ApiResponse({ status: 404, description: 'Tarea no encontrada' })
  getOne(@Param('id') id: number): Promise<Task | null> {
    return this.tasksService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Crear una nueva tarea' })
  @ApiBody({ type: CreateTaskDto })
  @ApiResponse({ status: 201, description: 'Tarea creada correctamente', type: Task })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  create(@Body() createTaskDto: CreateTaskDto): Promise<Task> {
    return this.tasksService.create(createTaskDto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Actualizar una tarea existente' })
  @ApiParam({ name: 'id', description: 'ID de la tarea a actualizar', type: Number })
  @ApiBody({ type: UpdateTaskDto })
  @ApiResponse({ status: 200, description: 'Tarea actualizada correctamente', type: Task })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 404, description: 'Tarea no encontrada' })
  async update(@Param('id') id: number, @Body() updateTaskDto: UpdateTaskDto) {
    return this.tasksService.update(id, updateTaskDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar una tarea por su ID' })
  @ApiParam({ name: 'id', description: 'ID de la tarea a eliminar', type: Number })
  @ApiResponse({ status: 200, description: 'Tarea eliminada correctamente' })
  @ApiResponse({ status: 404, description: 'Tarea no encontrada' })
  remove(@Param('id') id: number) {
    return this.tasksService.remove(id);
  }
}
