class Student
  include DataMapper::Resource

  property :id, Serial
  property :full_name, String
  property :email, String

  has n, :deliveries, through: Resource
  has n, :certificates
end