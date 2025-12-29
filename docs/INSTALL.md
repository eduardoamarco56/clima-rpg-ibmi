# 📦 Guía de Instalación Detallada

## Requisitos Previos

### 1. Software en IBM i

- **IBM i V7R3 o superior**
- **Apache HTTP Server** instalado y configurado
- **CGIDEV2** instalado
- **HTTPAPI** de Scott Klement instalado

### 2. Verificar instalaciones

```bash
# Verificar Apache
WRKACTJOB SBS(QHTTPSVR)

# Verificar CGIDEV2
WRKOBJ OBJ(CGIDEV2/*ALL)

# Verificar HTTPAPI
WRKOBJ OBJ(LIBHTTP/HTTPAPIR4) OBJTYPE(*SRVPGM)
```

## Instalación Paso a Paso

### Paso 1: Instalar CGIDEV2 (si no está instalado)

```bash
# Descargar de http://www.easy400.net/cgidev2/
# Seguir instrucciones del sitio
```

### Paso 2: Instalar HTTPAPI (si no está instalado)

```bash
# Descargar de http://www.scottklement.com/httpapi/
# Seguir instrucciones del sitio
```

### Paso 3: Configurar Apache

#### 3.1 Editar httpd.conf

```bash
# Ubicación típica
nano /www/tu-instancia/conf/httpd.conf
```

#### 3.2 Agregar configuración CGI

```apache
# Mapeo de programas CGI
ScriptAliasMatch /pub/(.*)\.net(.*)  /QSYS.LIB/TULIB.LIB/$1.PGM$2

# Configuración del directorio
<Directory /QSYS.LIB/TULIB.LIB>
   order allow,deny
   allow from all
   SetEnv QIBM_CGI_LIBRARY_LIST "QTEMP;TULIB;CGIDEV2;LIBHTTP;QGPL;"
   
   # Autenticación (opcional)
   Require valid-user
   UserId %%CLIENT%%
   PasswdFile %%SYSTEM%%
   AuthType Basic
   AuthName "Clima App"
</Directory>
```

#### 3.3 Reiniciar Apache

```bash
ENDTCPSVR SERVER(*HTTP) HTTPSVR(TU_INSTANCIA)
STRTCPSVR SERVER(*HTTP) HTTPSVR(TU_INSTANCIA)
```

### Paso 4: Obtener API Key de OpenWeatherMap

1. Ir a https://openweathermap.org/api
2. Crear cuenta gratuita
3. Generar API Key
4. Copiar la key (ejemplo: `034c4473ecc2980dcd73e7350770815e`)

### Paso 5: Configurar el código

#### 5.1 Editar CLIMAREAL.RPGLE

Abrir `src/CLIMAREAL.RPGLE` y modificar línea 70:

```rpg
// Cambiar esto:
apiKey = 'TU_API_KEY_AQUI';

// Por tu API key real:
apiKey = '034c4473ecc2980dcd73e7350770815e';
```

### Paso 6: Transferir archivos a IBM i

#### Opción A: SCP (recomendado)

```bash
scp src/CLIMAREAL.RPGLE usuario@ibmi:/home/usuario/
```

#### Opción B: FTP

```bash
ftp ibmi
# Usuario y password
put src/CLIMAREAL.RPGLE /home/usuario/CLIMAREAL.RPGLE
quit
```

### Paso 7: Compilar el programa

```bash
# Conectar a IBM i
ssh usuario@ibmi

# Agregar LIBHTTP a library list
ADDLIBLE LIB(LIBHTTP)

# Compilar
CRTBNDRPG PGM(TULIB/CLIMAREAL) +
          SRCSTMF('/home/usuario/CLIMAREAL.RPGLE') +
          DBGVIEW(*SOURCE)

# Verificar compilación
DSPPGM PGM(TULIB/CLIMAREAL)
```

### Paso 8: Configurar permisos

