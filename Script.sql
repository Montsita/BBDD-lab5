DROP DATABASE IF EXISTS gestion_de_hotel;
CREATE DATABASE gestion_de_hotel;
USE gestion_de_hotel;

CREATE TABLE Hotel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL
);

CREATE TABLE servicio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE Habitacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id INT NOT NULL,
    numero INT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    estado VARCHAR(80) NOT NULL,
    FOREIGN KEY (hotel_id) REFERENCES Hotel(id)
);

CREATE TABLE cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    habitacion_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    FOREIGN KEY (habitacion_id) REFERENCES Habitacion(id)
);

CREATE TABLE Reserva (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    habitacion_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(100) NOT NULL,
    fecha_checkin DATE,
    fecha_checkout DATE,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id),
    FOREIGN KEY (habitacion_id) REFERENCES Habitacion(id)
);

CREATE TABLE reserva_servicio (
    reserva_id INT NOT NULL,
    servicio_id INT NOT NULL,
    PRIMARY KEY (reserva_id, servicio_id),
    FOREIGN KEY (reserva_id) REFERENCES Reserva(id),
    FOREIGN KEY (servicio_id) REFERENCES servicio(id)
);

CREATE TABLE cliente_servicio (
    cliente_id INT NOT NULL,
    servicio_id INT NOT NULL,
    PRIMARY KEY (cliente_id, servicio_id),
    FOREIGN KEY (cliente_id) REFERENCES cliente(id),
    FOREIGN KEY (servicio_id) REFERENCES servicio(id)
);

alter table Habitacion add cliente_id INT;
alter table Habitacion
add constraint fk_habitacion_cliente FOREIGN key (cliente_id)
references cliente(id);


INSERT INTO Hotel (nombre, direccion) VALUES
('Hotel Paraíso', 'Calle de la Paz, 123, Ciudad Esperanza'),
('Hotel del Mar', 'Avenida del Océano, 456, Playa Hermosa'),
('Hotel Montaña', 'Calle de los Andes, 789, Ciudad Nevada');


INSERT INTO servicio (nombre, descripcion) VALUES
('Desayuno', 'Desayuno buffet incluido'),
('Piscina', 'Acceso a la piscina climatizada'),
('Spa', 'Tratamientos y masajes en el spa'),
('WiFi', 'Conexión WiFi en todas las áreas');


INSERT INTO Habitacion (hotel_id, numero, tipo, estado) VALUES
(1, 101, 'Doble', 'Ocupada'),
(1, 102, 'Individual', 'Libre'),
(2, 201, 'Suite', 'Ocupada'),
(3, 301, 'Doble', 'Libre');


INSERT INTO cliente (habitacion_id, nombre, direccion) VALUES
(1, 'Juan Pérez', 'Calle de los Olivos, 321, Ciudad Verde'),
(3, 'María Gómez', 'Avenida de las Flores, 654, Ciudad Rosa');

-- modificar cada registro de la habitación para que apunte a su respectivo cliente
update habitacion h
join cliente c on h.id = c.habitacion_id 
set h.cliente_id = 1
where c.id = 1;

update habitacion h
join cliente c on h.id = c.habitacion_id 
set h.cliente_id = 2
where c.id = 2;


INSERT INTO Reserva (cliente_id, habitacion_id, fecha_inicio, fecha_fin, estado, fecha_checkin, fecha_checkout) VALUES
(1, 1, '2024-07-01', '2024-07-05', 'Confirmada', '2024-07-01', '2024-07-05'),
(2, 3, '2024-07-03', '2024-07-10', 'Confirmada', '2024-07-03', '2024-07-10');


INSERT INTO reserva_servicio (reserva_id, servicio_id) VALUES
(1, 1),
(1, 4),
(2, 2),
(2, 3);


INSERT INTO cliente_servicio (cliente_id, servicio_id) VALUES
(1, 1),
(1, 4),
(2, 2),
(2, 3);

