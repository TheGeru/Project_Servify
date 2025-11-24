// sw.js - Service Worker para Servify
const CACHE_VERSION = 'servify-v1.0.0';
const ANUNCIOS_CACHE = `${CACHE_VERSION}-anuncios`;
const IMAGES_CACHE = `${CACHE_VERSION}-images`;

console.log('[SW] Service Worker cargando...');

// Instalación
self.addEventListener('install', (event) => {
  console.log('[SW] Instalando...');
  self.skipWaiting();
});

// Activación
self.addEventListener('activate', (event) => {
  console.log('[SW] Activando...');
  event.waitUntil(self.clients.claim());
});

// Escuchar mensajes desde la app
self.addEventListener('message', (event) => {
  console.log('[SW] Mensaje recibido:', event.data);
  
  const { action, data } = event.data;

  switch (action) {
    case 'CACHE_ANUNCIO':
      event.waitUntil(cacheAnuncio(data, event.ports[0]));
      break;
      
    case 'REMOVE_ANUNCIO':
      event.waitUntil(removeAnuncioFromCache(data.id, event.ports[0]));
      break;
      
    case 'GET_CACHED_ANUNCIOS':
      event.waitUntil(getCachedAnuncios(event.ports[0]));
      break;
      
    case 'CLEAR_CACHE':
      event.waitUntil(clearAllCaches(event.ports[0]));
      break;
      
    default:
      console.log('[SW] Acción desconocida:', action);
  }
});

// ============================================
// FUNCIONES DE CACHÉ
// ============================================

async function cacheAnuncio(anuncio, port) {
  try {
    console.log('[SW] Cacheando anuncio:', anuncio.titulo);
    
    const cache = await caches.open(ANUNCIOS_CACHE);
    
    // Guardar datos del anuncio como JSON
    const anuncioUrl = `/anuncio/${anuncio.id}`;
    const anuncioResponse = new Response(JSON.stringify(anuncio), {
      headers: { 'Content-Type': 'application/json' }
    });
    await cache.put(anuncioUrl, anuncioResponse);
    
    // Cachear imágenes del anuncio
    if (anuncio.imagenes && anuncio.imagenes.length > 0) {
      const imageCache = await caches.open(IMAGES_CACHE);
      
      for (const imagen of anuncio.imagenes) {
        if (imagen.url) {
          try {
            const imageResponse = await fetch(imagen.url);
            if (imageResponse.ok) {
              await imageCache.put(imagen.url, imageResponse);
              console.log('[SW] Imagen cacheada:', imagen.url);
            }
          } catch (error) {
            console.error('[SW] Error cacheando imagen:', error);
          }
        }
      }
    }
    
    console.log('[SW] ✅ Anuncio cacheado exitosamente:', anuncio.titulo);
    
    // Responder al puerto si existe
    if (port) {
      port.postMessage({ success: true, anuncioId: anuncio.id });
    }
    
    // Notificar a todos los clientes
    const clients = await self.clients.matchAll();
    clients.forEach(client => {
      client.postMessage({
        type: 'ANUNCIO_CACHED',
        anuncioId: anuncio.id
      });
    });
    
  } catch (error) {
    console.error('[SW] ❌ Error cacheando anuncio:', error);
    if (port) {
      port.postMessage({ success: false, error: error.message });
    }
  }
}

async function removeAnuncioFromCache(anuncioId, port) {
  try {
    console.log('[SW] Eliminando anuncio:', anuncioId);
    
    const cache = await caches.open(ANUNCIOS_CACHE);
    await cache.delete(`/anuncio/${anuncioId}`);
    
    console.log('[SW] ✅ Anuncio eliminado del caché:', anuncioId);
    
    if (port) {
      port.postMessage({ success: true, anuncioId });
    }
    
    // Notificar clientes
    const clients = await self.clients.matchAll();
    clients.forEach(client => {
      client.postMessage({
        type: 'ANUNCIO_REMOVED',
        anuncioId: anuncioId
      });
    });
    
  } catch (error) {
    console.error('[SW] ❌ Error eliminando anuncio:', error);
    if (port) {
      port.postMessage({ success: false, error: error.message });
    }
  }
}

async function getCachedAnuncios(port) {
  try {
    console.log('[SW] Obteniendo anuncios cacheados...');
    
    const cache = await caches.open(ANUNCIOS_CACHE);
    const requests = await cache.keys();
    
    const anuncios = [];
    
    for (const request of requests) {
      try {
        const response = await cache.match(request);
        if (response) {
          const data = await response.json();
          anuncios.push(data);
        }
      } catch (e) {
        console.error('[SW] Error procesando anuncio:', e);
      }
    }
    
    console.log('[SW] ✅ Anuncios encontrados:', anuncios.length);
    
    if (port) {
      port.postMessage({ anuncios });
    }
    
  } catch (error) {
    console.error('[SW] ❌ Error obteniendo anuncios:', error);
    if (port) {
      port.postMessage({ anuncios: [] });
    }
  }
}

async function clearAllCaches(port) {
  try {
    const cacheNames = await caches.keys();
    await Promise.all(
      cacheNames.map(cacheName => caches.delete(cacheName))
    );
    
    console.log('[SW] ✅ Todos los cachés eliminados');
    
    if (port) {
      port.postMessage({ success: true });
    }
    
  } catch (error) {
    console.error('[SW] ❌ Error limpiando cachés:', error);
    if (port) {
      port.postMessage({ success: false, error: error.message });
    }
  }
}

console.log('[SW] ✅ Service Worker cargado correctamente');
