import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

/**
 * Entidad Task que representa una tarea en la base de datos.
 */
@Entity()
export class Task {
   /**
   * Identificador único de la tarea (clave primaria autoincremental).
   */
  @PrimaryGeneratedColumn()
  id: number;

    /**
   * Título de la tarea.
   */
  @Column()
  title: string;

    /**
   * Descripción detallada de la tarea.
   */
  @Column()
  description: string;

    /**
   * Indica si la tarea está completada o no.
   * Valor por defecto: false.
   */
  @Column({ default: false })
  completed: boolean;

    /**
   * ID del usuario propietario de la tarea.
   * Puede ser nulo (opcional).
   */
  @Column({ nullable: true })
  userId: string;
}