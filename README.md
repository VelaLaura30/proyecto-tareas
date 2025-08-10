# 📋 Proyecto: Gestor de Tareas

Aplicación de Gestión de Tareas – **Prueba Técnica Wagon**  
Proyecto full stack con **aplicación móvil en Flutter** y **backend en NestJS + PostgreSQL**.  
Incluye listado, creación, edición, eliminación y completado de tareas, con despliegue en la nube y documentación.

---

## 📄 Descripción Breve

El **Gestor de Tareas Personal** permite:

- ✅ Ver todas las tareas (pendientes y completadas)  
- ➕ Crear nuevas tareas de forma rápida  
- ✏️ Editar tareas existentes  
- ☑️ Marcar tareas como completadas o pendientes  
- 🗑️ Eliminar tareas  

Cada dispositivo tiene su propio identificador único (`userId`), por lo que las tareas se gestionan de forma aislada para cada usuario sin necesidad de autenticación tradicional.

---

## 🛠️ Instrucciones para Ejecutar Localmente

### 1️⃣ Clonar el repositorio
```bash
git clone https://github.com/VelaLaura30/proyecto-tareas.git
cd proyecto-tareas
```

### 2️⃣ Backend (NestJS)
```bash
cd server
cd task-manager
npm install
```

Crear archivo `.env` en `task-manager/` con:
```env
# Base de datos
DATABASE_URL=URL BASE DE DATOS EN LA NUBE

# Puerto 
PORT=3000

NODE_ENV=production
```

Levantar servidor:
```bash
npm run start:dev
```

### 3️⃣ Base de Datos (PostgreSQL)

El backend creará las tablas automáticamente usando el ORM configurado.  
En producción se recomienda **crear las tablas manualmente** por seguridad. Ejemplo:

```sql
CREATE TABLE IF NOT EXISTS task (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    "userId" VARCHAR(255) NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4️⃣ Frontend Móvil (Flutter)
```bash
cd mobile
cd gestor_tareas
flutter pub get
```

Ejecutar:
```bash
flutter run
```

---

## 📡 API - Endpoints Disponibles

| Método | Endpoint             | Descripción |
|--------|----------------------|-------------|
| GET    | `/tasks/:userId`     | Obtener todas las tareas del usuario |
| POST   | `/tasks`             | Crear una nueva tarea |
| PUT    | `/tasks/:id`         | Editar una tarea existente |
| PATCH  | `/tasks/:id/done`    | Marcar tarea como completada |
| PATCH  | `/tasks/:id/undo`    | Marcar tarea como pendiente |
| DELETE | `/tasks/:id`         | Eliminar una tarea |

> **Nota:** Todas las peticiones requieren que el `userId` (UUID generado por la app) esté presente en el body o en el parámetro correspondiente. Este mecanismo asegura que cada usuario solo acceda a sus propias tareas.

---

##  Backend Desplegado

🔗 **URL**: [https://task-manager-production-27af.up.railway.app](https://task-manager-production-27af.up.railway.app)

---

## 💡 Decisiones Técnicas Importantes

- **Identificación de usuario sin login** → Cada dispositivo genera un `userId` (UUID) único al iniciar la app por primera vez. Este se utiliza en cada petición para aislar los datos del usuario.  
- **NestJS + PostgreSQL** → Robustez, escalabilidad y facilidad de integración con TypeORM.  
- **Flutter** → Experiencia fluida en Android e iOS con un único código base.  
- **Arquitectura limpia en el backend** → Controladores, servicios, DTOs y validaciones para mantener el código mantenible.  
- **Manejo global de errores** → Interceptores en NestJS para respuestas HTTP coherentes.

---

##  Uso de IA en el desarrollo

Este proyecto se desarrolló con apoyo de herramientas de IA como **ChatGPT** y **Claude** para:

- Aclarar dudas sobre implementación en **NestJS** y **Flutter**.  
- Redactar documentación y optimizar secciones de código.  
- Explicar conceptos de Flutter, Dart y NestJS que no conocía previamente.  
- Guiar en el proceso de despliegue y elección de base de datos en la nube.  
- Sugerir ideas para **UI/UX** y mockups.  
- Explicar permisos como conexión a internet y CORS.  
- Dar pautas de buenas prácticas sobre creación automática de tablas.  
- Recordar sobre inyección de dependencias en NestJS.  
- Ejemplificar validaciones en DTOs.

Las interacciones con IA se encuentran en la carpeta `/ai-conversations/`.
