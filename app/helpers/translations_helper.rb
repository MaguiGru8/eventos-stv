module TranslationsHelper
    def translate_to_es(status_name)
      translations = {
        'open' => 'Abierto',
        'announced' => 'Anunciado',
        'canceled' => 'Cancelado',
        'completed' => 'Completado',
        'ongoing' => 'En proceso',
        'draft' => 'En borrador',
        'communication' => 'Comunicación',
        'attendee' => 'Inscriptos',
        'speaker' => 'Ponente',
        'system_administrator' => 'Administrador',
        'organizer' => 'Organizador',
        'member' => 'Miembro',
        'short_answer' => 'Respuesta corta',
        'long_answer' => 'Respuesta larga',
        'number' => 'Numérico',
        'single_choice' => 'Elección única',
        'multiple_choice' => 'Elección múltiple',
        'yet_to_announce' => 'Aún por anunciar',
        'open_but_invisible' => 'Abierto pero invisible',
        'members_who_have_attended' => 'Miembros que han asistido',
        'closed' => 'Cerrado',
        'all' => 'Todo',
        'registered' => 'Registrado',
        'waiting' => 'Pendiente',
        'shortlisted' => 'Preseleccionado',
        'confirmed' => 'Confirmado',
        'cancelled' => 'Cancelado'
        
        

      }
      translations[status_name.downcase] || status_name.titlecase
    end

end
