class CertificateGenerator
  def self.generate_participation_certificate(user, event)
    # Debug information
    Rails.logger.info "Generating certificate for user: #{user.name} for event: #{event.name}"
    
    begin
      # Set up WickedPDF
      controller = ActionController::Base.new
      
      # Assign instance variables to be used in the template
      controller.instance_variable_set(:@user, user)
      controller.instance_variable_set(:@event, event)
      
      pdf = WickedPdf.new.pdf_from_string(
        controller.render_to_string(
          template: 'certificates/participation',
          layout: nil
        ),
        page_size: 'Letter',
        orientation: 'Landscape',
        margin: { top: 0, bottom: 0, left: 0, right: 0 }
      )
      
      Rails.logger.info "Certificate generated successfully"
      return pdf
    rescue => e
      Rails.logger.error "Error generating certificate: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # Return a simple PDF with error information for debugging
      return WickedPdf.new.pdf_from_string("<h1>Error generating certificate</h1><p>#{e.message}</p>")
    end
  end
end