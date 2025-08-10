import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task } from './task.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private tasksRepository: Repository<Task>,
  ) {}

  /**
   * Obtiene todas las tareas de la base de datos.
   * @returns {Promise<Task[]>} Lista de tareas.
   */
  findAll(): Promise<Task[]> {
    return this.tasksRepository.find();
  }

  /**
   * Obtiene todas las tareas filtradas por el ID de usuario.
   * @param {string} userId - ID del usuario para filtrar las tareas.
   * @returns {Promise<Task[]>} Lista de tareas del usuario.
   */
  findByUserId(userId: string): Promise<Task[]> {
    return this.tasksRepository.find({
      where: { userId },
      order: { id: 'DESC' },
    });
  }

  /**
   * Obtiene una tarea por su ID.
   * @param {number} id - ID de la tarea.
   * @returns {Promise<Task | null>} La tarea encontrada o null si no existe.
   */
  findOne(id: number): Promise<Task | null> {
    return this.tasksRepository.findOneBy({ id });
  }

  /**
   * Crea una nueva tarea en la base de datos.
   * @param {Partial<Task>} task - Datos de la tarea a crear.
   * @returns {Promise<Task>} La tarea creada.
   */
  create(task: Partial<Task>): Promise<Task> {
    const newTask = this.tasksRepository.create(task);
    return this.tasksRepository.save(newTask);
  }

  /**
   * Actualiza una tarea existente.
   * @param {number} id - ID de la tarea a actualizar.
   * @param {Partial<Task>} task - Datos actualizados de la tarea.
   * @returns {Promise<Task>} La tarea actualizada.
   * @throws {Error} Si la tarea con el ID especificado no existe.
   */
  async update(id: number, task: Partial<Task>): Promise<Task> {
    const existingTask = await this.tasksRepository.findOneBy({ id });

    if (!existingTask) {
      throw new Error(`Tarea con ID ${id} no encontrada`);
    }

    const updatedTask = this.tasksRepository.merge(existingTask, task);

    return await this.tasksRepository.save(updatedTask);
  }

  /**
   * Elimina una tarea por su ID.
   * @param {number} id - ID de la tarea a eliminar.
   * @returns {Promise<void>}
   */
  async remove(id: number): Promise<void> {
    await this.tasksRepository.delete(id);
  }
}
