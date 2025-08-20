# STV

### Prerequisites
* Ruby version: 2.5.0
* Rails version: 5.2.0
* Database Used: Postgres (for both development and production)
  * Set up postgres
    * Login to postgres and create a superuser  **(we need it because we're enabling a couple of extensions)**
      * `create role stv with createdb superuser login password your-password;`   

### Setup the environment
* Open bash profile set the following
  * **APP_DEV_PASS** (development DB password)
  * **EMAIL_USERNAME**
  * **EMAIL_PASSWORD**

### Commands 
  * ssh-keygen
  * git clone
  * sudo apt-get install software-properties-commo
  * sudo apt-get update
  * sudo apt-get upgrade
  * sudo apt-add-repository -y ppa:rael-gc/rvm
  * sudo apt-get update
  * sudo apt-get install rvm
  * sudo usermod -a -G rvm $USER
  * rvm install 2.5.0
  * sudo apt install libpq-dev
  * sudo apt-get install nodejs
  * sudo apt install redis-server
  * sudo apt-get install libjpeg-dev
  * sudo apt install postgresql postgresql-contrib
  * sudo -i -u postgres
    * psql
    * `create role stv with createdb superuser login password your-password;`
  * bundle install
  * rails db:setup
  * rails active_storage:install
  * rails db:setup
  * rails db:seed
  * rails s

### Know postgresql port
* pg_lsclusters

### Clone/Download
* `bundle install --deployment`
* `rails db:setup` (though this will load the seed as well, but you can run rake db:seed, just in case)
* `rails active_storage:install`
* `rails db:setup`
* `rails db:seed` 
(this will setup the data for roles, question_types, registration status and event status)
* Create an ER Diagram `rails db:migrate`

### Run the Server
* `rails s`
* Run: `gem pristine --all`


### Resque (for background jobs, mostly emails!)
* `QUEUE=* rake resque:work`

## Flujo del evento

- Crear un evento
- Crear formularios de registro, llamada a ponencias, comentarios para el mismo (o podemos reutilizar algunos formularios anteriores también)
- Crear un conjunto de formularios y asignar un formulario (hay principalmente 3 conjuntos de formularios)
  * Llamada a Ponencias
  * Registro
  * Comentarios
- Compartir los enlaces del formulario de Llamada a Ponencias con los miembros en las redes sociales [esto se hace fuera de la plataforma, pero realmente nos gustaría integrarlo también]
- Finalizar los ponentes a partir de las entradas recibidas de la Llamada a Ponencias 
- Enviar RSVP y recibir confirmación de los ponentes
- En el correo electrónico de RSVP, también se le pedirá al ponente que complete los detalles y los enlaces a las diapositivas/contenido de su sesión.
- Para este momento, la ubicación y el track + la agenda/horario se pueden actualizar en el evento.
- Lanzar los registros y continuar con las preselecciones.
- Cerrar los formularios de Llamada a Ponencias y Registro actualizando el estado.
- Enviar pases de entrada únicos al candidato confirmado (confirmaron en el correo electrónico de RSVP que tiene un enlace automático para la confirmación)
  **DÍA DEL EVENTO:**
- Marcar la asistencia usando la página de asistencia
- Puedes optar por permitir entradas no invitadas cambiando el estado del formulario de registro (recibirán automáticamente los pases de entrada)
- Al final del evento, simplemente haz clic en un botón para enviar el formulario de comentarios a los asistentes que han marcado su asistencia.




