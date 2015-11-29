require 'prawn'
require 'rmagick'
require 'aws-sdk'
require 'bitly'
require 'mail'

if ENV['RACK_ENV'] != 'production'
  require 'dotenv'
end

module CertificateGenerator
  if ENV['RACK_ENV'] != 'production'
    Dotenv.load
  end
  Bitly.use_api_version_3
  CURRENT_ENV = ENV['RACK_ENV'] || 'development'
  PATH = "pdf/#{CURRENT_ENV}/"
  TEMPLATE = File.absolute_path('./pdf/templates/certificate_tpl.jpg')
  URL = ENV['SERVER_URL'] || 'http://localhost:9292/verify/'
  S3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
  BITLY = Bitly.new(ENV['BITLY_USERNAME'], ENV['BITLY_API_KEY'])

  def self.generate(certificate)
    details = {name: certificate.student.full_name,
               email: certificate.student.email,
               date: certificate.delivery.start_date.to_s,
               course_name: certificate.delivery.course.title,
               course_desc: certificate.delivery.course.description,
               verify_url: [URL, certificate.identifier].join('')}

    file_name = [details[:name], details[:date], details[:course_name]].join('_').downcase.gsub!(/\s/, '_')

    certificate_output = "#{PATH}#{file_name}.pdf"
    image_output = "#{PATH}#{file_name}.jpg"

    make_prawn_document(details, certificate_output)
    make_rmagic_image(certificate_output, image_output)

    upload_to_s3(certificate_output, image_output)

    send_email(details, file_name)

    certificate.update(certificate_key: certificate_output, image_key: image_output )
  end

  private

  def self.make_prawn_document(details, output)
    File.delete(output) if File.exist?(output)

    Prawn::Document.generate(output,
                             page_size: 'A4',
                             background: TEMPLATE,
                             background_scale: 0.8231,
                             page_layout: :landscape,
                             left_margin: 30,
                             right_margin: 40,
                             top_margin: 7,
                             bottom_margin: 0,
                             skip_encoding: true) do |pdf|
      pdf.move_down 245
      pdf.font 'assets/fonts/Gotham-Bold.ttf'
      pdf.text details[:name], size: 44, color: '009900', align: :center
      pdf.move_down 20
      pdf.font 'assets/fonts/Gotham-Medium.ttf'
      pdf.text details[:course_name], indent_paragraphs: 150, size: 20
      pdf.text details[:course_desc], indent_paragraphs: 150, size: 20
      pdf.move_down 95
      pdf.text "Göteborg #{details[:date]}", indent_paragraphs: 120, size: 12
      pdf.move_down 65
      pdf.text "To verify this certificate, visit: #{get_url(details[:verify_url])}", indent_paragraphs: 100, size: 8
    end
  end

  def self.make_rmagic_image(certificate_output, output)
    im = Magick::Image.read(certificate_output)
    im[0].write(output)
  end

  def self.upload_to_s3(certificate_output, image_output)
    s3_certificate_object = S3.bucket(ENV['S3_BUCKET']).object(certificate_output)
    s3_certificate_object.upload_file(certificate_output, acl: 'public-read')
    s3_image_object = S3.bucket(ENV['S3_BUCKET']).object(image_output)
    s3_image_object.upload_file(image_output, acl: 'public-read')
  end

  def self.send_email(details, file)
    mail = Mail.new do
      from     "The course team <#{ENV['SENDGRID_USERNAME']}>"
      to       "#{details[:name]} <#{details[:email]}>"
      subject  "Course Certificate - #{details[:course_name]}"
      body     File.read('pdf/templates/body.txt')
      add_file filename: "#{file}.pdf", mime_type: 'application/x-pdf', content: File.read("#{PATH}#{file}.pdf")
    end
    mail.deliver
  end

  def self.get_url(url)
    begin
      BITLY.shorten(url).short_url
    rescue
      url
    end
  end

end