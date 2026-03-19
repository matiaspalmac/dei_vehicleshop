# dei_vehicleshop

Tienda de vehiculos para FiveM - Dei Ecosystem.

## Caracteristicas

- Multiples concesionarias configurables
- Catalogo con filtro por categorias y busqueda
- Sistema de test drive con temporizador
- Compra con validacion servidor
- Modo empleado con comision
- UI glassmorphism con 4 temas + modo claro
- Compatible con ESX y QBCore

## Dependencias

- oxmysql
- es_extended o qb-core
- dei_notifys (opcional)
- dei_input (opcional)

## Instalacion

1. Copiar `dei_vehicleshop` a tu carpeta de resources
2. Agregar `ensure dei_vehicleshop` a tu server.cfg
3. Configurar `config.lua` segun tu servidor

## Configuracion

Editar `config.lua` para ajustar:
- Framework (esx/qb)
- Ubicaciones de concesionarias
- Vehiculos disponibles y precios
- Tiempo de test drive
- Comision de empleados

## Comandos

- `/vender [id]` - Vender vehiculo a otro jugador (requiere trabajo de dealer)

## Exports

```lua
-- Cliente
exports['dei_vehicleshop']:OpenShop(shopId)
exports['dei_vehicleshop']:GetVehiclePrice(model)
```

---
Dei Ecosystem | 2026

## Licencia

MIT License - Dei