```bash
# Dar permisos al usuario HTTP
GRTOBJAUT OBJ(TULIB/CLIMAREAL) +
          OBJTYPE(*PGM) +
          USER(QTMHHTTP) +
          AUT(*USE)

# Verificar permisos
DSPOBJAUT OBJ(TULIB/CLIMAREAL) OBJTYPE(*PGM)
```

### Paso 9: Probar la aplicación

#### 9.1 Prueba básica

```
http://tu-servidor:puerto/pub/CLIMAREAL.net
```

#### 9.2 Prueba con ciudad específica

```
http://tu-servidor:puerto/pub/CLIMAREAL.net?ciudad=Madrid
http://tu-servidor:puerto/pub/CLIMAREAL.net?ciudad=New+York
http://tu-servidor:puerto/pub/CLIMAREAL.net?ciudad=Tokyo
```

## Solución de Problemas

### Error 404 - Not Found

**Causa:** Programa no encontrado o ScriptAliasMatch mal configurado

**Solución:**
```bash
# Verificar que el programa existe
WRKOBJ OBJ(TULIB/CLIMAREAL) OBJTYPE(*PGM)

# Verificar configuración Apache
grep "ScriptAliasMatch" /www/tu-instancia/conf/httpd.conf
```

### Error 500 - Internal Server Error

**Causa:** Error en el programa o falta de permisos

**Solución:**
```bash
# Ver logs de Apache
tail -50 /www/tu-instancia/logs/error_log

# Verificar permisos
DSPOBJAUT OBJ(TULIB/CLIMAREAL) OBJTYPE(*PGM)

# Verificar library list
grep "QIBM_CGI_LIBRARY_LIST" /www/tu-instancia/conf/httpd.conf
```

### Error de compilación

**Causa:** HTTPAPI o CGIDEV2 no encontrados

**Solución:**
```bash
# Verificar HTTPAPI
WRKOBJ OBJ(LIBHTTP/HTTPAPIR4) OBJTYPE(*SRVPGM)

# Verificar CGIDEV2
WRKOBJ OBJ(CGIDEV2/PROTOTYPEB) OBJTYPE(*FILE)

# Agregar a library list antes de compilar
ADDLIBLE LIB(LIBHTTP)
ADDLIBLE LIB(CGIDEV2)
```

### API no responde

**Causa:** API key inválida o sin conexión

**Solución:**
```bash
# Verificar conectividad
ping api.openweathermap.org

# Probar API key manualmente
curl "http://api.openweathermap.org/data/2.5/weather?q=Madrid&appid=TU_API_KEY"

# Verificar que LIBHTTP está en library list CGI
grep "LIBHTTP" /www/tu-instancia/conf/httpd.conf
```

## Verificación Final

### Checklist de instalación

- [ ] Apache funcionando
- [ ] CGIDEV2 instalado
- [ ] HTTPAPI instalado
- [ ] API key configurada
- [ ] Programa compilado
- [ ] Permisos configurados
- [ ] httpd.conf actualizado
- [ ] Apache reiniciado
- [ ] Aplicación accesible

### Comandos de verificación

```bash
# 1. Verificar Apache
WRKACTJOB SBS(QHTTPSVR)

# 2. Verificar programa
DSPPGM PGM(TULIB/CLIMAREAL)

# 3. Verificar permisos
DSPOBJAUT OBJ(TULIB/CLIMAREAL) OBJTYPE(*PGM)

# 4. Ver logs
tail -20 /www/tu-instancia/logs/error_log
```

## Próximos Pasos

Una vez instalado:

1. Personalizar el diseño (CSS en el código)
2. Agregar más datos del clima
3. Implementar caché de respuestas
4. Agregar gráficos del clima
5. Crear versión móvil

## Soporte

Si tienes problemas:

1. Revisar los logs de Apache
2. Verificar el joblog del programa
3. Consultar la documentación de HTTPAPI
4. Abrir un issue en GitHub

---

¿Necesitas ayuda? Abre un issue en el repositorio.