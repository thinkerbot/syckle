Gem::Specification.new do |s|
  s.name = "syckle"
  s.version = "1.0"
  s.author = "Simon Chiang"
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://bahuvrihi.github.com/syckle"
  s.platform = Gem::Platform::RUBY
  s.summary = "A sick little syck loader."
  s.require_path = "lib"
  s.has_rdoc = true
  s.rdoc_options.concat %w{--main README -S -N --title Syckle}
     
  s.extra_rdoc_files = %W{
    README
    MIT-LICENSE}
  
  s.files = %W{
    lib/syckle.rb
    lib/syckle/setup.rb
    lib/syckle/syck.rb
  }
end