describe Certificate do

  it { is_expected.to have_property :id }
  it { is_expected.to have_property :identifier }
  it { is_expected.to have_property :image_key }
  it { is_expected.to have_property :certificate_key }
  it { is_expected.to have_property :created_at }

  it { is_expected.to belong_to :delivery }
  it { is_expected.to belong_to :student }

  describe 'Creating a Certificate' do
    before do
      course = Course.create(title: 'Learn To Code 101', description: 'Introduction to programming')
      delivery = course.deliveries.create(start_date: '2015-01-01')
      student = delivery.students.create(full_name: 'Thomas Ochman', email: 'thomas@random.com')
      @certificate = student.certificates.create(created_at: DateTime.now, delivery: delivery)
    end

    after { FileUtils.rm_rf Dir['pdf/test/**/*.pdf'] }

    it 'adds an identifier after create' do
      expect(@certificate.identifier.size).to eq 64
    end

    it 'has a Student name' do
      expect(@certificate.student.full_name).to eq 'Thomas Ochman'
    end

    it 'has a Course name' do
      expect(@certificate.delivery.course.title).to eq 'Learn To Code 101'
    end

    it 'has a Course delivery date' do
      expect(@certificate.delivery.start_date.to_s).to eq '2015-01-01'
    end

    describe 'S3' do
      before { CertificateGenerator.generate(@certificate) }

      it 'can be fetched by #image_url' do
        binding.pry
        expect(@certificate.image_url).to eq 'https://certz.s3.amazonaws.com/pdf/test/thomas_ochman_2015-01-01.jpg'
      end

      it 'can be fetched by #certificate_url' do
        expect(@certificate.certificate_url).to eq 'https://certz.s3.amazonaws.com/pdf/test/thomas_ochman_2015-01-01.pdf'
      end

      it 'returns #bitly_lookup' do
        expect(@certificate.bitly_lookup).to eq "http://localhost:9292/verify/#{@certificate.identifier}"
      end

      it 'returns #stats' do
        expect(@certificate.stats).to eq 0
      end


    end


  end


end

