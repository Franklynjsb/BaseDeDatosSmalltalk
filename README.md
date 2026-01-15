# Trabajo Práctico: Sistema de Compatibilidad de Donantes

Este repositorio contiene la resolución del Trabajo Práctico para la asignatura **Paradigmas de Programación**. El proyecto integra el paradigma Orientado a Objetos y el Lógico para simular un sistema de gestión y verificación de donantes.

## 📋 Descripción del Proyecto

El objetivo es determinar la compatibilidad entre pacientes para la donación de órganos, utilizando un flujo híbrido de datos y lógica:

1.  **Paradigma de objetos (Smalltalk):** Actúa como base de datos. Se encarga del registro, modelado y almacenamiento de los pacientes.
2.  **Paradigma Lógico (Prolog):** Consulta la información generada por Smalltalk y evalúa, mediante reglas lógicas, si un paciente $X$ puede ser donante de un paciente $Y$.

## 🛠️ Tecnologías Utilizadas

* **Smalltalk:** (Pharo) para el manejo de objetos y persistencia.
* **Prolog:** (SWI-Prolog) para el motor de inferencia y reglas de negocio.

## 🚀 Funcionalidades

### Módulo Smalltalk (Base de Datos)
* Alta y modificación de pacientes.
* Gestión de atributos clínicos (tipo de sangre, factor, órganos sanos, etc.).
* Exportación/Disponibilización de los datos para el motor lógico.

### Módulo Prolog (Reglas de Negocio)
* **Base de Conocimiento:** Carga los hechos provenientes de Smalltalk.
* **Reglas de Compatibilidad:** Define las condiciones estrictas para la donación (ej: compatibilidad sanguínea, compatibilidad de tejido, edad, etc.).