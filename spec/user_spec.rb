require 'user'
require 'bcrypt'

describe User do
  it { is_expected.to have_property :id }
  it { is_expected.to have_property :name }
  it { is_expected.to have_property :email }
  it { is_expected.to have_property :password_digest }

  describe 'password encryption' do
    it 'encrypts password' do
      user = User.create(name: 'test', email: 'test@test.com', password: 'test', password_confirmation: 'test')
      expect(user.password_digest).to_not eql 'test'
      expect(user.password_digest.class).to eq BCrypt::Password
    end

    it 'raises error it password_confirmation does not match' do
      create_user = lambda { User.create(name: 'test', email: 'test@test.com', password: 'test', password_confirmation: 'wrong-test') }
      expect(create_user).to raise_error DataMapper::SaveFailureError
    end
  end

  describe 'user authentication' do
    before { @user = User.create(name: 'Thomas',
                                 email: 'thomas@makersacademy.se',
                                 password: 'password',
                                 password_confirmation: 'password') }

    it 'succeeds with valid credentials' do
      expect(User.authenticate('thomas@makersacademy.se', 'password')).to eq @user
    end

    it 'fails with invalid credentials' do
      expect(User.authenticate('thomas@makersacademy.se', 'wrong-password')).to eq nil
    end
  end
end