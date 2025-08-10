import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { TasksModule } from './tasks/tasks.module';
import { Task } from './tasks/task.entity';

@Module({
  imports: [
    // Configuración para variables de entorno
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    
    // Configuración de base de datos
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL || 'NO_DATABASE_URL_FOUND', // Debug temporal
      entities: [Task],
      synchronize: process.env.NODE_ENV !== 'production',
      ssl: process.env.DATABASE_URL ? { rejectUnauthorized: false } : false,
      // Logging para ver qué está pasando
      logging: true,
    }),
    
    TasksModule,
  ],
})
export class AppModule {
  constructor() {
    // Debug temporal - QUITAR después
    console.log('🔍 DATABASE_URL:', process.env.DATABASE_URL ? 'EXISTE' : 'NO EXISTE');
    console.log('🔍 NODE_ENV:', process.env.NODE_ENV);
    console.log('🔍 Todas las variables:', Object.keys(process.env).filter(key => key.includes('DATABASE')));
  }
}