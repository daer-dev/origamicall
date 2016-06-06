# Como en Ruby no hay forma de clonar un objeto recursivamente, creamos un método que lo haga
# Con él podremos obtener el contenido de, por ejemplo, un Array que contenga un Hash (o varios)

Object.class_eval do
  def rclone
    if [ Array, Hash ].include? self.class
      obj = self.class.new
      for i in 0..(length - 1) do
        if self.class == Array
          code = 'obj[i] = self[i]'
        else
          code = 'obj[self.keys[i]] = self.values[i]'
        end
        eval "#{code}.rclone"
      end
      obj
    else
      self
    end
  end
end