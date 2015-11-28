describe 'sending an email' do
  Mail.defaults do
    delivery_method :test # in practice you'd do this in spec_helper.rb
  end

  include Mail::Matchers

  before(:each) do
    Mail::TestMailer.deliveries.clear

    Mail.deliver do
      to ['mike1@me.com', 'mike2@me.com']
      from 'you@you.com'
      subject 'Course Certificate'
      body     File.read('pdf/templates/body.txt')
      add_file filename: "certificate.jpg", content: File.read("pdf/templates/certificate_tpl.jpg")
    end
  end

  it { is_expected.to have_sent_email }

  it { is_expected.to have_sent_email.from('you@you.com') }
  it { is_expected.to have_sent_email.to('mike1@me.com') }

  it { is_expected.to have_sent_email.to(['mike1@me.com', 'mike2@me.com']) }

  it { is_expected.to have_sent_email.with_subject('Course Certificate') }

  it { is_expected.to have_sent_email.with_attachments('certificate.jpg') }


end



