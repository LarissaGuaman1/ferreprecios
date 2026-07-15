# FerrePrecios — Frontend

Aplicación web desarrollada en **Flutter** que permite a compradores consultar precios de materiales de construcción en ferreterías de Quito, y a dueños de ferreterías gestionar su catálogo de precios.

## Tecnologías

- Flutter 3.x (web)
- Provider (gestión de estado)
- Docker + Nginx (contenedor de producción)
- GitHub Actions (CI/CD)
- GitHub Container Registry (GHCR)
- Docker Swarm + Traefik (orquestación y enrutamiento en VPS)

## URLs en producción

| Servicio | URL |
|---|---|
| Frontend | https://ferreprecios.byronrm.com |
| Backend API | https://api.ferreprecios.byronrm.com/api |

---

## Despliegue paso a paso

### 1. Requisitos previos

- VPS con Docker Swarm inicializado (`docker swarm init`)
- Traefik corriendo en el VPS con la red `traefik-public` creada
- Cuenta en GitHub con acceso al repositorio

### 2. Configurar secrets en GitHub

Ve a **Settings → Secrets and variables → Actions** del repositorio y agrega:

| Secret | Descripción |
|---|---|
| `GHCR_TOKEN` | Personal Access Token con permisos `write:packages` y `read:packages` |
| `VPS_HOST` | IP del VPS (ej. `46.224.5.181`) |
| `VPS_USER` | Usuario SSH del VPS (ej. `larissa`) |
| `VPS_PORT` | Puerto SSH (generalmente `22`) |
| `VPS_PASSWORD` | Contraseña SSH del VPS |

#### Cómo crear el GHCR_TOKEN

1. GitHub → foto de perfil → **Settings**
2. **Developer settings → Personal access tokens → Tokens (classic)**
3. **Generate new token (classic)**
4. Marcar: `write:packages`, `read:packages`, `delete:packages`
5. Sin fecha de expiración (No expiration)
6. Copiar el token y pegarlo como secret `GHCR_TOKEN`

### 3. Configurar la red de Traefik en el VPS

Conéctate al VPS por SSH y ejecuta una sola vez:

```bash
docker network create --driver overlay traefik-public
```

### 4. Despliegue automático (GitHub Actions)

Cada vez que haces `git push` a la rama `main`, el workflow `.github/workflows/deploy.yml` ejecuta automáticamente:

1. Descarga el código del repositorio
2. Instala Flutter y compila la app web (`flutter build web --release`)
3. Construye la imagen Docker con Nginx
4. Publica la imagen en GHCR: `ghcr.io/larissaguaman1/ferreprecios-frontend:latest`
5. Copia el `stack.yml` al VPS vía SCP
6. Conecta al VPS por SSH y ejecuta `docker stack deploy`

```bash
# El workflow hace esto automáticamente, pero puedes hacerlo manual desde el VPS:
cd ~/ferreprecios-web-deploy
docker pull ghcr.io/larissaguaman1/ferreprecios-frontend:latest
docker stack deploy -c stack.yml ferreprecios-web
```

### 5. Redesplegar manualmente (si el stack se cae)

Conéctate al VPS por SSH y ejecuta:

```bash
cd ~/ferreprecios-web-deploy
docker pull ghcr.io/larissaguaman1/ferreprecios-frontend:latest
docker stack deploy -c stack.yml ferreprecios-web
```

### 6. Verificar que el servicio está corriendo

```bash
docker service ls
# ferreprecios-web_ferreprecios-web debe mostrar 1/1 en REPLICAS
```

---

## Desarrollo local

```bash
# Instalar dependencias
flutter pub get

# Correr en modo desarrollo (puerto 4000)
flutter run -d chrome --web-port 4000
```

> La app apunta a `https://api.ferreprecios.byronrm.com/api` en producción.  
> Para desarrollo local, cambia `_baseUrl` en `lib/core/services/api_service.dart`.

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── services/        # ApiService (HTTP client con JWT)
│   ├── theme/           # Colores, estilos, componentes globales
│   └── navigation/      # MainShell (navegación por pestañas)
└── features/
    ├── auth/            # Login, registro, provider de autenticación
    ├── materiales/      # Búsqueda y detalle de materiales
    ├── ferreterias/     # Lista, mapa y gestión de ferreterías
    ├── reportes/        # Formulario para reportar precios
    └── perfil/          # Perfil del usuario, puntos y reportes
```
