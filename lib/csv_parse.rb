require 'csv'

module CSVParse
  def self.import(file, obj, parent)
    import = CSV.read(file, quote_char: '"',
                      col_sep: ';',
                      row_sep: :auto,
                      headers: true,
                      header_converters: :symbol,
                      converters: :all).collect do |row|
      Hash[row.collect { |c, r| [c, r] }]
    end
    CSVParse.create_instance(parent, obj, import)
  end

  def self.create_instance(parent, obj, dataset)
    dataset.each do |data|
      student = obj.first_or_create({full_name: data[:full_name]}, {full_name: data[:full_name], email: data[:email]})
      student.deliveries << parent unless student.deliveries.include? parent
      student.save
    end
  end
end