-- obtener la lista de habitaciones reservadas junto con los nombres de los clientes que las ocupan

select h.numero as num_hab, c.nombre as cliente
from habitacion h
join cliente c on h.id = c.habitacion_id
where h.estado = 'Ocupada';

-- obtener una lista de servicios reservados por un cliente específico junto con los detalles de cada servicio.

select s.descripcion as servicio, c.nombre as cliente
from servicio s 
join cliente_servicio cs on s.id = cs.servicio_id
join cliente c on cs.cliente_id = c.id;


-- RETOS ADICIONALES

-- 7. Utilizar subconsultas para obtener la cantidad total de reservas realizadas en un hotel específico en un mes determinado.

select h2.nombre as hotel, count(r.id) as reservas
from hotel h2
join habitacion h on h.hotel_id = h2.id
join reserva r on r.habitacion_id = h.id 
where h2.nombre = "Hotel Paraíso"
and r.fecha_inicio between "2024-07-01" and "2024-07-02"
and r.fecha_fin between "2024-07-05" and "2024-07-06";
-- group by h2.nombre NO FUNCIONA

-- 8 Implementar índices en las tablas relevantes para mejorar el rendimiento de consultas frecuentes, como la búsqueda de habitaciones disponibles.
-- Índices en la tabla Hotel
CREATE INDEX idx_nombre_hotel ON Hotel(nombre);

-- Índices en la tabla Habitacion
CREATE INDEX idx_hotelId_habitacion ON habitacion(hotel_id);
CREATE INDEX idx_estado_habitacion ON habitacion(estado);

-- Índices en la tabla Cliente
CREATE INDEX idx_nombre_cliente ON cliente(nombre);

-- Índices en la tabla Reserva
CREATE INDEX idx_idCliente_reserva ON Reserva(cliente_id);
CREATE INDEX idx_fechaInicio_reserva ON Reserva(fecha_inicio);
CREATE INDEX idx_fechaFin_reserva ON Reserva(fecha_fin);

-- Índice en la tabla Servicio
create index idx_descripcion_servicio on servicio(descripcion);

-- 9 Simular escenarios de reservas simultáneas utilizando transacciones para garantizar la consistencia de los datos y evitar conflictos.

START TRANSACTION;

INSERT INTO reserva (cliente_id, habitacion_id, fecha_inicio, fecha_fin, estado, fecha_checkin, fecha_checkout)
VALUES (1, 1, '2024-07-15', '2024-07-20', 'confirmada', '2024-07-15', '2024-07-20');

INSERT INTO Reserva_Servicio (reserva_id, servicio_id)
VALUES (LAST_INSERT_ID(), 1), (LAST_INSERT_ID(), 2);

INSERT INTO reserva (cliente_id, habitacion_id, fecha_inicio, fecha_fin, estado, fecha_checkin, fecha_checkout)
VALUES (2, 2, '2024-08-01', '2024-08-10', 'confirmada', '2024-08-01', '2024-08-10');

INSERT INTO Reserva_Servicio (reserva_id, servicio_id)
VALUES (LAST_INSERT_ID(), 3), (LAST_INSERT_ID(), 2), (LAST_INSERT_ID(), 4);

COMMIT;
ROLLBACK; 

-- 10 Crear triggers para automatizar acciones en la base de datos, como la actualización del estado de una habitación al realizarse una reserva o cancelación.

DELIMITER $$
CREATE TRIGGER actualizar_estado_habitacion AFTER INSERT ON reserva
    FOR EACH ROW
    BEGIN
        UPDATE Habitacion SET estado = 'Ocupada' WHERE id = NEW.habitacion_id;
    end$$
  
DELIMITER ;

 -- 11 Realiza al menos una consulta anidada.
   
   select s.descripcion as servicio, c.nombre as cliente, h.numero as habitacion
	from servicio s 
	left join cliente_servicio cs on s.id = cs.servicio_id
	left join cliente c on cs.cliente_id = c.id 
	left join habitacion h on h.cliente_id = c.id