# Hoja de Ruta para Integración de Backend y Autenticación Segura
## Hotel Boutique María Morelia

Este documento describe la arquitectura técnica necesaria para transformar el portal de empleados y el catálogo del **Hotel Boutique María Morelia** de una previsualización estática a un sistema de producción 100% seguro y persistente en la nube.

---

## 1. Diagnóstico de la Arquitectura Actual

Actualmente el proyecto está desplegado como un **sitio web estático en Vercel** (`HTML5`, `Tailwind CSS`, `JavaScript vanilla`):
- **Ventajas:** Carga ultrarrápida, escalabilidad mundial, costo cero de servidor para tráfico web, diseño e interactividad fluidos.
- **Limitación de seguridad para usuarios privados:** Los navegadores web no pueden ejecutar código confidencial por sí solos ni almacenar secretos, ya que todo el código JavaScript que corre en el cliente es inspeccionable. Ocultar botones en el frontend no protege los datos sin una validación estricta en el servidor (*Server-Side Authorization*).

---

## 2. Proveedor Recomendado: Supabase (PostgreSQL + Auth + Storage)

Para mantener la velocidad de Vercel y no requerir el mantenimiento de servidores VPS tradicionales, la solución estándar en hotelería moderna es **Supabase** (Plataforma Serverless de código abierto sobre PostgreSQL):

| Necesidad del Hotel | Solución con Supabase |
| :--- | :--- |
| **Autenticación segura** | Manejo de contraseñas con hash `bcrypt`/`argon2`, sesiones JWT cifradas y flujo de invitación por correo. |
| **Control de Rangos (RBAC)** | Asignación de roles (`admin`, `gerente`, `recepcion`, `empleado`) que se validan en la base de datos mediante **Row Level Security (RLS)**. |
| **Persistencia de Precios y Suites** | Tabla relacional `rooms` con tarifas que se sincronizan en vivo tanto en el panel como en la web pública. |
| **Almacenamiento de Fotografías** | Bucket de Supabase Storage con CDN para subir, optimizar y sustituir imágenes de alta resolución. |
| **Despliegue e Integración** | Compatible con Vercel en 1 clic y con plan gratuito que cubre con creces el volumen del hotel. |

*Alternativa viable:* **Firebase** (Google Cloud) con Firebase Authentication + Firestore + Firebase Storage.

---

## 3. Modelo de Base de Datos Propuesto (PostgreSQL)

```sql
-- 1. Enum de Rangos del Hotel
CREATE TYPE user_role AS ENUM ('admin', 'gerente', 'recepcion', 'empleado');

-- 2. Tabla de Perfiles de Empleados
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  role user_role NOT NULL DEFAULT 'empleado',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Tabla de Habitaciones y Tarifas
CREATE TABLE public.rooms (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price_per_night NUMERIC(10,2) NOT NULL,
  original_price NUMERIC(10,2) NOT NULL,
  capacity TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'Disponible',
  updated_by UUID REFERENCES public.profiles(id),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Tabla de Galería de Fotografías
CREATE TABLE public.gallery_images (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT NOT NULL,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Tabla de Registro de Auditoría (Bitácora de Seguridad)
CREATE TABLE public.audit_logs (
  id BIGSERIAL PRIMARY KEY,
  actor_id UUID REFERENCES public.profiles(id),
  action TEXT NOT NULL,
  details JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

## 4. Políticas de Seguridad a Nivel de Fila (Row Level Security - RLS)

Las políticas RLS garantizan que **ningún empleado pueda modificar datos sin el rango correspondiente**, incluso si manipulan el navegador:

```sql
-- Habilitar RLS en todas las tablas
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery_images ENABLE ROW LEVEL SECURITY;

-- REGLA 1: Lectura pública de habitaciones e imágenes (para los huéspedes del sitio web)
CREATE POLICY "Public Read Rooms" ON public.rooms FOR SELECT USING (true);
CREATE POLICY "Public Read Gallery" ON public.gallery_images FOR SELECT USING (true);

-- REGLA 2: Solo Administradores y Gerentes pueden modificar precios
CREATE POLICY "Admin and Gerente Update Rooms" ON public.rooms
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'gerente')
      AND profiles.is_active = true
    )
  );

-- REGLA 3: Solo el Administrador puede invitar o cambiar rangos a otros empleados
CREATE POLICY "Admin Manage Profiles" ON public.profiles
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
      AND profiles.is_active = true
    )
  );

-- REGLA 4: Cada empleado solo puede leer su propio perfil
CREATE POLICY "Staff Read Own Profile" ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);
```

---

## 5. Variables de Entorno Necesarias

Cuando se active el backend, se configurarán en el panel de **Vercel** (`Settings > Environment Variables`):

```bash
# Variables Públicas (Cliente)
NEXT_PUBLIC_SUPABASE_URL=https://tu-proyecto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Variable Privada de Servidor (Solo para Vercel Serverless Functions / Invitaciones)
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 6. Proceso de Implementación en Producción

1. **Crear proyecto en Supabase:** Registrar cuenta gratuita en [supabase.com](https://supabase.com).
2. **Ejecutar el esquema SQL:** Pegar el script anterior en el SQL Editor de Supabase.
3. **Crear el primer usuario Administrador:** Invitarlo directamente desde `Authentication > Users` con el rol `admin`.
4. **Vincular en Vercel:** Instalar la integración oficial de Supabase para Vercel o agregar las variables de entorno.
5. **Conectar en empleados.html:** Sustituir los métodos de demostración por llamadas al SDK oficial `@supabase/supabase-js`.
